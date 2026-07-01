/// Customer API paths, relative to `AppConfig.customerApi`
/// (`<API_BASE_URL>/api/v1/customer`).
///
/// The Laravel backend was not present in this workspace. These paths mirror the
/// driver app style and define the customer contract the backend should expose.
abstract class Endpoints {
  static const login = '/login';
  static const register = '/register';
  static const me = '/me';
  static const logout = '/logout';

  static const bookings = '/bookings';
  static String booking(Object id) => '/bookings/$id';
  static String cancelBooking(Object id) => '/bookings/$id/cancel';
  static const priceEstimate = '/bookings/estimate';
}
