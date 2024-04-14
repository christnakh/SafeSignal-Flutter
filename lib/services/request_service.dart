import 'package:dio/dio.dart';

class RequestService {
  const RequestService();

  static Future<ServiceRequestModel> getRequest(int requestId) async {
    final Dio dio = Dio();
    try {
      final response = await dio.getUri(
        Uri.parse('http://192.168.1.103:3000/service_requests/$requestId'),
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data.isEmpty) {
        throw Exception('Service request not found');
      }

      if (response.statusCode == 404) {
        throw Exception('Service request not found');
      }

      return ServiceRequestModel.fromJson(response.data);
    } catch (e, trace) {
      print('Error fetching service request: $e');
      print(trace);
      throw Exception('Error fetching service request');
    }
  }
}

class ServiceRequestModel {
  final int requestId;
  final int userId;
  final DateTime requestTime;
  final String serviceType;
  final String details;
  final String status;
  final String estimatedArrivalTime;
  final int employeeId;

  const ServiceRequestModel({
    required this.requestId,
    required this.userId,
    required this.requestTime,
    required this.serviceType,
    required this.details,
    required this.status,
    required this.estimatedArrivalTime,
    required this.employeeId,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      requestId: json['request_id'],
      userId: json['user_id'],
      requestTime: DateTime.parse(json['request_time']),
      serviceType: json['service_type'],
      details: json['details'],
      status: json['status'],
      estimatedArrivalTime: json['estimated_arrival_time'],
      employeeId: json['employee_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'request_time': requestTime.toIso8601String(),
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
    String? serviceType,
    String? details,
    String? status,
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

  @override
  int get hashCode {
    return requestId.hashCode ^
        userId.hashCode ^
        requestTime.hashCode ^
        serviceType.hashCode ^
        details.hashCode ^
        status.hashCode ^
        estimatedArrivalTime.hashCode ^
        employeeId.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceRequestModel &&
        other.requestId == requestId &&
        other.userId == userId &&
        other.requestTime == requestTime &&
        other.serviceType == serviceType &&
        other.details == details &&
        other.status == status &&
        other.estimatedArrivalTime == estimatedArrivalTime &&
        other.employeeId == employeeId;
  }

  @override
  String toString() {
    return 'ServiceRequestModel(requestId: $requestId, userId: $userId, requestTime: $requestTime, serviceType: $serviceType, details: $details, status: $status, estimatedArrivalTime: $estimatedArrivalTime, employeeId: $employeeId)';
  }
}
