import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/trips/trips_list_screen.dart';
import '../../features/trips/trip_detail_screen.dart';
import '../../features/profile/profile_screen.dart';

abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const trips = '/trips';
  static const profile = '/profile';
  static String trip(Object id) => '/trips/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider.select((s) => s.status), (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }
      final atLogin = loc == Routes.login;
      if (status == AuthStatus.unauthenticated) {
        return atLogin ? null : Routes.login;
      }
      // Authenticated
      if (loc == Routes.splash || atLogin) return Routes.trips;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.trips, builder: (_, __) => const TripsListScreen()),
      GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/trips/:id',
        builder: (_, s) =>
            TripDetailScreen(bookingId: int.parse(s.pathParameters['id']!)),
      ),
    ],
  );
});
