import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/viewer_preferences.dart';

class ViewerPreferencesLocalDataSource {

  ViewerPreferencesLocalDataSource(this._storage);
  final FlutterSecureStorage _storage;
  
  static const _keyKeepAwake = 'pref_keep_awake';
  static const _keyRestorePos = 'pref_restore_pos';

  Future<ViewerPreferences> getPreferences() async {
    final awakeStr = await _storage.read(key: _keyKeepAwake);
    final restoreStr = await _storage.read(key: _keyRestorePos);

    return ViewerPreferences(
      keepScreenAwake: awakeStr == null ? true : awakeStr == 'true',
      restoreLastPosition: restoreStr == null ? true : restoreStr == 'true',
    );
  }

  Future<void> savePreferences(ViewerPreferences prefs) async {
    await _storage.write(key: _keyKeepAwake, value: prefs.keepScreenAwake.toString());
    await _storage.write(key: _keyRestorePos, value: prefs.restoreLastPosition.toString());
  }
}
