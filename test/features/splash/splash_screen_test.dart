import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:aura/core/router/app_routes.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/onboarding/domain/services/onboarding_store.dart';
import 'package:aura/features/splash/presentation/screens/splash_screen.dart';

import '../../support/fake_onboarding_store.dart';

const String _onboardingMarker = 'ONBOARDING_REACHED';
const String _homeMarker = 'HOME_REACHED';

/// Matches the splash screen's own minimum visible duration.
const Duration _splashDuration = Duration(seconds: 2);

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: AppRoutes.onboarding,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text(_onboardingMarker)),
          ),
        ),
        GoRoute(
          path: '/home',
          name: AppRoutes.home,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text(_homeMarker)),
          ),
        ),
      ],
    );

Future<void> _pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: _buildRouter(),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() async {
    await GetIt.instance.reset();
  });

  void registerStore(OnboardingStore store) {
    GetIt.instance.registerSingleton<OnboardingStore>(store);
  }

  group('SplashScreen start destination', () {
    testWidgets('first launch goes to onboarding', (tester) async {
      registerStore(FakeOnboardingStore(complete: false));

      await _pumpSplash(tester);
      expect(find.text('AURA'), findsOneWidget);

      await tester.pump(_splashDuration);
      await tester.pumpAndSettle();

      expect(find.text(_onboardingMarker), findsOneWidget);
      expect(find.text(_homeMarker), findsNothing);
    });

    testWidgets('subsequent launch skips onboarding and goes home',
        (tester) async {
      registerStore(FakeOnboardingStore(complete: true));

      await _pumpSplash(tester);

      await tester.pump(_splashDuration);
      await tester.pumpAndSettle();

      expect(find.text(_homeMarker), findsOneWidget);
      expect(find.text(_onboardingMarker), findsNothing);
    });

    testWidgets('a throwing store falls back to onboarding', (tester) async {
      registerStore(ThrowingOnboardingStore());

      await _pumpSplash(tester);

      await tester.pump(_splashDuration);
      await tester.pumpAndSettle();

      expect(find.text(_onboardingMarker), findsOneWidget);
    });

    testWidgets('stays on the splash until the branded delay elapses',
        (tester) async {
      registerStore(FakeOnboardingStore(complete: true));

      await _pumpSplash(tester);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('AURA'), findsOneWidget);
      expect(find.text(_homeMarker), findsNothing);

      await tester.pump(_splashDuration);
      await tester.pumpAndSettle();

      expect(find.text(_homeMarker), findsOneWidget);
    });

    testWidgets('the storage read adds no time beyond the splash delay',
        (tester) async {
      // A deliberately slow store, but still well inside the 2s splash. If the
      // read were awaited sequentially instead of overlapping, this would push
      // navigation past the delay and the assertion below would fail.
      registerStore(_SlowOnboardingStore(const Duration(milliseconds: 800)));

      await _pumpSplash(tester);
      await tester.pump(_splashDuration);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.text(_homeMarker), findsOneWidget);
    });
  });
}

/// [OnboardingStore] whose read takes a while, used to prove the splash
/// overlaps the read with its own delay rather than adding to it.
class _SlowOnboardingStore implements OnboardingStore {
  _SlowOnboardingStore(this.delay);

  final Duration delay;

  @override
  Future<bool> isOnboardingComplete() async {
    await Future<void>.delayed(delay);
    return true;
  }

  @override
  Future<void> markOnboardingComplete() async {}
}
