import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/driver.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

const _sampleDriver = Driver(
  id: 42,
  name: 'Marcus Reed',
  email: 'marcus@princelimousine.test',
  phone: '+1 212 555 0142',
  status: 'online',
  isOnline: true,
);

class AuthState {
  final AuthStatus status;
  final Driver? driver;
  final bool busy;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.driver,
    this.busy = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    Driver? driver,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        driver: driver ?? this.driver,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  /// Static test mode: boot straight into the app with a sample driver.
  Future<void> bootstrap() async {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      driver: _sampleDriver,
    );
  }

  Future<bool> login(String email, String password, {String? deviceName}) async {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      driver: _sampleDriver,
      busy: false,
      clearError: true,
    );
    return true;
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Called by the API client when any request returns 401.
  void onSessionExpired() {
    if (state.status != AuthStatus.unauthenticated) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());
