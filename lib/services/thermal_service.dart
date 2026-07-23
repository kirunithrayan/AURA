/// Service to monitor device thermal state.
/// Used by the Adaptive AI Scheduler to pause jobs when device is overheating.
class ThermalService {
  /// Checks if the device is currently in a high thermal state (overheating).
  Future<bool> isOverheating() async {
    // Stub: Real implementation would use platform channels to query 
    // Android PowerManager.getCurrentThermalStatus()
    return false;
  }
}
