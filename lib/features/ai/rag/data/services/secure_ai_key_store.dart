import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/services/ai_key_store.dart';

/// [AiKeyStore] backed by platform secure storage (Keystore on Android).
class SecureAiKeyStore implements AiKeyStore {
  SecureAiKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyGeminiApiKey = 'ai_gemini_api_key';

  @override
  Future<String?> readApiKey() async {
    final value = await _storage.read(key: _keyGeminiApiKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      await clearApiKey();
      return;
    }
    await _storage.write(key: _keyGeminiApiKey, value: trimmed);
  }

  @override
  Future<void> clearApiKey() => _storage.delete(key: _keyGeminiApiKey);

  @override
  Future<bool> hasApiKey() async => (await readApiKey()) != null;
}
