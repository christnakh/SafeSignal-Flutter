import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key, required this.id});

  final String id;

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool _isLoading = true;
  final Dio _dio = Dio();

  static const String _baseUrl = 'http://192.168.1.103:3000';

  final ValueNotifier<EmployeeLocation?> _employeeLocation =
      ValueNotifier(null);
  Timer? _timer;

  List<EmployeeModel> _employees = [];

  @override
  void initState() {
    super.initState();

    _getEmployee();

    _updateEmployeeLocation(widget.id);
    _timer = Timer.periodic(const Duration(seconds: 35), (timer) {
      _updateEmployeeLocation(widget.id);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _employeeLocation.dispose();
    super.dispose();
  }

  Future<void> _getEmployee() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/employees/${widget.id}',
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

      final employees = (data as List)
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _updateEmployeeStatus(int requestId, String status) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/status/$requestId',
        data: {
          'status': status,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw Exception('Failed to update employee status');
      }

      if (!mounted) return;
      setState(() {
        _employees = _employees.map((employee) {
          if (employee.requestId == requestId) {
            return employee.copyWith(status: status);
          }
          return employee;
        }).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(serviceEnabled);
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print(permission);
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(permission);
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateEmployeeLocation(String employeeId) async {
    try {
      final locationData = await _determinePosition();
      final response = await _dio.post(
        '$_baseUrl/locations_employe',
        data: {
          'employee_id': employeeId,
          'longitude': locationData.longitude,
          'latitude': locationData.latitude,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      print(data);
      if (data == null || data.isEmpty) {
        throw Exception('Failed to update employee location');
      }

      _employeeLocation.value = _employeeLocation.value?.copyWith(
        employeeId: employeeId,
        longitude: locationData.longitude.toString(),
        latitude: locationData.latitude.toString(),
      );

      if (!mounted) return;
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
        actions: [
          ValueListenableBuilder<EmployeeLocation?>(
              valueListenable: _employeeLocation,
              builder: (_, it, __) {
                if (it == null) return const SizedBox();

                return Text(
                  'Location: lat: ${it.latitude}, long: ${it.longitude}',
                );
              }),
        ],
      ),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${employee.requestId}'),
                Text('User ID: ${employee.userId}'),
                Text('Request Time: ${employee.requestTime}'),
                Row(
                  children: [
                    Text('Status: ${employee.status}'),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        _updateEmployeeStatus(employee.requestId, 'Accept');
                      },
                      child: const Text('Accept'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _updateEmployeeStatus(employee.requestId, 'Done');
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
                Text(
                  'Estimated Arrival Time: ${employee.estimatedArrivalTime}',
                ),
                Text('Employee ID: ${employee.employeeId}'),
              ],
            ),
          );
        },
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

class EmployeeLocation {
  final String employeeId;
  final String longitude;
  final String latitude;

  const EmployeeLocation({
    required this.employeeId,
    required this.longitude,
    required this.latitude,
  });

  factory EmployeeLocation.fromJson(Map<String, dynamic> json) {
    return EmployeeLocation(
      employeeId: json['employee_id'] as String,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  EmployeeLocation copyWith({
    String? employeeId,
    String? longitude,
    String? latitude,
  }) {
    return EmployeeLocation(
      employeeId: employeeId ?? this.employeeId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }

  @override
  String toString() {
    return 'EmployeeLocation{employee_id: $employeeId, longitude: $longitude, latitude: $latitude}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeLocation &&
        other.employeeId == employeeId &&
        other.longitude == longitude &&
        other.latitude == latitude;
  }

  @override
  int get hashCode {
    return employeeId.hashCode ^ longitude.hashCode ^ latitude.hashCode;
  }
}
