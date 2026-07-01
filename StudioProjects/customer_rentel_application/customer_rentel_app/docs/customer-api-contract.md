# Customer API Contract

Base path: `<API_BASE_URL>/api/v1/customer`

This contract mirrors the existing driver API style because the Laravel backend
was not present in the local workspace.

## Authentication

- `POST /login` with `email`, `password`, optional `device_name`
- `POST /register` with `name`, `email`, `phone`, `password`, optional `device_name`
- `GET /me`
- `PATCH /me` with `name`, `phone`
- `POST /logout`

Auth responses should include a customer object and one of `token`,
`access_token`, `plain_text_token`, or `api_token`.

## Bookings

- `GET /bookings`
- `POST /bookings`
- `POST /bookings/estimate`
- `GET /bookings/{id}`
- `POST /bookings/{id}/cancel`

Booking fields consumed by Flutter:

- `id`
- `reference`
- `status`
- `pickup_location`
- `dropoff_location`
- `pickup_at`
- `vehicle_class`
- `hours`
- `passenger_count`
- `notes`
- `contact_phone`
- `total`
- `pickup_lat`, `pickup_lng`
- `dropoff_lat`, `dropoff_lng`
- `driver_lat`, `driver_lng` or `driver_location: { lat, lng }`
- `driver: { id, name, phone }`
- `vehicle: { id, name, plate, color, make, model }`
- `allowed_actions`, optionally including `cancel`

Statuses: `confirmed`, `assigned`, `en_route`, `arrived`, `in_progress`,
`completed`, `declined`, `cancelled`.
