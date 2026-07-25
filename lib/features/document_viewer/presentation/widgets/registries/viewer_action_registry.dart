import '../../../domain/entities/viewer_capability.dart';
import '../commands/viewer_command.dart';

class ViewerActionRegistry {
  final Map<ViewerCapability, ViewerCommand> _registry = {};

  void register(ViewerCapability capability, ViewerCommand command) {
    _registry[capability] = command;
  }

  ViewerCommand? getCommand(ViewerCapability capability) {
    return _registry[capability];
  }
}
