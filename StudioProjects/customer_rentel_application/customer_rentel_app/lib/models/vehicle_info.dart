class VehicleInfo {
  final int? id;
  final String? name;
  final String? plate;
  final String? color;
  final String? make;
  final String? model;

  const VehicleInfo({
    this.id,
    this.name,
    this.plate,
    this.color,
    this.make,
    this.model,
  });

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    final parts = [make, model].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? 'Assigned vehicle' : parts.join(' ');
  }

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
    id: _int(json['id']),
    name: _s(json['name']) ?? _s(json['vehicle_name']),
    plate: _s(json['plate']) ?? _s(json['license_plate']),
    color: _s(json['color']),
    make: _s(json['make']),
    model: _s(json['model']),
  );
}

String? _s(dynamic value) => value == null ? null : '$value';

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
