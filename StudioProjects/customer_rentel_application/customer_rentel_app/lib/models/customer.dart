class Customer {
  final int id;
  final String name;
  final String email;
  final String? phone;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  Customer copyWith({int? id, String? name, String? email, String? phone}) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: _int(json['id']) ?? 0,
    name: _s(json['name']) ?? '',
    email: _s(json['email']) ?? '',
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
