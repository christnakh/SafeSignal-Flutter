import 'package:equatable/equatable.dart';

class AdminModel extends Equatable {
  final int? adminId;
  final String username;
  final String password;

  const AdminModel({
    this.adminId,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [adminId, username, password];

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json['admin_id'] as int?,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'username': username,
      'password': password,
    };
  }

  AdminModel copyWith({
    int? adminId,
    String? username,
    String? password,
  }) {
    return AdminModel(
      adminId: adminId ?? this.adminId,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
