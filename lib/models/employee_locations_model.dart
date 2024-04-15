import 'package:equatable/equatable.dart';

class EmployeeLocationModel extends Equatable {
  final int? locationId;
  final int? employeeId;
  final String longitude;
  final String latitude;
  final DateTime? lastUpdated;

  const EmployeeLocationModel({
    this.locationId,
    this.employeeId,
    required this.longitude,
    required this.latitude,
    this.lastUpdated,
  });

  @override
  List<Object?> get props =>
      [locationId, employeeId, longitude, latitude, lastUpdated];

  factory EmployeeLocationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLocationModel(
      locationId: json['location_id'] as int?,
      employeeId: json['employee_id'] as int?,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'employee_id': employeeId,
      'longitude': longitude,
      'latitude': latitude,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  EmployeeLocationModel copyWith({
    int? locationId,
    int? userId,
    int? employeeId,
    String? longitude,
    String? latitude,
    DateTime? lastUpdated,
  }) {
    return EmployeeLocationModel(
      locationId: locationId ?? this.locationId,
      employeeId: employeeId ?? this.employeeId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
