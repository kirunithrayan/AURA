import 'package:flutter/material.dart';
import 'core/theme/app_spacing.dart';
import 'core/constants/ui_constants.dart';
import 'core/widgets/glass_container.dart';
import 'core/widgets/aura_card.dart';

/// A placeholder screen specifically designed to preview the AURA theme system.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AURA Theme Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Typography (Inter)', style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
            const Divider(),
            AppSpacing.v8,
            Text('Display Large', style: textTheme.displayLarge),
            Text('Headline Medium', style: textTheme.headlineMedium),
            Text('Title Large', style: textTheme.titleLarge),
            Text('Body Medium', style: textTheme.bodyMedium),
            Text('Label Small', style: textTheme.labelSmall),
            
            AppSpacing.v24,
            Text('Colors', style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
            const Divider(),
            AppSpacing.v8,
            Wrap(
              spacing: UiConstants.gridSpacing,
              runSpacing: UiConstants.gridSpacing,
              children: [
                _ColorBox(color: colorScheme.primary, name: 'Primary', textColor: colorScheme.onPrimary),
                _ColorBox(color: colorScheme.secondary, name: 'Secondary', textColor: colorScheme.onSecondary),
                _ColorBox(color: colorScheme.tertiary, name: 'Tertiary', textColor: colorScheme.onTertiary),
                _ColorBox(color: colorScheme.error, name: 'Error', textColor: colorScheme.onError),
                _ColorBox(color: colorScheme.surface, name: 'Surface', textColor: colorScheme.onSurface),
                _ColorBox(color: colorScheme.surfaceContainerHighest, name: 'Surface Container Highest', textColor: colorScheme.onSurfaceVariant),
              ],
            ),

            AppSpacing.v24,
            Text('Components & Elevation', style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
            const Divider(),
            AppSpacing.v8,
            const AuraCard(
              elevation: UiConstants.elevationHigh,
              child: Text('High Elevation Card (Radius Medium)'),
            ),
            AppSpacing.v16,
            const AuraCard(
              elevation: UiConstants.elevationLow,
              child: Text('Low Elevation Card (Radius Medium)'),
            ),
            
            AppSpacing.v24,
            Text('Glassmorphism', style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
            const Divider(),
            AppSpacing.v8,
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                  ),
                ),
                GlassContainer(
                  padding: AppSpacing.edgeInsetsAll24,
                  child: Text(
                    'Glassmorphism Effect',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            AppSpacing.v24,
            Text('Buttons', style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary)),
            const Divider(),
            AppSpacing.v8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              ],
            ),
            AppSpacing.v24,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {

  const _ColorBox({
    required this.color,
    required this.name,
    required this.textColor,
  });
  final Color color;
  final String name;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: UiConstants.elevationLow,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
}
