import 'package:equatable/equatable.dart';

enum LoginType {
  user,
  admin,
  provider,
}

class User extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as int?,
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id ?? 0,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, phone, email, password];
}
