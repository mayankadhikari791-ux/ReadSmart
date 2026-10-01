/// Application-wide configuration and environment variable loader.
///
/// Sensitive credentials and API endpoints are injected at build/run time via
/// `--dart-define` or `--dart-define-from-file=.env`.
///
/// Example run command:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.readsmart.app --dart-define=API_KEY=your_key
/// ```
class AppConfig {
  /// Base URL for remote backend API services.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.readsmart.app/v1',
  );

  /// Authentication server endpoint.
  static const String authEndpoint = String.fromEnvironment(
    'AUTH_ENDPOINT',
    defaultValue: 'https://auth.readsmart.app',
  );

  /// Public API Key for client requests (non-sensitive identifier).
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'readsmart_public_client_key',
  );

  /// Environment name (development, staging, production).
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Default HTTP timeout in milliseconds.
  static const int requestTimeoutMs = int.fromEnvironment(
    'REQUEST_TIMEOUT_MS',
    defaultValue: 15000,
  );

  /// Cloud synchronization feature toggle.
  static const bool enableCloudSync = bool.fromEnvironment(
    'ENABLE_CLOUD_SYNC',
    defaultValue: true,
  );

  /// Offline caching duration in hours.
  static const int cacheDurationHours = int.fromEnvironment(
    'CACHE_DURATION_HOURS',
    defaultValue: 72,
  );

  /// Base URL for secure server-side dictionary proxy.
  static const String dictionaryProxyUrl = String.fromEnvironment(
    'DICTIONARY_PROXY_URL',
    defaultValue: 'https://api.readsmart.app/v1/dictionary',
  );

  /// Base URL for secure server-side translation proxy.
  static const String translationProxyUrl = String.fromEnvironment(
    'TRANSLATION_PROXY_URL',
    defaultValue: 'https://api.readsmart.app/v1/translate',
  );

  /// Private API key for dictionary/translation provider (injected at build/proxy level).
  /// Never hardcoded in client source code.
  static const String dictionaryApiKey = String.fromEnvironment(
    'DICTIONARY_API_KEY',
    defaultValue: '',
  );

  /// Whether to use the secure server-side proxy for dictionary/translation.
  static const bool useDictionaryProxy = bool.fromEnvironment(
    'USE_DICTIONARY_PROXY',
    defaultValue: false,
  );

  /// Helper getter to check if running in production.
  static bool get isProduction => environment == 'production';

  /// Helper getter to check if running in development.
  static bool get isDevelopment => environment == 'development';

  /// Returns timeout Duration.
  static Duration get requestTimeout =>
      const Duration(milliseconds: requestTimeoutMs);
}

