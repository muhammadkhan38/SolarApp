class Contact {
  final String? name;
  final String? phone;
  final String? email;

  const Contact({this.name, this.phone, this.email});

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    name: _s(json['name']),
    phone: _s(json['phone']),
    email: _s(json['email']),
  );
}

String? _s(dynamic value) => value == null ? null : '$value';
