class UserModel {
  final int id;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isSuperuser;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.isActive = true,
    this.isSuperuser = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isSuperuser: json['is_superuser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'is_superuser': isSuperuser,
    };
  }
}

