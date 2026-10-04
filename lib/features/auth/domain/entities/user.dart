enum UserRole {
  supervisor('SUPERVISOR'),
  contractor('CONTRACTOR');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) {
    final normalized = value.toUpperCase().replaceFirst('ROLE_', '');
    return normalized == 'CONTRACTOR'
        ? UserRole.contractor
        : UserRole.supervisor;
  }
}

class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.createdAt,
    this.profilePicture,
  });

  final int id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? phone;
  final DateTime? createdAt;
  final String? profilePicture;

  bool get isSupervisor => role == UserRole.supervisor;
  bool get isContractor => role == UserRole.contractor;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role.apiValue,
    'phone': phone,
    'createdAt': createdAt?.toIso8601String(),
    'profilePicture': profilePicture,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num).toInt(),
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: UserRole.fromApi(json['role']?.toString() ?? ''),
    phone: json['phone']?.toString(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    profilePicture: json['profilePicture']?.toString(),
  );
}
