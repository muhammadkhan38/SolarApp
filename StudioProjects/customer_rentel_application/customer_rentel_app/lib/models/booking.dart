import 'booking_status.dart';
import 'contact.dart';
import 'driver_info.dart';
import 'vehicle_info.dart';

class Booking {
  final int id;
  final String reference;
  final BookingStatus status;
  final String? vehicleClass;
  final String pickupLocation;
  final String? dropoffLocation;
  final DateTime? pickupAt;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? driverLat;
  final double? driverLng;
  final num? hours;
  final int? passengerCount;
  final num? total;
  final String? notes;
  final String? contactPhone;
  final Contact? customerContact;
  final DriverInfo? driver;
  final VehicleInfo? vehicle;
  final List<String> allowedActions;

  const Booking({
    required this.id,
    required this.reference,
    required this.status,
    this.vehicleClass,
    required this.pickupLocation,
    this.dropoffLocation,
    this.pickupAt,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.driverLat,
    this.driverLng,
    this.hours,
    this.passengerCount,
    this.total,
    this.notes,
    this.contactPhone,
    this.customerContact,
    this.driver,
    this.vehicle,
    this.allowedActions = const [],
  });

  bool get hasPickupCoords => pickupLat != null && pickupLng != null;
  bool get hasDropoffCoords => dropoffLat != null && dropoffLng != null;
  bool get hasDriverCoords => driverLat != null && driverLng != null;

  bool get canCancel {
    if (allowedActions.contains('cancel')) return true;
    return status == BookingStatus.confirmed ||
        status == BookingStatus.assigned;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final driverLocation = _map(json['driver_location']);
    return Booking(
      id: _int(json['id']) ?? 0,
      reference: _s(json['reference']) ?? _s(json['booking_reference']) ?? '',
      status: BookingStatus.fromApi(_s(json['status'])),
      vehicleClass:
          _s(json['vehicle_class']) ??
          _s(json['service_class']) ??
          _s(json['class']),
      pickupLocation:
          _s(json['pickup_location']) ??
          _s(json['pickup_address']) ??
          _s(json['pickup']) ??
          '',
      dropoffLocation:
          _s(json['dropoff_location']) ??
          _s(json['drop_off_location']) ??
          _s(json['dropoff_address']) ??
          _s(json['dropoff']) ??
          _s(json['drop_off']),
      pickupAt:
          _date(json['pickup_at']) ??
          _date(json['pickup_time']) ??
          _date(json['starts_at']),
      pickupLat: _d(json['pickup_lat']) ?? _d(json['pickup_latitude']),
      pickupLng:
          _d(json['pickup_lng']) ??
          _d(json['pickup_lon']) ??
          _d(json['pickup_longitude']),
      dropoffLat:
          _d(json['dropoff_lat']) ??
          _d(json['drop_off_lat']) ??
          _d(json['dropoff_latitude']),
      dropoffLng:
          _d(json['dropoff_lng']) ??
          _d(json['dropoff_lon']) ??
          _d(json['drop_off_lng']) ??
          _d(json['dropoff_longitude']),
      driverLat: _d(json['driver_lat']) ?? _d(driverLocation?['lat']),
      driverLng:
          _d(json['driver_lng']) ??
          _d(json['driver_lon']) ??
          _d(driverLocation?['lng']),
      hours: _n(json['hours']),
      passengerCount: _int(json['passenger_count']) ?? _int(json['passengers']),
      total:
          _n(json['total']) ??
          _n(json['total_amount']) ??
          _n(json['price']) ??
          _n(json['estimated_total']),
      notes: _s(json['notes']) ?? _s(json['special_instructions']),
      contactPhone:
          _s(json['contact_phone']) ??
          _s(json['customer_phone']) ??
          _s(json['phone']),
      customerContact: _map(json['customer']) == null
          ? null
          : Contact.fromJson(_map(json['customer'])!),
      driver: _map(json['driver']) == null
          ? null
          : DriverInfo.fromJson(_map(json['driver'])!),
      vehicle: _map(json['vehicle']) == null
          ? null
          : VehicleInfo.fromJson(_map(json['vehicle'])!),
      allowedActions:
          (json['allowed_actions'] as List?)
              ?.map((action) => '$action')
              .toList() ??
          (json['allowed_transitions'] as List?)
              ?.map((action) => '$action')
              .toList() ??
          const [],
    );
  }
}

class BookingDraft {
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupAt;
  final String vehicleClass;
  final num? hours;
  final int? passengerCount;
  final String? notes;
  final String contactPhone;

  const BookingDraft({
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAt,
    required this.vehicleClass,
    required this.contactPhone,
    this.hours,
    this.passengerCount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'pickup_location': pickupLocation,
    'dropoff_location': dropoffLocation,
    'pickup_at': pickupAt.toUtc().toIso8601String(),
    'vehicle_class': vehicleClass,
    'contact_phone': contactPhone,
    if (hours != null) 'hours': hours,
    if (passengerCount != null) 'passenger_count': passengerCount,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };
}

class PriceEstimate {
  final num total;
  final String? currency;

  const PriceEstimate({required this.total, this.currency});

  factory PriceEstimate.fromJson(Map<String, dynamic> json) => PriceEstimate(
    total:
        _n(json['total']) ??
        _n(json['estimated_total']) ??
        _n(json['price']) ??
        0,
    currency: _s(json['currency']),
  );
}

String? _s(dynamic value) => value == null ? null : '$value';

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

num? _n(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse('$value');
}

double? _d(dynamic value) => _n(value)?.toDouble();

DateTime? _date(dynamic value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

Map<String, dynamic>? _map(dynamic value) {
  if (value is! Map) return null;
  return value.map((key, mapValue) => MapEntry('$key', mapValue));
}
