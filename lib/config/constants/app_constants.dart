/// Environment-level configuration.
///
/// Values are supplied at build time so a release build never carries a
/// developer's machine address:
///
///   flutter run --dart-define=BASE_URL=https://api.example.com/api \
///               --dart-define=SOCKET_URL=https://api.example.com
///
/// The defaults point at the deployed backend, so a plain `flutter run` works
/// on a physical device without any extra flags. Point them at a local server
/// only when you have one running and the device shares its network — the
/// Android emulator reaches the host as `10.0.2.2`, never `localhost`.
class AppConstants {
  const AppConstants._();

  /// Backend origin **including the `/api/v1` prefix**, matching
  /// `FLUTTER_API_SPEC.md` ("Base URL: {HOST}/api/v1"). Repository paths are
  /// therefore written without the version, e.g. `/food/restaurant/current`.
  /// Keep the version here and nowhere else — splitting it across the base and
  /// the call sites is how paths end up with a doubled or missing segment.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://quick.appzeto.com/api/v1',
  );

  /// Socket.IO origin. Deployed behind the same host as the API; a local setup
  /// may run it as a separate process on 5001 (`SOCKET_PORT`), which is why it
  /// is configured independently of [baseUrl].
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://quick.appzeto.com',
  );

  /// Origin used to resolve relative media paths.
  ///
  /// The backend's upload service deliberately refuses to persist absolute
  /// localhost URLs, so `url` in an upload response is usually a relative
  /// `/uploads/...` path. [resolveMediaUrl] turns it back into something the
  /// image loader can fetch.
  static String get mediaOrigin {
    final uri = Uri.parse(baseUrl);
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.port).toString();
  }

  /// Absolute URL for a possibly-relative media path returned by the backend.
  /// Returns an empty string for empty input so callers can branch on `isEmpty`
  /// rather than juggling nulls.
  static String resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$mediaOrigin${url.startsWith('/') ? '' : '/'}$url';
  }
}
