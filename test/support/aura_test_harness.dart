import 'package:aura/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reusable widget/golden testing harness for the AURA UI migration.
///
/// Wraps a widget under test in the real production theme (which carries the
/// `AuraTokens` extension) with deterministic rendering parameters: fixed
/// device size, pixel ratio, locale, and text scale. Every future
/// presentation-layer test should build on these helpers rather than
/// hand-rolling its own `MaterialApp`.
///
/// Reuses [AppTheme]; introduces no test-only theme and no third-party package.

/// Reference device for golden tests (logical pixels): the spec's 393 x 852.
const Size kAuraGoldenSize = Size(393, 852);

/// Fixed device pixel ratio for deterministic golden capture.
const double kAuraGoldenPixelRatio = 1;

/// Fixed locale so text and formatting never vary by host environment.
const Locale kAuraTestLocale = Locale('en', 'US');

/// Wraps [child] in the production theme with a fixed locale and text scale.
///
/// Does NOT load fonts, so existing widget tests can adopt this without any
/// change to their text metrics. Font loading is scoped to the golden harness.
Widget wrapForTest(
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
}) {
  final ThemeData theme =
      brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: kAuraTestLocale,
    supportedLocales: const <Locale>[kAuraTestLocale],
    theme: theme,
    builder: (BuildContext context, Widget? built) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: built!,
    ),
    home: child,
  );
}

/// Pumps [child] for a standard (non-golden) widget test.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
}) =>
    tester.pumpWidget(
      wrapForTest(child, brightness: brightness, textScale: textScale),
    );

/// Pumps [child] with a fixed surface size and pixel ratio for golden capture,
/// restoring the view afterwards so tests stay isolated.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = kAuraGoldenSize,
  double pixelRatio = kAuraGoldenPixelRatio,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(size.width * pixelRatio, size.height * pixelRatio);
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    wrapForTest(child, brightness: brightness, textScale: textScale),
  );
  await tester.pumpAndSettle();
}
