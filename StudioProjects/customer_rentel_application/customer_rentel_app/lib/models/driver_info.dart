class DriverInfo {
  final int? id;
  final String? name;
  final String? phone;

  const DriverInfo({this.id, this.name, this.phone});

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
    id: _int(json['id']),
    name: _s(json['name']),
    phone: _s(json['phone']),
  );
}

String? _s(dynamic value) => value == null ? null : '$value';

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
