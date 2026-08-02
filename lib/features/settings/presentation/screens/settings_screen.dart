import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../ai/rag/domain/services/ai_key_store.dart';
import '../widgets/ai_key_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AiKeyStore _keyStore = sl<AiKeyStore>();
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _refreshKeyStatus();
  }

  Future<void> _refreshKeyStatus() async {
    final has = await _keyStore.hasApiKey();
    if (mounted) setState(() => _hasApiKey = has);
  }

  Future<void> _openKeyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AiKeyDialog(keyStore: _keyStore),
    );
    await _refreshKeyStatus();
  }

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
                          'Version 0.6.0 • Local storage, cloud AI',
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
            subtitle: Text('Encrypted SQLite (SQLCipher)'),
            trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('AI Engine Configuration'),
            subtitle: Text(
              _hasApiKey
                  ? 'Google Gemini • API key configured'
                  : 'Google Gemini • no API key set — Ask AURA is disabled',
            ),
            trailing: Icon(
              _hasApiKey ? Icons.check_circle : Icons.error_outline,
              color: _hasApiKey ? Colors.green : theme.colorScheme.error,
              size: 20,
            ),
            onTap: _openKeyDialog,
          ),
          const ListTile(
            leading: Icon(Icons.cloud_outlined),
            title: Text('Data Handling'),
            subtitle: Text(
              'Documents and search stay on device. Ask AURA sends the '
              'selected excerpts to Google Gemini.',
            ),
            isThreeLine: true,
          ),
          const Divider(),
          AppSpacing.v16,

          // Developer Options Section
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
            subtitle: Text('Clean Architecture • MVVM • Riverpod'),
          ),
        ],
      ),
    );
  }
}
