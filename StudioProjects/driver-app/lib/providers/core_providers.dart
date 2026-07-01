import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/services/location_service.dart';
import '../core/storage/token_storage.dart';
import 'auth_provider.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(tokenStorageProvider),
    // A 401 anywhere drops the session; the router then routes to login.
    onUnauthorized: () => ref.read(authControllerProvider.notifier).onSessionExpired(),
  );
});

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
