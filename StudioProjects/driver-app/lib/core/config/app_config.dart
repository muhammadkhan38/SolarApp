/// Build-time configuration, provided via --dart-define so one codebase targets
/// local / staging / production without code edits.
///
/// Example:
///   flutter run \
///     --dart-define=API_BASE_URL=https://car-rental.kodeking.net \
///     --dart-define=GOOGLE_MAPS_API_KEY=xxxxxxxx
class AppConfig {
  /// Root of your Laravel app (APP_URL). The driver API lives under
  /// `<API_BASE_URL>/api/v1/driver`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://car-rental.kodeking.net/',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Full prefix for the driver API.
  static String get driverApi => '$_normalizedApiBaseUrl/api/v1/driver';

  static String get _normalizedApiBaseUrl =>
      apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  /// How often the app pushes a GPS ping while on an active trip.
  static const Duration locationPingInterval = Duration(seconds: 8);

  /// How often trip lists / details refresh (no websockets — REST polling).
  static const Duration pollInterval = Duration(seconds: 15);
}
