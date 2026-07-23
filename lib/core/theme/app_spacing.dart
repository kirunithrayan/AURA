import 'package:flutter/material.dart';

/// Centralized spacing definitions for consistent layouts.
class AppSpacing {
  AppSpacing._();

  // Padding & Margin values
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Spacing Widgets (SizedBox)
  static const SizedBox h4 = SizedBox(width: xs);
  static const SizedBox h8 = SizedBox(width: sm);
  static const SizedBox h16 = SizedBox(width: md);
  static const SizedBox h24 = SizedBox(width: lg);
  static const SizedBox h32 = SizedBox(width: xl);

  static const SizedBox v4 = SizedBox(height: xs);
  static const SizedBox v8 = SizedBox(height: sm);
  static const SizedBox v16 = SizedBox(height: md);
  static const SizedBox v24 = SizedBox(height: lg);
  static const SizedBox v32 = SizedBox(height: xl);
  static const SizedBox v48 = SizedBox(height: xxl);

  // Common Paddings
  static const EdgeInsets edgeInsetsAll8 = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAll16 = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAll24 = EdgeInsets.all(lg);
  
  static const EdgeInsets edgeInsetsH16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets edgeInsetsV16 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets edgeInsetsH16V8 = EdgeInsets.symmetric(horizontal: md, vertical: sm);
}
