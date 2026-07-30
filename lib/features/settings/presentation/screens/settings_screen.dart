import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/aura_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AuraAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: AppSpacing.edgeInsetsAll16,
        children: [
          // Header Card
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: AppSpacing.edgeInsetsAll16,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  AppSpacing.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AURA Workspace',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Version 1.0.0 (RC1) • Local-First AI',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.v24,

          // General Settings
          Text(
            'General',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.v8,
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Local Repository Storage'),
            subtitle: Text('Encrypted SQLite & Vector Index'),
            trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('AI Engine Configuration'),
            subtitle: const Text('Gemini API + Local Stub Fallback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI Engine active in local hybrid mode.')),
              );
            },
          ),
          const Divider(),
          AppSpacing.v16,

          // Developer Options Section (Refinement #2)
          Text(
            'Developer Options',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.v8,
          ListTile(
            leading: const Icon(Icons.developer_board),
            title: const Text('Performance Diagnostics'),
            subtitle: const Text('Inspect index counts, search latency & cache metrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoutes.diagnostics),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Database Encryption Status'),
            subtitle: Text('SQLCipher AES-256 Key Initialized'),
            trailing: Icon(Icons.lock, color: Colors.green, size: 20),
          ),
          const Divider(),
          AppSpacing.v16,

          // About Section
          Text(
            'About',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.v8,
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('AURA Architecture'),
            subtitle: Text('Clean Architecture • MVVM • Riverpod • Local-First'),
          ),
        ],
      ),
    );
  }
}
