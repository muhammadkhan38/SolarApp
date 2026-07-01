/// Build-time configuration supplied with --dart-define.
///
/// Example:
///   flutter run \
///     --dart-define=API_BASE_URL=https://car-rental.kodeking.net \
///     --dart-define=GOOGLE_MAPS_API_KEY=xxxxxxxx
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://car-rental.kodeking.net/',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static String get customerApi => '$_normalizedApiBaseUrl/api/v1/customer';

  static String get _normalizedApiBaseUrl =>
      apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  /// Same polling cadence as the driver app: REST refreshes, no websockets.
  static const Duration pollInterval = Duration(seconds: 15);

  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+1-800-555-0199',
  );
}
