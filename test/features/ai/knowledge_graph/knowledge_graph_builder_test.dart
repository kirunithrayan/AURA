// KnowledgeGraphBuilder was registered in the DI container but never called,
// and it did not work. Two defects sat in the document loop:
//
//   * it read `docMap['name']`, but workspace_files has no `name` column (it is
//     `file_name`), so the non-nullable cast threw on the first document;
//   * it read `docMap['content']`, and that column does not exist either. The
//     cast was nullable, so text silently became '' for every document, which
//     yields zero concepts, zero edges, and a graph of unconnected dots.
//
// Document text lives behind AbstractTextDocumentEngine, the parser the search
// index already uses. These tests pin that contract: real text in, populated
// graph out, and rebuilding must not duplicate what is already stored.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:aura/core/error/failures.dart';
import 'package:aura/core/text_engine/abstract_text_document_engine.dart';
import 'package:aura/core/text_engine/models/text_document.dart';
import 'package:aura/features/ai/knowledge_graph/domain/entities/knowledge_edge.dart';
import 'package:aura/features/ai/knowledge_graph/domain/entities/knowledge_node.dart';
import 'package:aura/features/ai/knowledge_graph/domain/entities/node_type.dart';
import 'package:aura/features/ai/knowledge_graph/domain/entities/relationship_type.dart';
import 'package:aura/features/ai/knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import 'package:aura/features/ai/knowledge_graph/domain/services/concept_extraction_service.dart';
import 'package:aura/features/ai/knowledge_graph/domain/services/knowledge_graph_builder.dart';
import 'package:aura/features/ai/knowledge_graph/domain/services/relationship_detection_service.dart';
import 'package:aura/features/document_viewer/domain/entities/viewer_search_result.dart';
import 'package:aura/features/workspace/domain/entities/workspace_file.dart';
import 'package:aura/features/workspace/domain/repositories/workspace_repository.dart';

const _workspaceId = 'ws-1';

WorkspaceFile _file(String id) => WorkspaceFile(
      id: id,
      workspaceId: _workspaceId,
      fileName: '$id.txt',
      filePath: '/tmp/$id.txt',
      extension: 'txt',
      createdAt: 0,
      modifiedAt: 0,
      importedAt: 0,
    );

/// Mirrors the real table, which is `id TEXT PRIMARY KEY` written with
/// `ConflictAlgorithm.replace`: storing the same id twice replaces the row
/// rather than adding a second one. Keying the map on id keeps the fake
/// honest about what the database would actually do.
class _InMemoryGraphRepository implements KnowledgeGraphRepository {
  final Map<String, KnowledgeNode> nodes = {};
  final Map<String, KnowledgeEdge> edges = {};

  @override
  Future<void> saveNode(KnowledgeNode node) async => nodes[node.id] = node;

  @override
  Future<void> saveNodes(List<KnowledgeNode> list) async {
    for (final node in list) {
      nodes[node.id] = node;
    }
  }

  @override
  Future<void> saveEdge(KnowledgeEdge edge) async => edges[edge.id] = edge;

  @override
  Future<void> saveEdges(List<KnowledgeEdge> list) async {
    for (final edge in list) {
      edges[edge.id] = edge;
    }
  }

  @override
  Future<KnowledgeNode?> getNode(String id) async => nodes[id];

  @override
  Future<List<KnowledgeNode>> getNodesForWorkspace(String workspaceId) async =>
      nodes.values.where((n) => n.workspaceId == workspaceId).toList();

  @override
  Future<List<KnowledgeEdge>> getEdgesForWorkspace(String workspaceId) async {
    final ids = nodes.values
        .where((n) => n.workspaceId == workspaceId)
        .map((n) => n.id)
        .toSet();
    return edges.values.where((e) => ids.contains(e.sourceId)).toList();
  }

  @override
  Future<List<KnowledgeEdge>> getEdgesForNode(String nodeId) async => edges
      .values
      .where((e) => e.sourceId == nodeId || e.targetId == nodeId)
      .toList();

  @override
  Future<void> deleteNode(String id) async {
    nodes.remove(id);
    edges.removeWhere((_, e) => e.sourceId == id || e.targetId == id);
  }

  @override
  Future<void> clearWorkspaceGraph(String workspaceId) async {
    final ids = nodes.values
        .where((n) => n.workspaceId == workspaceId)
        .map((n) => n.id)
        .toSet();
    nodes.removeWhere((id, _) => ids.contains(id));
    edges.removeWhere((_, e) => ids.contains(e.sourceId));
  }
}

class _FakeWorkspaceRepository implements WorkspaceRepository {
  _FakeWorkspaceRepository(this.files, {this.failure});

  final List<WorkspaceFile> files;
  final Failure? failure;

  @override
  Future<Either<Failure, List<WorkspaceFile>>> getWorkspaceFiles(
      String workspaceId) async {
    final f = failure;
    if (f != null) return Left(f);
    return Right(files.where((x) => x.workspaceId == workspaceId).toList());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used by KnowledgeGraphBuilder');
}

/// Returns whatever body text the test assigned to a file id.
class _FakeTextEngine implements AbstractTextDocumentEngine {
  _FakeTextEngine(this.bodies, {this.failFor = const {}});

  final Map<String, String> bodies;
  final Set<String> failFor;

  @override
  Future<TextDocument> openDocument(WorkspaceFile file) async {
    if (failFor.contains(file.id)) {
      throw StateError('cannot parse ${file.id}');
    }
    final content = bodies[file.id] ?? '';
    return TextDocument(
      title: file.fileName,
      content: content,
      headings: const [],
      paragraphCount: 1,
      wordCount: content.split(RegExp(r'\s+')).length,
      characterCount: content.length,
      sourceType: 'txt',
      parserVersion: 'test-1',
    );
  }

  @override
  void close() {}
  @override
  TextDocument? getDocument() => null;
  @override
  Map<String, dynamic> getMetadata() => {};
  @override
  double getScrollPosition() => 0;
  @override
  void setScrollPosition(double position) {}
  @override
  ViewerSearchResult search(String keyword) => throw UnimplementedError();
}

({KnowledgeGraphBuilder builder, _InMemoryGraphRepository repo}) _harness({
  required Map<String, String> bodies,
  Set<String> failFor = const {},
  Failure? workspaceFailure,
}) {
  final repo = _InMemoryGraphRepository();
  final builder = KnowledgeGraphBuilder(
    repo,
    ConceptExtractionService(),
    RelationshipDetectionService(),
    _FakeWorkspaceRepository(
      bodies.keys.map(_file).toList(),
      failure: workspaceFailure,
    ),
    _FakeTextEngine(bodies, failFor: failFor),
  );
  return (builder: builder, repo: repo);
}

void main() {
  group('KnowledgeGraphBuilder', () {
    test('labels a document node with its file name', () async {
      // Regression: the old code read docMap['name'], a column that does not
      // exist, and threw a type error on the first document.
      final h = _harness(bodies: {'doc-a': 'Machine Learning is a field.'});

      await h.builder.buildGraph(workspaceId: _workspaceId);

      final docNodes =
          h.repo.nodes.values.where((n) => n.type == NodeType.document);
      expect(docNodes, hasLength(1));
      expect(docNodes.single.label, 'doc-a.txt');
      expect(docNodes.single.documentId, 'doc-a');
    });

    test('extracts concepts from the document body', () async {
      // Regression: text came from a nonexistent 'content' column and was
      // always '', so extraction returned nothing and the graph had no edges.
      final h = _harness(bodies: {
        'doc-a': 'Machine Learning underpins Clean Architecture here.',
      });

      await h.builder.buildGraph(workspaceId: _workspaceId);

      final conceptLabels = h.repo.nodes.values
          .where((n) => n.type == NodeType.concept)
          .map((n) => n.label)
          .toList();

      expect(conceptLabels, isNotEmpty);
      expect(conceptLabels, contains('Machine Learning'));
      expect(conceptLabels, contains('Clean Architecture'));

      // And the document must actually be connected to them.
      final mentions = h.repo.edges.values
          .where((e) => e.relationshipType == RelationshipType.mentions);
      expect(mentions, isNotEmpty);
      expect(mentions.every((e) => e.sourceId == 'doc-a'), isTrue);
    });

    test('links two documents that share concepts', () async {
      final h = _harness(bodies: {
        'doc-a': 'Machine Learning and Clean Architecture and Neural Networks.',
        'doc-b': 'Machine Learning and Clean Architecture and Neural Networks.',
      });

      await h.builder.buildGraph(workspaceId: _workspaceId);

      final similar = h.repo.edges.values.where(
          (e) => e.relationshipType == RelationshipType.semanticSimilarity);
      expect(similar, hasLength(1));
      expect({similar.single.sourceId, similar.single.targetId},
          {'doc-a', 'doc-b'});
    });

    test('collapses one concept seen in two documents onto one node', () async {
      final h = _harness(bodies: {
        'doc-a': 'Machine Learning is here.',
        'doc-b': 'Machine Learning is also here.',
      });

      await h.builder.buildGraph(workspaceId: _workspaceId);

      final machineLearning = h.repo.nodes.values
          .where((n) => n.type == NodeType.concept && n.label == 'Machine Learning');
      expect(machineLearning, hasLength(1));
    });

    test('rebuilding does not duplicate nodes or edges', () async {
      // Concept and edge ids used to be uuid.v4(), so every rebuild inserted a
      // parallel copy. The graph is built on import and again on first open of
      // an empty graph, so duplication was reachable in normal use.
      final h = _harness(bodies: {
        'doc-a': 'Machine Learning and Clean Architecture and Neural Networks.',
        'doc-b': 'Machine Learning and Clean Architecture and Neural Networks.',
      });

      await h.builder.buildGraph(workspaceId: _workspaceId);
      final nodesAfterFirst = h.repo.nodes.length;
      final edgesAfterFirst = h.repo.edges.length;

      await h.builder.buildGraph(workspaceId: _workspaceId);

      expect(h.repo.nodes.length, nodesAfterFirst);
      expect(h.repo.edges.length, edgesAfterFirst);
    });

    test('skips a document whose text cannot be parsed', () async {
      final h = _harness(
        bodies: {
          'doc-a': 'Machine Learning is here.',
          'doc-bad': 'unreadable',
        },
        failFor: {'doc-bad'},
      );

      await h.builder.buildGraph(workspaceId: _workspaceId);

      final docIds = h.repo.nodes.values
          .where((n) => n.type == NodeType.document)
          .map((n) => n.id)
          .toSet();
      expect(docIds, {'doc-a'});
    });

    test('builds only the documents named in modifiedDocumentIds', () async {
      final h = _harness(bodies: {
        'doc-a': 'Machine Learning is here.',
        'doc-b': 'Clean Architecture is here.',
      });

      await h.builder.buildGraph(
        workspaceId: _workspaceId,
        modifiedDocumentIds: ['doc-b'],
      );

      final docIds = h.repo.nodes.values
          .where((n) => n.type == NodeType.document)
          .map((n) => n.id)
          .toSet();
      expect(docIds, {'doc-b'});
    });

    test('throws when the workspace file list cannot be read', () async {
      // A read failure must not look like an empty workspace: that would leave
      // a silently blank graph with nothing surfaced to the screen.
      final h = _harness(
        bodies: {'doc-a': 'Machine Learning is here.'},
        workspaceFailure: const DatabaseFailure('db is locked'),
      );

      expect(
        () => h.builder.buildGraph(workspaceId: _workspaceId),
        throwsA(isA<Exception>()),
      );
    });

    test('stores nothing for a workspace with no documents', () async {
      final h = _harness(bodies: {});

      await h.builder.buildGraph(workspaceId: _workspaceId);

      expect(h.repo.nodes, isEmpty);
      expect(h.repo.edges, isEmpty);
    });
  });

  group('derived identity', () {
    test('concept id ignores casing and whitespace runs', () {
      expect(
        ConceptExtractionService.conceptId(
            _workspaceId, ConceptExtractionService.normalizeLabel('Machine  Learning')),
        ConceptExtractionService.conceptId(
            _workspaceId, ConceptExtractionService.normalizeLabel('machine\nlearning')),
      );
    });

    test('concept id is scoped to its workspace', () {
      expect(
        ConceptExtractionService.conceptId('ws-1', 'machine learning'),
        isNot(ConceptExtractionService.conceptId('ws-2', 'machine learning')),
      );
    });
  });
}
