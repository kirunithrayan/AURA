import 'package:aura/core/utils/app_logger.dart';

class AppUsageService {
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // Local-only telemetry
    AppLogger.info('Event: $eventName, params: $parameters', category: LogCategory.personalization);
    // In a real app, this could log to a local SQLite table for on-device analytics
  }
}
