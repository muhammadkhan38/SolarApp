import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/endpoints.dart';
import '../core/storage/token_storage.dart';
import '../models/customer.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final Customer? customer;
  final bool busy;
  final String? error;
  final Map<String, List<String>> fieldErrors;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.customer,
    this.busy = false,
    this.error,
    this.fieldErrors = const {},
  });

  AuthState copyWith({
    AuthStatus? status,
    Customer? customer,
    bool? busy,
    String? error,
    Map<String, List<String>>? fieldErrors,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: clearError ? const {} : (fieldErrors ?? this.fieldErrors),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({TokenStorage? tokenStorage, ApiClient? api})
    : _tokenStorage = tokenStorage ?? TokenStorage(),
      super(const AuthState()) {
    _api = api ?? ApiClient(_tokenStorage);
  }

  final TokenStorage _tokenStorage;
  late final ApiClient _api;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.read();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final customer = await _fetchCustomer();
      state = AuthState(status: AuthStatus.authenticated, customer: customer);
    } catch (_) {
      await _tokenStorage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(
    String email,
    String password, {
    String? deviceName,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final response = await _api.post(
        Endpoints.login,
        data: {
          'email': email,
          'password': password,
          if (deviceName != null && deviceName.isNotEmpty)
            'device_name': deviceName,
        },
      );
      await _completeAuth(response);
      return true;
    } catch (error) {
      await _tokenStorage.clear();
      _setFailure(error, status: AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? deviceName,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final response = await _api.post(
        Endpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          if (deviceName != null && deviceName.isNotEmpty)
            'device_name': deviceName,
        },
      );
      await _completeAuth(response);
      return true;
    } catch (error) {
      await _tokenStorage.clear();
      _setFailure(error, status: AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final response = await _api.patch(
        Endpoints.me,
        data: {'name': name, 'phone': phone},
      );
      final customer = _customerJson(response) == null
          ? await _fetchCustomer()
          : _customerFromResponse(response);
      state = AuthState(status: AuthStatus.authenticated, customer: customer);
      return true;
    } catch (error) {
      _setFailure(error);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (await _tokenStorage.read() != null) {
        await _api.post(Endpoints.logout);
      }
    } catch (_) {
      // Local sign-out should still succeed if the network is unavailable.
    } finally {
      await _tokenStorage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void onSessionExpired() {
    unawaited(_tokenStorage.clear());
    if (state.status != AuthStatus.unauthenticated) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _completeAuth(dynamic response) async {
    final token = _tokenFromResponse(response);
    if (token == null || token.isEmpty) {
      throw ApiException('Login response did not include an API token.');
    }
    await _tokenStorage.save(token);
    final customer = _customerJson(response) == null
        ? await _fetchCustomer()
        : _customerFromResponse(response);
    state = AuthState(status: AuthStatus.authenticated, customer: customer);
  }

  Future<Customer> _fetchCustomer() async {
    final response = await _api.get(Endpoints.me);
    return _customerFromResponse(response);
  }

  void _setFailure(Object error, {AuthStatus? status}) {
    final apiError = error is ApiException ? error : ApiException('$error');
    state = AuthState(
      status: status ?? state.status,
      customer: state.customer,
      error: apiError.message,
      fieldErrors: apiError.errors,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

Customer _customerFromResponse(dynamic response) {
  final json = _customerJson(response);
  if (json == null) {
    throw ApiException('Invalid customer response from the server.');
  }
  return Customer.fromJson(json);
}

Map<String, dynamic>? _customerJson(dynamic value) {
  if (value is! Map) return null;
  final map = _stringMap(value);
  if (map.containsKey('id') &&
      (map.containsKey('email') || map.containsKey('name'))) {
    return map;
  }
  for (final key in const ['customer', 'data', 'user']) {
    final customer = _customerJson(map[key]);
    if (customer != null) return customer;
  }
  return null;
}

String? _tokenFromResponse(dynamic value) {
  if (value is! Map) return null;
  final map = _stringMap(value);
  for (final key in const [
    'token',
    'access_token',
    'plain_text_token',
    'api_token',
  ]) {
    final token = map[key];
    if (token != null) return '$token';
  }
  for (final key in const ['data', 'auth']) {
    final token = _tokenFromResponse(map[key]);
    if (token != null) return token;
  }
  return null;
}

Map<String, dynamic> _stringMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) => MapEntry('$key', value));
}
