import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/viewer_capability.dart';
import 'registries/viewer_action_registry.dart';
import 'commands/zoom_commands.dart';
import 'commands/navigation_commands.dart';
import 'commands/rotation_commands.dart';
import 'commands/action_commands.dart';
import 'commands/ui_commands.dart';
import '../../data/services/document_share_service_impl.dart';

final documentShareServiceProvider = Provider((ref) => DocumentShareServiceImpl());

final viewerActionRegistryProvider = Provider((ref) {
  final registry = ViewerActionRegistry();
  final shareService = ref.read(documentShareServiceProvider);

  registry.register(ViewerCapability.zoom, ZoomCommand());
  registry.register(ViewerCapability.pageNavigation, PageNavigationCommand());
  registry.register(ViewerCapability.rotate, RotateCommand());
  registry.register(ViewerCapability.share, ShareCommand(shareService));
  registry.register(ViewerCapability.openExternally, OpenExternallyCommand(shareService));
  registry.register(ViewerCapability.copy, CopyDocumentPathCommand(shareService));
  registry.register(ViewerCapability.metadata, ViewMetadataCommand());
  registry.register(ViewerCapability.textSettings, OpenTextSettingsCommand());

  return registry;
});
