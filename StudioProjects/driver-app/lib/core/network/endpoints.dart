/// Driver API paths, relative to `AppConfig.driverApi`
/// (`<API_BASE_URL>/api/v1/driver`). Mirrors routes/api.php exactly.
abstract class Endpoints {
  static const login = '/login';
  static const me = '/me';
  static const logout = '/logout';

  static const bookings = '/bookings';
  static String booking(Object id) => '/bookings/$id';
  static String accept(Object id) => '/bookings/$id/accept';
  static String decline(Object id) => '/bookings/$id/decline';
  static String status(Object id) => '/bookings/$id/status';

  static const location = '/location';
}
