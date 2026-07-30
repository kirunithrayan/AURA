import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// A wrapper widget to animate list items as they enter the screen.
class AnimatedListItem extends StatelessWidget {

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: UiConstants.animNormal,
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) => Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: MergeSemantics(child: childWidget),
          ),
        ),
      child: child,
    );
}
