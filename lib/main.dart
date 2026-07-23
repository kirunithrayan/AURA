import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

void main() async {
  // Ensure Flutter engine is initialized before async setup
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection (GetIt)
  await initInjection();

  // Run app wrapped in Riverpod's ProviderScope
  runApp(
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}
