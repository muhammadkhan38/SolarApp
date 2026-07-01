import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Permissions + GPS access for the live location ping.
class LocationService {
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    // SDK 35 requires explicit handling of denied permissions to avoid loops or crashes.
    if (permission == LocationPermission.deniedForever) return false;

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> current() async {
    if (!await ensurePermission()) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Continuous stream while on a trip (moves of ≥ [distanceFilter] metres).
  /// Uses AndroidSettings for foreground service stability on SDK 34+.
  Stream<Position> watch({int distanceFilter = 20}) {
    final appleSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    );

    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 10),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Tracking trip location in background",
        notificationTitle: "Prince Driver Active",
        enableWakeLock: true,
      ),
    );

    return Geolocator.getPositionStream(
      locationSettings: (defaultTargetPlatform == TargetPlatform.android)
          ? androidSettings
          : appleSettings,
    );
  }
}
