import 'package:aura/features/workspace/domain/entities/workspace_file.dart';

abstract class DocumentShareService {
  Future<void> shareDocument(WorkspaceFile file);
  Future<void> openExternally(WorkspaceFile file);
  Future<void> copyDocumentPath(WorkspaceFile file);
}
