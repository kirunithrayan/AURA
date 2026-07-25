import 'metadata_provider.dart';
import '../../viewmodels/document_viewer_viewmodel.dart';

class PdfMetadataProvider implements MetadataProvider {
  @override
  Map<String, String> getMetadata(DocumentViewerViewModelState state) {
    return {
      'Pages': state.viewState.pageCount.toString(),
    };
  }
}

class ImageMetadataProvider implements MetadataProvider {
  @override
  Map<String, String> getMetadata(DocumentViewerViewModelState state) {
    return {
      'Resolution': 'Unknown',
    };
  }
}

class TextMetadataProvider implements MetadataProvider {
  @override
  Map<String, String> getMetadata(DocumentViewerViewModelState state) {
    if (state.textDocument == null) return {};
    final doc = state.textDocument!;
    return {
      'Words': doc.wordCount.toString(),
      'Characters': doc.characterCount.toString(),
      'Paragraphs': doc.paragraphCount.toString(),
      if (doc.encoding != null) 'Encoding': doc.encoding!,
      if (doc.estimatedReadingTime != null) 'Read Time': '~${doc.estimatedReadingTime} min',
    };
  }
}
