# Prince Limousine — Driver App (Flutter)

Native Android & iOS app for limousine drivers. It consumes the Laravel driver
API (`/api/v1/driver/*`, Sanctum auth) already in this repo. Drivers sign in, see
their assigned trips, accept/decline, advance the trip through its lifecycle, and
stream live GPS to the admin Live Map.

> Customer booking (website + Vapi voice agent) and the admin dashboard are the
> Laravel web side. This Flutter app is **drivers only**, matching
> `docs/driver-app-api.md` and `routes/api.php`.

## What it does

- **Sanctum login** — `POST /login` → bearer token stored securely; auto-restores
  the session on launch; a 401 anywhere signs the driver out.
- **My trips** — `GET /bookings`, active trips soonest-first, pull-to-refresh and
  background polling (no websockets — REST, every 15s).
- **Trip detail** — `GET /bookings/{id}`: map (pickup/drop-off), customer call
  button, vehicle, hours, total, notes, and the status actions allowed *right now*
  (driven by each booking's `allowed_transitions`).
- **Lifecycle** — Accept (`/accept`), Decline (`/decline`, back to dispatch), and
  advance `en_route → arrived → in_progress → completed` (`PATCH /status`).
- **Live GPS** — while a trip is active, `POST /location` every 8s feeds
  `drivers.last_lat/lng` (the admin Live Map).

## Prerequisites

- Flutter 3.19+
- The Laravel API running and reachable from the device/emulator
- A Google Maps API key (Maps SDK Android + iOS)
- Seeded driver logins (password `password`): `marcus@`, `devon@`,
  `ava@princelimousine.test`

## First-time setup

```bash
cd driver-app
flutter create .        # generates android/ ios/ (keeps lib/, pubspec)
flutter pub get
```

## Run

```bash
flutter run \
  --dart-define=API_BASE_URL=https://car-rental.kodeking.net \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_MAPS_KEY
```

- `API_BASE_URL` is your Laravel `APP_URL`; the production default is
  `https://car-rental.kodeking.net`, and the app appends `/api/v1/driver`.
- This test build currently uses static in-memory auth and booking data, so
  `flutter run` opens directly into sample trips without the Laravel API.
- For local development, override `API_BASE_URL`. `10.0.2.2` = host localhost
  from the **Android emulator**; iOS simulator can use `http://localhost:8000`;
  a physical device needs your machine's LAN IP and the phone on the same
  network. For `php artisan serve`, bind to your LAN:
  `php artisan serve --host=0.0.0.0 --port=8000`.

## Platform configuration

### Android — `android/app/src/main/AndroidManifest.xml`
Inside `<application>`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```
Above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
Set `minSdkVersion 21`+ in `android/app/build.gradle`. For HTTP during local dev,
allow cleartext (`android:usesCleartextTraffic="true"`) or use HTTPS.

### iOS — `ios/Runner/AppDelegate.swift`
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```
`ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Shares your live location with dispatch during active trips.</string>
```

## Project layout

```
lib/
  core/
    config/app_config.dart      base URL, poll/ping intervals (dart-define)
    theme/app_theme.dart        black-car dark + gold theme
    storage/token_storage.dart  secure Sanctum token
    network/                    api_client (Sanctum), endpoints, api_exception
    services/location_service.dart
    router/app_router.dart
  models/                       driver, booking, booking_status
  providers/                    core, auth, bookings (Riverpod)
  features/
    auth/                       splash, login
    trips/                      trips_list, trip_detail (map + GPS + actions)
    profile/                    profile + logout
    shared/                     status_badge, async_value_view
```

## Endpoint → screen map

| Screen | Calls |
|---|---|
| Login | `POST /login` |
| Splash/bootstrap | `GET /me` |
| Trips list | `GET /bookings` (polled) |
| Trip detail | `GET /bookings/{id}` (polled), `POST /accept`, `POST /decline`, `PATCH /status`, `POST /location` |
| Profile | `POST /logout` |

All endpoint paths live in `lib/core/network/endpoints.dart` — change them in one
place if your routes move.

## Not in this app (no API yet / out of scope)

Online/offline toggle, push notifications, in-SUV item sales, and payments are not
in the driver API yet (`docs/driver-app-api.md` §4). Seams are easy to add when the
backend exposes them.
