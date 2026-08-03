import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/services/onboarding_store.dart';
import '../models/onboarding_page_data.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_page_content.dart';

/// First-run carousel introducing AURA's implemented capabilities.
///
/// Self-contained: it owns its own page state and depends on nothing beyond
/// the router and the static copy in [OnboardingContent].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Minimum height for interactive controls, per accessibility guidance.
  static const double _minTouchTargetHeight = 48.0;
  static const double _primaryButtonHeight = 52.0;

  final PageController _pageController = PageController();
  final OnboardingStore _onboardingStore = sl<OnboardingStore>();

  int _currentPage = 0;

  bool get _isLastPage => _currentPage == OnboardingContent.pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) =>
      setState(() => _currentPage = index);

  void _goToNextPage() => _pageController.nextPage(
        duration: UiConstants.animNormal,
        curve: Curves.easeInOut,
      );

  /// Shared exit path for both Skip and Get Started: record completion, then
  /// leave. The write is awaited so the flag is durable before we navigate,
  /// and it never throws, so navigation cannot be blocked by storage failure.
  Future<void> _completeOnboarding() async {
    try {
      await _onboardingStore.markOnboardingComplete();
    } catch (_) {
      // OnboardingStore is contracted never to throw, but leaving the user
      // stuck on onboarding is a far worse outcome than a lost flag, so the
      // exit path does not depend on that contract holding.
    }

    if (!mounted) return;
    context.goNamed(AppRoutes.home);
  }

  Future<void> _handlePrimaryAction() async {
    if (_isLastPage) {
      await _completeOnboarding();
    } else {
      _goToNextPage();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildSkipRow(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _handlePageChanged,
                  itemCount: OnboardingContent.pages.length,
                  itemBuilder: (context, index) => OnboardingPageContent(
                    data: OnboardingContent.pages[index],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      );

  /// Skip stays in the tree on the last page so the layout does not shift.
  /// While hidden it must be inert in every input modality: invisible
  /// (opacity), untappable (IgnorePointer), unreachable by keyboard or switch
  /// control (ExcludeFocus) and unseen by screen readers (ExcludeSemantics).
  /// IgnorePointer alone does not remove a widget from focus traversal.
  Widget _buildSkipRow() => Padding(
        padding: AppSpacing.edgeInsetsAll8,
        child: Align(
          alignment: Alignment.centerRight,
          child: ExcludeFocus(
            excluding: _isLastPage,
            child: ExcludeSemantics(
              excluding: _isLastPage,
              child: AnimatedOpacity(
                duration: UiConstants.animFast,
                opacity: _isLastPage ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: _isLastPage,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        _minTouchTargetHeight * 1.5,
                        _minTouchTargetHeight,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildFooter() => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingDotIndicator(
              count: OnboardingContent.pages.length,
              activeIndex: _currentPage,
            ),
            AppSpacing.v24,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handlePrimaryAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(_primaryButtonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UiConstants.radiusMedium),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: UiConstants.animFast,
                  child: Text(
                    _isLastPage ? 'Get Started' : 'Next',
                    key: ValueKey<bool>(_isLastPage),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
