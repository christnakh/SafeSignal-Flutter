import 'package:equatable/equatable.dart';
import 'package:senior_proj/models/service_provider_model.dart';

enum ServiceStatus {
  pending,
  accept,
  done,
}

class ServiceRequestModel extends Equatable {
  final int? requestId;
  final int? userId;
  final DateTime? requestTime;
  final ServiceProviderRoleEnum? serviceType;
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
    return ServiceRequestModel(
      requestId: json['request_id'] as int?,
      userId: json['user_id'] as int?,
      requestTime: json['request_time'] == null
          ? null
          : DateTime.parse(json['request_time'] as String),
      serviceType: getServiceProviderRoleEnum(json['service_type'] as String?),
      details: json['details'] as String?,
      status: getStatus(json['status'] as String?),
      estimatedArrivalTime: json['estimated_arrival_time'] as String?,
      employeeId: json['employee_id'] as int?,
    );
  }

  // get serviceType from string
  static ServiceProviderRoleEnum? getServiceProviderRoleEnum(String? type) {
    switch (type) {
      case 'moto':
        return ServiceProviderRoleEnum.moto;
      case 'towTruck':
        return ServiceProviderRoleEnum.towTruck;
      case 'mechanic':
        return ServiceProviderRoleEnum.mechanic;
      case 'fuelDelivery':
        return ServiceProviderRoleEnum.fuelDelivery;
      default:
        return null;
    }
  }

  // getStatus from ServiceStatus
  static ServiceStatus getStatus(String? status) {
    switch (status) {
      case 'accept':
        return ServiceStatus.accept;
      case 'done':
        return ServiceStatus.done;
      default:
        return ServiceStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'request_time': requestTime?.toIso8601String(),
      'service_type': serviceType?.name,
      'details': details,
      'status': status.name,
      'estimated_arrival_time': estimatedArrivalTime,
      'employee_id': employeeId,
    };
  }

  ServiceRequestModel copyWith({
    int? requestId,
    int? userId,
    DateTime? requestTime,
    ServiceProviderRoleEnum? serviceType,
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
