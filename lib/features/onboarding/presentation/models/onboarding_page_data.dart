import 'package:flutter/material.dart';

/// Immutable description of a single onboarding page.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Decorative glyph shown above the title. Excluded from semantics.
  final IconData icon;

  /// Short feature name.
  final String title;

  /// One-sentence explanation of the feature.
  final String description;
}

/// Static onboarding copy.
///
/// Every entry below describes a capability that is **already implemented**
/// in AURA. Do not add pages for planned or scaffolded features.
class OnboardingContent {
  OnboardingContent._();

  static const List<OnboardingPageData> pages = <OnboardingPageData>[
    OnboardingPageData(
      icon: Icons.manage_search,
      title: 'Hybrid Search',
      description:
          'Quickly find documents using keyword search, metadata, and '
          'organized workspaces.',
    ),
    OnboardingPageData(
      icon: Icons.workspaces_outlined,
      title: 'Workspace Management',
      description:
          'Organize files into dedicated workspaces and access recent, '
          'pinned, and favorite documents with ease.',
    ),
    OnboardingPageData(
      icon: Icons.shield_outlined,
      title: 'Secure Storage',
      description:
          'Your documents and workspace information are stored securely to '
          'help protect your data.',
    ),
  ];
}
