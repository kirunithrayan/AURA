import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';

abstract class MetadataProvider {
  Map<String, String> getMetadata(DocumentViewerViewModelState state);
}
