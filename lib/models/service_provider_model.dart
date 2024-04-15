import 'package:equatable/equatable.dart';

enum ServiceProviderRoleEnum {
  moto(1),
  fuelDelivery(2),
  towTruck(3),
  mechanic(4);

  const ServiceProviderRoleEnum(this.value);
  final int value;
}

class ServiceProviderModel extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String password;
  final int role;

  const ServiceProviderModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, password, role];

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['provider_id'] as int?,
      name: json['provider_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': id,
      'provider_name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  ServiceProviderModel copyWith({
    int? providerId,
    String? providerName,
    String? email,
    String? password,
    int? role,
  }) {
    return ServiceProviderModel(
      id: providerId ?? id,
      name: providerName ?? name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
