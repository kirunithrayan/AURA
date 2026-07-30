import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/theme/app_colors.dart';
import '../../domain/entities/reading_preferences.dart';
import '../../domain/entities/viewer_preferences.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import '../../data/datasources/viewer_preferences_local_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ViewerSettingsSheet extends ConsumerStatefulWidget {

  const ViewerSettingsSheet({
    super.key,
    required this.fileId,
    required this.initialPrefs,
  });
  final String fileId;
  final ReadingPreferences initialPrefs;

  @override
  ConsumerState<ViewerSettingsSheet> createState() => _ViewerSettingsSheetState();
}

class _ViewerSettingsSheetState extends ConsumerState<ViewerSettingsSheet> {
  late ReadingPreferences _prefs;
  ViewerPreferences _viewerPrefs = const ViewerPreferences();
  late ViewerPreferencesLocalDataSource _viewerPrefsDataSource;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initialPrefs;
    _viewerPrefsDataSource = ViewerPreferencesLocalDataSource(const FlutterSecureStorage());
    _loadViewerPrefs();
  }

  Future<void> _loadViewerPrefs() async {
    final prefs = await _viewerPrefsDataSource.getPreferences();
    if (mounted) {
      setState(() {
        _viewerPrefs = prefs;
        _isLoading = false;
      });
    }
  }

  void _updateReadingPrefs(ReadingPreferences newPrefs) {
    setState(() {
      _prefs = newPrefs;
    });
    ref.read(documentViewerViewModelProvider(widget.fileId).notifier).updateReadingPreferences(newPrefs);
  }

  void _updateViewerPrefs(ViewerPreferences newPrefs) async {
    setState(() {
      _viewerPrefs = newPrefs;
    });
    await _viewerPrefsDataSource.savePreferences(newPrefs);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            const Text('Reading Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Font Size'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateReadingPrefs(_prefs.copyWith(fontSize: (_prefs.fontSize - 1).clamp(10.0, 32.0))),
                    ),
                    Text('${_prefs.fontSize.toInt()}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateReadingPrefs(_prefs.copyWith(fontSize: (_prefs.fontSize + 1).clamp(10.0, 32.0))),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Line Spacing'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateReadingPrefs(_prefs.copyWith(lineSpacing: (_prefs.lineSpacing - 0.1).clamp(1.0, 3.0))),
                    ),
                    Text(_prefs.lineSpacing.toStringAsFixed(1)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateReadingPrefs(_prefs.copyWith(lineSpacing: (_prefs.lineSpacing + 0.1).clamp(1.0, 3.0))),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Reading Theme'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReadingTheme.values.map((theme) => ChoiceChip(
                  label: Text(theme.name),
                  selected: _prefs.readingTheme == theme,
                  onSelected: (selected) {
                    if (selected) {
                      _updateReadingPrefs(_prefs.copyWith(readingTheme: theme));
                    }
                  },
                )).toList(),
            ),

            const SizedBox(height: 24),
            const Text('Viewer Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            
            SwitchListTile(
              title: const Text('Keep Screen Awake'),
              value: _viewerPrefs.keepScreenAwake,
              onChanged: (val) => _updateViewerPrefs(_viewerPrefs.copyWith(keepScreenAwake: val)),
            ),
            SwitchListTile(
              title: const Text('Restore Last Position'),
              value: _viewerPrefs.restoreLastPosition,
              onChanged: (val) => _updateViewerPrefs(_viewerPrefs.copyWith(restoreLastPosition: val)),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
