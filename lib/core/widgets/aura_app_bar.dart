import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// A custom AppBar for AURA that applies consistent styling.
class AuraAppBar extends StatelessWidget implements PreferredSizeWidget {

  const AuraAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) => AppBar(
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
