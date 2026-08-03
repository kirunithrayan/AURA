import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../onboarding/domain/services/onboarding_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// How long the branded splash stays on screen, unchanged from before.
  static const Duration _minimumVisibleDuration = Duration(seconds: 2);

  final OnboardingStore _onboardingStore = sl<OnboardingStore>();

  @override
  void initState() {
    super.initState();
    _resolveStartDestination();
  }

  /// Picks the first real screen: onboarding on first launch, home afterwards.
  ///
  /// The storage read is started *before* the splash delay is awaited, so the
  /// two overlap and the check costs no additional startup time.
  Future<void> _resolveStartDestination() async {
    // The error handler is attached immediately, before the delay is awaited.
    // That keeps a rejected read from surfacing as an unhandled async error,
    // and guarantees we always reach the navigation below: being stranded on
    // the splash screen forever is the one failure the user cannot recover
    // from without force-quitting.
    final Future<bool> onboardingComplete = _onboardingStore
        .isOnboardingComplete()
        .catchError((Object _) => false);

    await Future<void>.delayed(_minimumVisibleDuration);
    final bool isComplete = await onboardingComplete;

    if (!mounted) return;
    context.goNamed(isComplete ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'AURA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adaptive Unified Repository Assistant',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
}
