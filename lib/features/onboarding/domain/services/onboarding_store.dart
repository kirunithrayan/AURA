/// Records whether the user has finished the first-run onboarding flow.
///
/// Implementations must never throw. Onboarding gates app startup, so a
/// storage failure has to degrade to "not yet complete" rather than blocking
/// launch or crashing.
abstract class OnboardingStore {
  /// Whether onboarding has already been completed on this device.
  ///
  /// Returns `false` when the flag is missing, unset, or unreadable, so any
  /// failure shows onboarding again instead of silently skipping it.
  Future<bool> isOnboardingComplete();

  /// Records that the user finished or skipped onboarding.
  ///
  /// Best-effort: a write failure is swallowed so the user is never trapped in
  /// onboarding. The worst case is seeing it again on the next launch.
  Future<void> markOnboardingComplete();
}
