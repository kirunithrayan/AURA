import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility to debounce rapidly firing events (e.g., search input typing).
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Executes [action] only if no other call is made within the [delay] period.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
  }
}
