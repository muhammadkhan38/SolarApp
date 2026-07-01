import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:customer_rentel_app/core/network/api_client.dart';
import 'package:customer_rentel_app/core/network/api_exception.dart';
import 'package:customer_rentel_app/core/storage/token_storage.dart';
import 'package:customer_rentel_app/models/booking.dart';
import 'package:customer_rentel_app/models/booking_status.dart';
import 'package:customer_rentel_app/providers/auth_provider.dart';
import 'package:customer_rentel_app/providers/bookings_provider.dart';

void main() {
  group('customer auth API flow', () {
    late _TestApiServer server;
    late _FakeTokenStorage storage;

    setUp(() async {
      server = await _TestApiServer.start();
      storage = _FakeTokenStorage();
    });

    tearDown(() async {
      await server.close();
    });

    AuthController controller({void Function()? onUnauthorized}) {
      final api = ApiClient(
        storage,
        baseUrl: server.baseUrl,
        onUnauthorized: onUnauthorized,
      );
      return AuthController(tokenStorage: storage, api: api);
    }

    test('bootstrap restores a saved Sanctum token via /me', () async {
      storage.token = 'saved-token';
      String? authHeader;
      server.on('GET', '/api/v1/customer/me', (request) {
        authHeader = request.headers.value(HttpHeaders.authorizationHeader);
        _json(request, {
          'customer': {
            'id': 7,
            'name': 'Ava Customer',
            'email': 'ava@example.com',
            'phone': '+15555550111',
          },
        });
      });

      final auth = controller();
      await auth.bootstrap();

      expect(authHeader, 'Bearer saved-token');
      expect(auth.state.status, AuthStatus.authenticated);
      expect(auth.state.customer?.name, 'Ava Customer');
    });

    test('bootstrap without token routes to unauthenticated', () async {
      final auth = controller();
      await auth.bootstrap();

      expect(auth.state.status, AuthStatus.unauthenticated);
      expect(auth.state.customer, isNull);
    });

    test('login stores token and logout clears it', () async {
      Map<String, dynamic>? loginBody;
      String? logoutAuth;
      server.on('POST', '/api/v1/customer/login', (request) async {
        loginBody = await _jsonBody(request);
        _json(request, {
          'token': 'fresh-token',
          'customer': {
            'id': 8,
            'name': 'Nora Black',
            'email': 'nora@example.com',
            'phone': '+15555550222',
          },
        });
      });
      server.on('POST', '/api/v1/customer/logout', (request) {
        logoutAuth = request.headers.value(HttpHeaders.authorizationHeader);
        _json(request, {'ok': true});
      });

      final auth = controller();
      final ok = await auth.login(
        'nora@example.com',
        'password',
        deviceName: 'test device',
      );

      expect(ok, isTrue);
      expect(loginBody?['email'], 'nora@example.com');
      expect(loginBody?['device_name'], 'test device');
      expect(storage.token, 'fresh-token');
      expect(auth.state.status, AuthStatus.authenticated);

      await auth.logout();

      expect(logoutAuth, 'Bearer fresh-token');
      expect(storage.token, isNull);
      expect(auth.state.status, AuthStatus.unauthenticated);
    });
  });

  group('customer bookings API flow', () {
    late _TestApiServer server;
    late _FakeTokenStorage storage;
    late BookingsRepository repository;

    setUp(() async {
      server = await _TestApiServer.start();
      storage = _FakeTokenStorage()..token = 'booking-token';
      repository = BookingsRepository(
        ApiClient(storage, baseUrl: server.baseUrl),
      );
    });

    tearDown(() async {
      await server.close();
    });

    test('lists bookings from Laravel resource wrappers', () async {
      server.on('GET', '/api/v1/customer/bookings', (request) {
        _json(request, {
          'data': [
            _bookingJson(id: 1, reference: 'PL-1', status: 'completed'),
            _bookingJson(
              id: 2,
              reference: 'PL-2',
              status: 'confirmed',
              pickupAt: '2026-07-02T20:30:00Z',
            ),
          ],
        });
      });

      final bookings = await repository.list();

      expect(bookings, hasLength(2));
      expect(bookings.first.reference, 'PL-2');
      expect(bookings.last.status, BookingStatus.completed);
    });

    test('creates booking, reads detail, and cancels booking', () async {
      Map<String, dynamic>? createBody;
      server.on('POST', '/api/v1/customer/bookings', (request) async {
        createBody = await _jsonBody(request);
        _json(request, {
          'booking': _bookingJson(
            id: 7,
            reference: 'PL-7',
            status: 'confirmed',
          ),
        });
      });
      server.on('GET', '/api/v1/customer/bookings/7', (request) {
        _json(request, {
          'data': {
            ..._bookingJson(id: 7, reference: 'PL-7', status: 'assigned'),
            'pickup_lat': 40.6413,
            'pickup_lng': -73.7781,
            'driver': {'name': 'Marcus Reed', 'phone': '+15555550123'},
            'vehicle': {'name': 'Cadillac Escalade', 'plate': 'A2Z-777'},
          },
        });
      });
      server.on('POST', '/api/v1/customer/bookings/7/cancel', (request) {
        _json(request, {
          'booking': _bookingJson(
            id: 7,
            reference: 'PL-7',
            status: 'cancelled',
          ),
        });
      });

      final draft = BookingDraft(
        pickupLocation: 'JFK Terminal 4',
        dropoffLocation: 'The Plaza Hotel',
        pickupAt: DateTime.utc(2026, 7, 1, 20, 30),
        vehicleClass: 'suv',
        contactPhone: '+15555550123',
      );

      final created = await repository.create(draft);
      final detail = await repository.get(created.id);
      final cancelled = await repository.cancel(created.id);

      expect(createBody?['pickup_location'], 'JFK Terminal 4');
      expect(created.reference, 'PL-7');
      expect(detail.hasPickupCoords, isTrue);
      expect(detail.driver?.name, 'Marcus Reed');
      expect(detail.vehicle?.plate, 'A2Z-777');
      expect(cancelled.status, BookingStatus.cancelled);
    });

    test('401 clears token and notifies auth layer', () async {
      var unauthorized = false;
      repository = BookingsRepository(
        ApiClient(
          storage,
          baseUrl: server.baseUrl,
          onUnauthorized: () => unauthorized = true,
        ),
      );
      server.on('GET', '/api/v1/customer/bookings', (request) {
        _json(request, {'message': 'Unauthenticated.'}, statusCode: 401);
      });

      await expectLater(repository.list(), throwsA(isA<ApiException>()));

      expect(storage.token, isNull);
      expect(storage.clearCount, 1);
      expect(unauthorized, isTrue);
    });
  });
}

Map<String, dynamic> _bookingJson({
  required int id,
  required String reference,
  required String status,
  String pickupAt = '2026-07-01T20:30:00Z',
}) {
  return {
    'id': id,
    'reference': reference,
    'status': status,
    'pickup_location': 'JFK Terminal 4',
    'dropoff_location': 'The Plaza Hotel',
    'pickup_at': pickupAt,
    'vehicle_class': 'suv',
    'total': 185,
  };
}

Future<Map<String, dynamic>> _jsonBody(HttpRequest request) async {
  final raw = await utf8.decoder.bind(request).join();
  if (raw.isEmpty) return {};
  return (jsonDecode(raw) as Map).cast<String, dynamic>();
}

void _json(HttpRequest request, Object body, {int statusCode = HttpStatus.ok}) {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body))
    ..close();
}

class _FakeTokenStorage extends TokenStorage {
  String? token;
  int clearCount = 0;

  @override
  Future<void> save(String token) async {
    this.token = token;
  }

  @override
  Future<String?> read() async => token;

  @override
  Future<void> clear() async {
    clearCount++;
    token = null;
  }
}

typedef _Handler = FutureOr<void> Function(HttpRequest request);

class _TestApiServer {
  _TestApiServer._();

  late final HttpServer _server;
  final _handlers = <String, _Handler>{};

  String get baseUrl =>
      'http://${_server.address.address}:${_server.port}/api/v1/customer';

  static Future<_TestApiServer> start() async {
    final api = _TestApiServer._();
    api._server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    api._server.listen(api._handle);
    return api;
  }

  void on(String method, String path, _Handler handler) {
    _handlers['$method $path'] = handler;
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final key = '${request.method} ${request.uri.path}';
    final handler = _handlers[key];
    if (handler == null) {
      _json(request, {
        'message': 'No test handler for $key',
      }, statusCode: HttpStatus.notFound);
      return;
    }
    await handler(request);
  }
}
