import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key, required this.id});

  final String id;

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool _isLoading = true;
  final Dio _dio = Dio();

  static const String _baseUrl = 'http://192.168.1.103:3000/employees';

  late final EmployeeModel _employee;

  @override
  void initState() {
    super.initState();

    _getEmployee();
  }

  Future<void> _getEmployee() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/${widget.id}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw Exception('Failed to load employee');
      }

      final employee = EmployeeModel.fromJson(data as Map<String, dynamic>);

      if (!mounted) return;
      setState(() {
        _employee = employee;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
      ),
      body: Column(
        children: <Widget>[
          Text('ID: ${_employee.requestId}'),
          Text('User ID: ${_employee.userId}'),
          Text('Request Time: ${_employee.requestTime}'),
          Text('Service Type: ${_employee.serviceType}'),
          Text('Details: ${_employee.details}'),
          Text('Status: ${_employee.status}'),
          Text('Estimated Arrival Time: ${_employee.estimatedArrivalTime}'),
          Text('Employee ID: ${_employee.employeeId}'),
        ],
      ),
    );
  }
}

class EmployeeModel {
  final int requestId;
  final int userId;
  final String requestTime;
  final String serviceType;
  final String details;
  final String status;
  final String estimatedArrivalTime;
  final int employeeId;

  const EmployeeModel({
    required this.requestId,
    required this.userId,
    required this.requestTime,
    required this.serviceType,
    required this.details,
    required this.status,
    required this.estimatedArrivalTime,
    required this.employeeId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      requestId: json['request_id'] as int,
      userId: json['user_id'] as int,
      requestTime: json['request_time'] as String,
      serviceType: json['service_type'] as String,
      details: json['details'] as String,
      status: json['status'] as String,
      estimatedArrivalTime: json['estimated_arrival_time'] as String,
      employeeId: json['employee_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'request_time': requestTime,
      'service_type': serviceType,
      'details': details,
      'status': status,
      'estimated_arrival_time': estimatedArrivalTime,
      'employee_id': employeeId,
    };
  }

  EmployeeModel copyWith({
    int? requestId,
    int? userId,
    String? requestTime,
    String? serviceType,
    String? details,
    String? status,
    String? estimatedArrivalTime,
    int? employeeId,
  }) {
    return EmployeeModel(
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
  String toString() {
    return 'EmployeeModel{requestId: $requestId, userId: $userId, requestTime: $requestTime, serviceType: $serviceType, details: $details, status: $status, estimatedArrivalTime: $estimatedArrivalTime, employeeId: $employeeId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeModel &&
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
}
