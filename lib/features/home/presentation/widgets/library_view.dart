import 'package:flutter/material.dart';

import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_course_grid_section.dart';
import '../../../../core/widgets/aura_empty_state.dart';
import '../../../../core/widgets/aura_icon_button.dart';
import '../../../../core/widgets/aura_recent_section.dart';
import '../../../../core/widgets/aura_section_header.dart';

/// The Library screen's presentation, with no data dependencies.
///
/// Kept free of providers so it can be rendered deterministically in golden
/// tests; [LibraryScreen] supplies the data.
///
/// Composition (Direction B): app bar, then Courses, then Recent.
///
/// Continue Reading is intentionally absent. The Design System places it first
/// as the Library's primary element, but it requires durable per-document
/// reading-position persistence, which does not exist: `lastViewedPage` and
/// `lastScrollPosition` are present in the schema but nothing ever writes them.
/// The migration blueprint's §7.4 fallback is explicit — "Step 6 ships with
/// Continue omitted and the section restored later" — so the section is
/// deferred until that persistence exists rather than faked here.
class LibraryView extends StatelessWidget {
  const LibraryView({
    super.key,
    required this.courses,
    required this.recentDocuments,
    this.onCreateCourse,
    this.onOpenSearch,
    this.onOpenSettings,
    this.onRefresh,
  });

  final List<AuraCourseData> courses;
  final List<AuraRecentDocumentData> recentDocuments;
  final VoidCallback? onCreateCourse;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenSettings;
  final Future<void> Function()? onRefresh;

  /// Direction B specifies a 24dp Library screen margin. `AuraSpacing.groupGap`
  /// is the committed 24dp value; the 20dp `AuraSpacing.screenMargin` token is
  /// deliberately left untouched, so this stays a screen-level decision.
  static const double _libraryMargin = AuraSpacing.groupGap;

  @override
  Widget build(BuildContext context) {
    final Future<void> Function()? refresh = onRefresh;
    final bool isEmpty = courses.isEmpty && recentDocuments.isEmpty;

    final Widget body = isEmpty
        // Kept scrollable so pull-to-refresh still works with no content.
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const AuraEmptyState(
                  title: 'Your library is empty',
                  message: 'Create a course to start adding documents.',
                ),
              ),
            ),
          )
        : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(_libraryMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (courses.isNotEmpty)
                  AuraCourseGridSection(
                    header: const AuraSectionHeader(title: 'Courses'),
                    courses: courses,
                  ),
                if (courses.isNotEmpty && recentDocuments.isNotEmpty)
                  const SizedBox(height: AuraSpacing.sectionGap),
                if (recentDocuments.isNotEmpty)
                  AuraRecentSection(
                    header: const AuraSectionHeader(title: 'Recent'),
                    documents: recentDocuments,
                  ),
              ],
            ),
          );

    return Scaffold(
      appBar: AuraAppBar(
        title: 'Library',
        // TEMPORARY COMPATIBILITY EXCEPTION (approved 2026-08-10, Step 6).
        //
        // Direction B does NOT authorise these Library app-bar actions; the
        // only app-bar mapping in the migration blueprint is
        // "ImportFab -> AuraIconButton in app bar", which belongs to the Course
        // screen. They are retained solely because this screen previously held
        // the only entry points to Search, Settings, and course creation, and
        // removing them would strand those routes.
        //
        // Routes, callbacks, and behavior are unchanged. This is functional
        // compatibility debt, to be revisited in Step 7, where Search and
        // Settings are formally migrated. Do not add further actions here.
        actions: <Widget>[
          AuraIconButton(
            icon: Icons.add,
            tooltip: 'New course',
            onPressed: onCreateCourse,
          ),
          AuraIconButton(
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: onOpenSearch,
          ),
          AuraIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: refresh == null
          ? body
          : RefreshIndicator(onRefresh: refresh, child: body),
    );
  }
}
