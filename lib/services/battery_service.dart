/// Service to monitor device battery level and charging state.
/// Used by the Adaptive AI Scheduler to pause intense jobs on low battery.
class BatteryService {
  /// Returns the current battery level (0.0 to 1.0).
  Future<double> getBatteryLevel() async {
    // Stub: Real implementation would use battery_plus package
    return 0.85; 
  }

  /// Checks if the device is currently charging.
  Future<bool> isCharging() async {
    // Stub: Real implementation would use battery_plus package
    return true; 
  }

  /// Evaluates if the battery state allows for AI processing.
  Future<bool> isSafeToProcess() async {
    final level = await getBatteryLevel();
    final charging = await isCharging();

    if (charging) return true;
    return level > 0.20; // Require at least 20% if not charging
  }
}
