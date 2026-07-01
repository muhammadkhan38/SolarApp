import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Dio client for the Laravel driver API (Sanctum bearer tokens).
///
/// - Attaches `Authorization: Bearer <token>` and `Accept: application/json`.
/// - On a 401 it clears the stored token (Sanctum tokens don't refresh), which
///   the router observes to send the driver back to login.
/// - Wraps failures in [ApiException].
class ApiClient {
  ApiClient(this._tokenStorage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.driverApi,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains(Endpoints401.login)) {
            await _tokenStorage.clear();
            onUnauthorized?.call();
          }
          handler.next(e);
        },
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final void Function()? onUnauthorized;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _wrap(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _wrap(() => _dio.post(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) =>
      _wrap(() => _dio.patch(path, data: data));

  Future<dynamic> delete(String path) => _wrap(() => _dio.delete(path));

  Future<dynamic> _wrap(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Tiny constant holder to avoid importing endpoints just for the login guard.
abstract class Endpoints401 {
  static const login = '/login';
}
