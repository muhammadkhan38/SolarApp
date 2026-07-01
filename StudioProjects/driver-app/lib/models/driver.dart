/// The authenticated driver, as returned by `/login` and `/me`
/// (`{ "driver": { id, name, email, phone, status, is_online } }`).
class Driver {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final bool isOnline;

  const Driver({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.isOnline,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        status: json['status'] as String? ?? 'offline',
        isOnline: json['is_online'] as bool? ?? false,
      );
}
