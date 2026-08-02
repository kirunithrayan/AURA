/// Stores the user-supplied API key for cloud AI providers.
///
/// The key is entered by the user at runtime and held in platform secure
/// storage. It is deliberately *not* compiled into the binary, so a released
/// APK never ships a credential.
abstract class AiKeyStore {
  /// Returns the stored API key, or `null` if the user has not set one.
  Future<String?> readApiKey();

  /// Persists [apiKey] to secure storage.
  Future<void> saveApiKey(String apiKey);

  /// Removes any stored API key.
  Future<void> clearApiKey();

  /// Whether a non-empty key is currently stored.
  Future<bool> hasApiKey();
}
