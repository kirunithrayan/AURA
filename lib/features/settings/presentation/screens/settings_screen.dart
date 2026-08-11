import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/aura_app_bar.dart';
import '../../../../core/widgets/aura_section_header.dart';
import '../../../ai/rag/domain/services/ai_key_store.dart';
import '../widgets/ai_key_dialog.dart';

/// Settings, migrated 1:1 to design tokens in Step 7.
///
/// Every section and row is preserved; nothing was added or removed. The Gemini
/// API-key flow and its dialog are unchanged.
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
    final AuraColors colors = context.tokens.colors;

    return Scaffold(
      appBar: const AuraAppBar(
        variant: AuraAppBarVariant.nested,
        title: 'Settings',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpacing.screenMargin),
        children: [
          // Header Card
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AuraRadius.md),
              border: Border.all(
                color: colors.borderDefault,
                width: AuraBorders.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AuraSpacing.componentPadding),
              child: Row(
                children: [
                  Container(
                    width: AuraSpacing.s48,
                    height: AuraSpacing.s48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.actionSubtle,
                      borderRadius: BorderRadius.circular(AuraRadius.md),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: AuraIconTokens.sizeMd,
                      color: colors.actionPrimary,
                    ),
                  ),
                  const SizedBox(width: AuraSpacing.componentPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AURA Workspace',
                          style: AuraTypography.titleSm.copyWith(
                            color: colors.contentPrimary,
                          ),
                        ),
                        Text(
                          'Version 0.6.0 • Local storage, cloud AI',
                          style: AuraTypography.caption.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AuraSpacing.sectionGap),

          // General Settings
          const AuraSectionHeader(title: 'General'),
          const SizedBox(height: AuraSpacing.gapTight),
          _SettingsRow(
            icon: Icons.storage_outlined,
            title: 'Local Repository Storage',
            subtitle: 'Encrypted SQLite (SQLCipher)',
            trailing: Icon(
              Icons.check_circle,
              color: colors.statusSuccess,
              size: AuraIconTokens.sizeSm,
            ),
          ),
          _SettingsRow(
            icon: Icons.psychology_outlined,
            title: 'AI Engine Configuration',
            subtitle: _hasApiKey
                ? 'Google Gemini • API key configured'
                : 'Google Gemini • no API key set — Ask AURA is disabled',
            trailing: Icon(
              _hasApiKey ? Icons.check_circle : Icons.error_outline,
              color: _hasApiKey ? colors.statusSuccess : colors.statusError,
              size: AuraIconTokens.sizeSm,
            ),
            onTap: _openKeyDialog,
          ),
          const _SettingsRow(
            icon: Icons.cloud_outlined,
            title: 'Data Handling',
            subtitle:
                'Documents and search stay on device. Ask AURA sends the '
                'selected excerpts to Google Gemini.',
          ),
          const SizedBox(height: AuraSpacing.sectionGap),

          // Developer Options Section
          const AuraSectionHeader(title: 'Developer Options'),
          const SizedBox(height: AuraSpacing.gapTight),
          _SettingsRow(
            icon: Icons.developer_board,
            title: 'Performance Diagnostics',
            subtitle: 'Inspect index counts, search latency & cache metrics',
            trailing: Icon(
              Icons.chevron_right,
              color: colors.contentTertiary,
              size: AuraIconTokens.sizeSm,
            ),
            onTap: () => context.pushNamed(AppRoutes.diagnostics),
          ),
          _SettingsRow(
            icon: Icons.security,
            title: 'Database Encryption Status',
            subtitle: 'SQLCipher AES-256 Key Initialized',
            trailing: Icon(
              Icons.lock,
              color: colors.statusSuccess,
              size: AuraIconTokens.sizeSm,
            ),
          ),
          const SizedBox(height: AuraSpacing.sectionGap),

          // About Section
          const AuraSectionHeader(title: 'About'),
          const SizedBox(height: AuraSpacing.gapTight),
          const _SettingsRow(
            icon: Icons.info_outline,
            title: 'AURA Architecture',
            subtitle: 'Clean Architecture • MVVM • Riverpod',
          ),
        ],
      ),
    );
  }
}

/// A single settings row. Grows with the text scale rather than clipping.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AuraColors colors = context.tokens.colors;
    final Widget? trailingWidget = trailing;

    final Widget row = Container(
      constraints: const BoxConstraints(minHeight: AuraLayout.touchTargetMin),
      padding: const EdgeInsets.symmetric(vertical: AuraSpacing.componentGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: AuraIconTokens.sizeMd, color: colors.contentSecondary),
          const SizedBox(width: AuraSpacing.componentPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AuraTypography.body.copyWith(color: colors.contentPrimary),
                ),
                const SizedBox(height: AuraSpacing.gapMicro),
                Text(
                  subtitle,
                  style: AuraTypography.caption
                      .copyWith(color: colors.contentSecondary),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) ...<Widget>[
            const SizedBox(width: AuraSpacing.componentGap),
            Padding(
              padding: const EdgeInsets.only(top: AuraSpacing.gapMicro),
              child: trailingWidget,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(child: row),
      ),
    );
  }
}
