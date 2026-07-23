import 'package:flutter/material.dart';

/// Extension methods for [BuildContext] to simplify access to theme and media query data.
extension ContextExtensions on BuildContext {
  /// Quick access to the [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Quick access to the [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Quick access to the [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Quick access to [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Quick access to screen size.
  Size get screenSize => mediaQuery.size;

  /// Shows a standard SnackBar with the given message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: isError ? colorScheme.onError : colorScheme.onInverseSurface),
          ),
          backgroundColor: isError ? colorScheme.error : colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }
}
