import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:aura/core/router/app_routes.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/onboarding/domain/services/onboarding_store.dart';
import 'package:aura/features/onboarding/presentation/models/onboarding_page_data.dart';
import 'package:aura/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:aura/features/onboarding/presentation/widgets/onboarding_dot_indicator.dart';

import '../../support/fake_onboarding_store.dart';

/// Marker rendered by the stand-in home route.
const String _homeMarker = 'HOME_REACHED';

/// The store the screen resolves from GetIt for the current test.
late FakeOnboardingStore store;

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/onboarding',
      routes: <RouteBase>[
        GoRoute(
          path: '/onboarding',
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
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

Future<void> _pumpOnboarding(
  WidgetTester tester, {
  ThemeData? theme,
  double textScale = 1.0,
  Size logicalSize = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logicalSize;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: theme ?? AppTheme.lightTheme,
      routerConfig: _buildRouter(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _advanceToLastPage(WidgetTester tester) async {
  for (int i = 0; i < OnboardingContent.pages.length - 1; i++) {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }
}

void main() {
  setUp(() {
    store = FakeOnboardingStore();
    GetIt.instance.registerSingleton<OnboardingStore>(store);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('OnboardingContent', () {
    test('exposes exactly three pages', () {
      expect(OnboardingContent.pages.length, 3);
    });

    test('every page has a non-empty title and description', () {
      for (final OnboardingPageData page in OnboardingContent.pages) {
        expect(page.title.trim(), isNotEmpty);
        expect(page.description.trim(), isNotEmpty);
      }
    });

    test('copy matches the approved wording character for character', () {
      expect(OnboardingContent.pages[0].title, 'Hybrid Search');
      expect(
        OnboardingContent.pages[0].description,
        'Quickly find documents using keyword search, metadata, and '
        'organized workspaces.',
      );

      expect(OnboardingContent.pages[1].title, 'Workspace Management');
      expect(
        OnboardingContent.pages[1].description,
        'Organize files into dedicated workspaces and access recent, pinned, '
        'and favorite documents with ease.',
      );

      expect(OnboardingContent.pages[2].title, 'Secure Storage');
      expect(
        OnboardingContent.pages[2].description,
        'Your documents and workspace information are stored securely to '
        'help protect your data.',
      );
    });

    test('copy makes no on-device or offline AI claims', () {
      final String corpus = OnboardingContent.pages
          .map((page) => '${page.title} ${page.description}')
          .join(' ')
          .toLowerCase();

      for (final String forbidden in <String>[
        'on-device',
        'on device',
        'offline',
        'ai-powered',
        'semantic search',
      ]) {
        expect(corpus.contains(forbidden), isFalse,
            reason: 'onboarding copy must not claim "$forbidden"');
      }
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders the first page with Skip and Next', (tester) async {
      await _pumpOnboarding(tester);

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('Next advances through every page', (tester) async {
      await _pumpOnboarding(tester);

      expect(find.text('Hybrid Search'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Workspace Management'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Secure Storage'), findsOneWidget);
    });

    testWidgets('last page swaps Next for Get Started', (tester) async {
      await _pumpOnboarding(tester);
      await _advanceToLastPage(tester);

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Skip is faded out and inert on the last page', (tester) async {
      await _pumpOnboarding(tester);
      await _advanceToLastPage(tester);

      final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Skip'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0.0);

      // Behavioural check: tapping the invisible Skip must do nothing at all.
      await tester.tap(find.text('Skip'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text(_homeMarker), findsNothing);
      expect(find.text('Secure Storage'), findsOneWidget);
    });

    testWidgets('Skip navigates straight to home', (tester) async {
      await _pumpOnboarding(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text(_homeMarker), findsOneWidget);
    });

    testWidgets('Get Started navigates to home', (tester) async {
      await _pumpOnboarding(tester);
      await _advanceToLastPage(tester);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text(_homeMarker), findsOneWidget);
    });

    testWidgets('swiping the PageView updates the indicator', (tester) async {
      await _pumpOnboarding(tester);

      expect(
        tester.widget<OnboardingDotIndicator>(
          find.byType(OnboardingDotIndicator),
        ).activeIndex,
        0,
      );

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(
        tester.widget<OnboardingDotIndicator>(
          find.byType(OnboardingDotIndicator),
        ).activeIndex,
        1,
      );
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpOnboarding(tester, theme: AppTheme.darkTheme);

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });

  group('OnboardingScreen layout resilience', () {
    testWidgets('no overflow on a small phone at 3x text scale',
        (tester) async {
      await _pumpOnboarding(
        tester,
        textScale: 3.0,
        logicalSize: const Size(320, 568),
      );

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in landscape', (tester) async {
      await _pumpOnboarding(
        tester,
        logicalSize: const Size(844, 390),
      );

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in landscape at 2x text scale', (tester) async {
      await _pumpOnboarding(
        tester,
        textScale: 2.0,
        logicalSize: const Size(844, 390),
      );

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives an orientation change', (tester) async {
      await _pumpOnboarding(tester);
      expect(find.text('Hybrid Search'), findsOneWidget);

      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpAndSettle();

      expect(find.text('Hybrid Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingScreen persistence', () {
    testWidgets('Get Started records completion before navigating',
        (tester) async {
      await _pumpOnboarding(tester);
      await _advanceToLastPage(tester);

      expect(store.complete, isFalse);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(store.markCallCount, 1);
      expect(store.complete, isTrue);
      expect(find.text(_homeMarker), findsOneWidget);
    });

    testWidgets('Skip records completion before navigating', (tester) async {
      await _pumpOnboarding(tester);

      expect(store.complete, isFalse);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(store.markCallCount, 1);
      expect(store.complete, isTrue);
      expect(find.text(_homeMarker), findsOneWidget);
    });

    testWidgets('advancing pages does not record completion', (tester) async {
      await _pumpOnboarding(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(store.markCallCount, 0);
      expect(store.complete, isFalse);
    });

    testWidgets('still navigates when the store throws', (tester) async {
      await GetIt.instance.reset();
      GetIt.instance.registerSingleton<OnboardingStore>(
        ThrowingOnboardingStore(),
      );

      await _pumpOnboarding(tester);
      await _advanceToLastPage(tester);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // A misbehaving store must never trap the user on onboarding.
      expect(find.text(_homeMarker), findsOneWidget);
    });
  });

  group('OnboardingScreen accessibility', () {
    testWidgets('primary button semantics follow the Next to Get Started swap',
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpOnboarding(tester);

      expect(find.bySemanticsLabel('Next'), findsOneWidget);
      expect(find.bySemanticsLabel('Get Started'), findsNothing);

      await _advanceToLastPage(tester);

      expect(find.bySemanticsLabel('Get Started'), findsOneWidget);
      expect(find.bySemanticsLabel('Next'), findsNothing);

      final SemanticsNode node =
          tester.getSemantics(find.byType(FilledButton));
      expect(
        node.label,
        'Get Started',
        reason: 'AnimatedSwitcher must republish the new label',
      );

      handle.dispose();
    });

    testWidgets('hidden Skip leaves the semantics tree on the last page',
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpOnboarding(tester);

      expect(_semanticsTreeHasLabel(tester, 'Skip'), isTrue);

      await _advanceToLastPage(tester);

      expect(
        _semanticsTreeHasLabel(tester, 'Skip'),
        isFalse,
        reason: 'a screen reader must not reach the invisible Skip button',
      );

      handle.dispose();
    });

    testWidgets('hidden Skip drops out of focus traversal', (tester) async {
      await _pumpOnboarding(tester);
      final int withSkip = _traversableFocusCount(tester);

      await _advanceToLastPage(tester);
      final int withoutSkip = _traversableFocusCount(tester);

      expect(
        withoutSkip,
        withSkip - 1,
        reason: 'the invisible Skip button must not be keyboard reachable',
      );
    });

    testWidgets('the page indicator announces position', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpOnboarding(tester);

      expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);

      handle.dispose();
    });
  });
}

/// Number of focus nodes the user could actually reach by keyboard.
int _traversableFocusCount(WidgetTester tester) => tester
    .binding.focusManager.rootScope.traversalDescendants
    .where((FocusNode node) => node.canRequestFocus)
    .length;

/// Whether the *rendered* semantics tree contains a node labelled [label].
///
/// Walks the real tree the platform hands to TalkBack/VoiceOver rather than
/// inspecting widgets, so ancestor exclusions are honoured.
bool _semanticsTreeHasLabel(WidgetTester tester, String label) {
  SemanticsNode? root;
  void findOwner(PipelineOwner owner) {
    root ??= owner.semanticsOwner?.rootSemanticsNode;
    owner.visitChildren(findOwner);
  }

  findOwner(tester.binding.rootPipelineOwner);
  if (root == null) return false;

  bool found = false;
  void visit(SemanticsNode node) {
    if (node.label.contains(label)) {
      found = true;
      return;
    }
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return !found;
    });
  }

  visit(root!);
  return found;
}
