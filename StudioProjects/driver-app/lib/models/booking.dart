import 'booking_status.dart';

class Contact {
  final String? name;
  final String? phone;
  const Contact({this.name, this.phone});

  factory Contact.fromJson(Map<String, dynamic> j) =>
      Contact(name: j['name'] as String?, phone: j['phone'] as String?);
}

class VehicleInfo {
  final String? name;
  final String? plate;
  const VehicleInfo({this.name, this.plate});

  factory VehicleInfo.fromJson(Map<String, dynamic> j) =>
      VehicleInfo(name: j['name'] as String?, plate: j['plate'] as String?);
}

/// A driver's trip. List responses include the base fields; `GET /bookings/{id}`
/// adds the detail fields (coordinates, hours, total, notes, customer, vehicle).
class Booking {
  final int id;
  final String reference;
  final BookingStatus status;
  final String? vehicleClass;
  final String pickupLocation;
  final String? dropoffLocation;
  final DateTime? pickupAt;
  final List<String> allowedTransitions;

  // Detail-only fields:
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final num? hours;
  final num? total;
  final String? notes;
  final Contact? customer;
  final VehicleInfo? vehicle;

  const Booking({
    required this.id,
    required this.reference,
    required this.status,
    this.vehicleClass,
    required this.pickupLocation,
    this.dropoffLocation,
    this.pickupAt,
    this.allowedTransitions = const [],
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.hours,
    this.total,
    this.notes,
    this.customer,
    this.vehicle,
  });

  Booking copyWith({
    int? id,
    String? reference,
    BookingStatus? status,
    String? vehicleClass,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupAt,
    List<String>? allowedTransitions,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    num? hours,
    num? total,
    String? notes,
    Contact? customer,
    VehicleInfo? vehicle,
  }) =>
      Booking(
        id: id ?? this.id,
        reference: reference ?? this.reference,
        status: status ?? this.status,
        vehicleClass: vehicleClass ?? this.vehicleClass,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
        pickupAt: pickupAt ?? this.pickupAt,
        allowedTransitions: allowedTransitions ?? this.allowedTransitions,
        pickupLat: pickupLat ?? this.pickupLat,
        pickupLng: pickupLng ?? this.pickupLng,
        dropoffLat: dropoffLat ?? this.dropoffLat,
        dropoffLng: dropoffLng ?? this.dropoffLng,
        hours: hours ?? this.hours,
        total: total ?? this.total,
        notes: notes ?? this.notes,
        customer: customer ?? this.customer,
        vehicle: vehicle ?? this.vehicle,
      );

  bool get hasPickupCoords => pickupLat != null && pickupLng != null;
  bool get hasDropoffCoords => dropoffLat != null && dropoffLng != null;

  /// Can the driver advance to the next non-decline status from here?
  bool get canAdvance =>
      allowedTransitions.any((t) => t != 'declined' && t != 'en_route') ||
      (status == BookingStatus.enRoute);

  /// The next status to PATCH to (skips accept/decline which have own endpoints).
  String? get nextStatus {
    const order = ['arrived', 'in_progress', 'completed'];
    for (final s in order) {
      if (allowedTransitions.contains(s)) return s;
    }
    return null;
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: (json['id'] as num).toInt(),
        reference: json['reference'] as String? ?? '',
        status: BookingStatus.fromApi(json['status'] as String?),
        vehicleClass: json['vehicle_class'] as String?,
        pickupLocation: json['pickup_location'] as String? ?? '',
        dropoffLocation: json['dropoff_location'] as String?,
        pickupAt: _date(json['pickup_at']),
        allowedTransitions:
            (json['allowed_transitions'] as List?)?.map((e) => '$e').toList() ??
                const [],
        pickupLat: _d(json['pickup_lat']),
        pickupLng: _d(json['pickup_lng']),
        dropoffLat: _d(json['dropoff_lat']),
        dropoffLng: _d(json['dropoff_lng']),
        hours: json['hours'] as num?,
        total: json['total'] as num?,
        notes: json['notes'] as String?,
        customer: json['customer'] is Map
            ? Contact.fromJson((json['customer'] as Map).cast<String, dynamic>())
            : null,
        vehicle: json['vehicle'] is Map
            ? VehicleInfo.fromJson((json['vehicle'] as Map).cast<String, dynamic>())
            : null,
      );

  static double? _d(dynamic v) => v == null ? null : (v as num).toDouble();
  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;
}
