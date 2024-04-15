import 'package:equatable/equatable.dart';

class UserLocationModel extends Equatable {
  final int? locationId;
  final int? userId;
  final String? longitude;
  final String? latitude;
  final DateTime? lastUpdated;

  const UserLocationModel({
    this.locationId,
    this.userId,
    this.longitude,
    this.latitude,
    this.lastUpdated,
  });

  @override
  List<Object?> get props =>
      [locationId, userId, longitude, latitude, lastUpdated];

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      locationId: json['location_id'] as int?,
      userId: json['user_id'] as int?,
      longitude: json['longitude'] as String?,
      latitude: json['latitude'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'user_id': userId,
      'longitude': longitude,
      'latitude': latitude,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  UserLocationModel copyWith({
    int? locationId,
    int? userId,
    int? employeeId,
    String? longitude,
    String? latitude,
    DateTime? lastUpdated,
  }) {
    return UserLocationModel(
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
