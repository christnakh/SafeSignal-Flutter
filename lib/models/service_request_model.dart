import 'package:equatable/equatable.dart';

enum ServiceType {
  moto,
  tow,
  mechanic,
  refuel,
}

enum ServiceStatus {
  pending,
  accept,
  done,
}

class ServiceRequestModel extends Equatable {
  final int? requestId;
  final int? userId;
  final DateTime? requestTime;
  final ServiceType? serviceType;
  final String? details;
  final ServiceStatus status;
  final String? estimatedArrivalTime;
  final int? employeeId;

  const ServiceRequestModel({
    this.requestId,
    this.userId,
    this.requestTime,
    this.serviceType,
    this.details,
    this.status = ServiceStatus.pending,
    this.estimatedArrivalTime,
    this.employeeId,
  });

  @override
  List<Object?> get props => [
        requestId,
        userId,
        requestTime,
        serviceType,
        details,
        status,
        estimatedArrivalTime,
        employeeId,
      ];

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    print(json);

    return ServiceRequestModel(
      requestId: json['request_id'] as int?,
      userId: json['user_id'] as int?,
      requestTime: json['request_time'] == null
          ? null
          : DateTime.parse(json['request_time'] as String),
      serviceType: json['service_type'] as ServiceType?,
      details: json['details'] as String?,
      status: json['status'] as ServiceStatus? ?? ServiceStatus.pending,
      estimatedArrivalTime: json['estimated_arrival_time'] as String?,
      employeeId: json['employee_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'request_time': requestTime?.toIso8601String(),
      'service_type': serviceType,
      'details': details,
      'status': status,
      'estimated_arrival_time': estimatedArrivalTime,
      'employee_id': employeeId,
    };
  }

  ServiceRequestModel copyWith({
    int? requestId,
    int? userId,
    DateTime? requestTime,
    ServiceType? serviceType,
    String? details,
    ServiceStatus? status,
    String? estimatedArrivalTime,
    int? employeeId,
  }) {
    return ServiceRequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      requestTime: requestTime ?? this.requestTime,
      serviceType: serviceType ?? this.serviceType,
      details: details ?? this.details,
      status: status ?? this.status,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      employeeId: employeeId ?? this.employeeId,
    );
  }
}
