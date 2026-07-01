# Prince Limousine Customer App

Flutter customer app for Prince Limousine / A2Z Black Car. It mirrors the driver
app architecture: Riverpod, go_router, Dio, Laravel Sanctum bearer tokens,
secure token storage, Google Maps, and 15 second REST polling.

## Run

```bash
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=https://car-rental.kodeking.net \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_RESTRICTED_ANDROID_MAPS_KEY
```

The app calls `<API_BASE_URL>/api/v1/customer/*`. Override `API_BASE_URL` for
local Laravel development. Android emulators reach host localhost at
`http://10.0.2.2:8000`.

## Customer API Contract

The Laravel backend source was not present in this checkout, so the customer app
targets a matching contract under `/api/v1/customer`:

- `POST /login`
- `POST /register`
- `GET /me`
- `PATCH /me`
- `POST /logout`
- `GET /bookings`
- `POST /bookings`
- `POST /bookings/estimate`
- `GET /bookings/{id}`
- `POST /bookings/{id}/cancel`

Responses may be direct objects or Laravel resource wrappers (`data`,
`booking`, `bookings`, `customer`). Auth accepts token keys used by Sanctum-style
APIs: `token`, `access_token`, `plain_text_token`, or `api_token`.

## Maps

Android reads `GOOGLE_MAPS_API_KEY` from `--dart-define`, Gradle properties,
environment variables, or `android/local.properties`.

For Flutter Web, copy `web/maps_config.example.js` to `web/maps_config.js` and
set `window.GOOGLE_MAPS_API_KEY`, or append `?googleMapsApiKey=YOUR_KEY` while
testing locally.

iOS reads `GoogleMapsApiKey` from `Info.plist` via the `GOOGLE_MAPS_API_KEY`
build setting. Keep real keys outside source control.
