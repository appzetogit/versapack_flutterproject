/// Build-time configuration — the single source of truth for hosts and keys on
/// the Dart side.
///
/// Values come from `config/keys.env`, which also feeds the Android manifest
/// placeholder and the iOS xcconfig, so a key is written down exactly once:
///
///   flutter run --dart-define-from-file=config/keys.env
///
/// Individual `--dart-define`s still override it for one-off runs.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.mapsApiKey,
    required this.environment,
    required this.enableNetworkLogs,
  });

  final String apiBaseUrl;

  /// Used by the Dart-side Google REST calls (Places autocomplete, place
  /// details, reverse geocoding). The native map SDKs read the same key from
  /// the manifest / Info.plist instead — they are configured before Dart runs.
  final String mapsApiKey;

  final String environment;
  final bool enableNetworkLogs;

  bool get isProduction => environment == 'production';

  /// False when the key is absent or still the template placeholder. Map
  /// features check this and degrade with an explanation rather than showing a
  /// blank grey tile.
  bool get hasMapsKey =>
      mapsApiKey.isNotEmpty && mapsApiKey != _mapsKeyPlaceholder;

  /// The shared hosted backend. Per `FLUTTER_API_SPEC.md` the base is
  /// `{HOST}/api/v1` and every route is written as `/food/...` on top of it —
  /// so the `/v1` segment belongs here, not in the paths.
  static const _defaultBaseUrl = 'https://quick.appzeto.com/api/v1';

  /// Kept in sync with `config/keys.example.env`.
  static const _mapsKeyPlaceholder = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  factory AppConfig.fromEnvironment() {
    const url = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    const mapsKey = String.fromEnvironment('MAPS_API_KEY');
    final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

    // A base URL missing the version segment 404s every single call, and does
    // it silently at runtime. Fail loudly in debug instead.
    assert(
      base.endsWith('/api/v1'),
      'API_BASE_URL must end with /api/v1 (got "$base"). '
      'Route paths are written as /food/... on top of it.',
    );

    return AppConfig(
      apiBaseUrl: base,
      mapsApiKey: mapsKey,
      environment: env,
      enableNetworkLogs: env != 'production',
    );
  }
}
