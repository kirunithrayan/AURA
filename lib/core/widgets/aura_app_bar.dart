import 'package:flutter/material.dart';
import '../design_system/design_tokens.dart';
import '../extensions/context_extensions.dart';

/// App-bar placement variants.
///
/// The Design System names three: [root] (a top-level destination), [nested]
/// (a pushed screen with a back affordance), and [contextual] (a transient
/// state such as multi-select). Per-variant behavior beyond the shared contract
/// is not yet specified; all three currently render the shared left-aligned,
/// shadowless bar.
enum AuraAppBarVariant { root, nested, contextual }

/// A custom AppBar for AURA that applies consistent Design System styling.
class AuraAppBar extends StatelessWidget implements PreferredSizeWidget {

  const AuraAppBar({
    super.key,
    required this.title,
    this.variant = AuraAppBarVariant.root,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });
  final String title;
  final AuraAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;

  /// LEGACY: ignored. AURA app bars are always left-aligned.
  @Deprecated(
    'Design System app bars are always left-aligned; this value is ignored. '
    'Kept for source compatibility; scheduled for removal in a later step.',
  )
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget>? currentActions = actions;
    // Design System §2.8: at most three actions. Debug-only signal (stripped
    // from release builds, never throws in production).
    assert(
      currentActions == null || currentActions.length <= 3,
      'AuraAppBar allows at most three actions (Design System §2.8).',
    );
    return AppBar(
      title: Text(
        title,
        // Design System §4.2 AppBar: title in the interface title-large tier.
        style: AuraTypography.titleLg.copyWith(
          color: context.tokens.colors.contentPrimary,
        ),
      ),
      centerTitle: false,
      titleSpacing: AuraSpacing.groupGap,
      actions: currentActions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AuraLayout.appBarHeight);
}
