import 'package:workmanager/workmanager.dart';
import '../core/constants/app_constants.dart';

/// Callback dispatcher for WorkManager background execution.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Initialize DI (database, etc.)
    // 2. Fetch the SchedulerRepository
    // 3. Call executeNextJob()
    
    // Stub
    return Future.value(true);
  });
}

/// Service to handle registration of background tasks via WorkManager.
class WorkManagerService {
  static const String _periodicTaskName = "com.aura.scheduler.periodic";

  /// Initializes WorkManager and registers the background dispatcher.
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  /// Registers the periodic scheduler task that wakes up the app in the background.
  Future<void> registerPeriodicScheduler() async {
    await Workmanager().registerPeriodicTask(
      "aura_scheduler_task",
      _periodicTaskName,
      frequency: const Duration(minutes: AppConstants.schedulerIntervalMinutes),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  /// Cancels all background tasks.
  Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}
