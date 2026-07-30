import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to AURA'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.home),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
}
