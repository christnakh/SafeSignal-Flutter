import 'dart:async';

import 'package:flutter/material.dart';
import 'package:senior_proj/components/app_loading_indicator.dart';
import 'package:senior_proj/models/service_request_model.dart';
import 'package:senior_proj/services/employee_service.dart';
import 'package:senior_proj/services/geolocator_service.dart';
import 'package:senior_proj/services/user_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key, required this.id});

  final int id;

  static const routeNamed = 'employee_page';
  static const route = '/employee_page/:id';

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  bool _isLoading = true;
  List<ServiceRequestModel> _employees = [];
  final Map<int, LocationRecord> _userLocations = {};

  @override
  void initState() {
    super.initState();
    _getEmployeeRequests();
  }

  Future<void> _getEmployeeRequests() async {
    _employees = await EmployeeService.getEmployees(
      id: widget.id,
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load employees: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    for (final employee in _employees) {
      if (employee.userId case final userId?) {
        await _getUserLocation(userId);
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getUserLocation(int userId) async {
    final userLocation = await UserService.getUserLocation(
      userId: userId,
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user location: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    if (!mounted) return;
    _userLocations[userId] = (
      latitude: userLocation?.latitude ?? 'unknown',
      longitude: userLocation?.longitude ?? 'unknown',
    );
  }

  Future<void> onEmployeeStatusUpdate(int? id, String status) async {
    if (id == null) return;

    EmployeeService.updateEmployeeStatus(
      requestId: id,
      status: status,
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $message'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Screen'),
        actions: [
          EmployeeLocationWidget(id: widget.id),
        ],
      ),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          final userLocation =
              _userLocations[employee.userId] ?? (latitude: '', longitude: '');

          return EmployeeCard(
            employee: employee,
            userLocation: userLocation,
            onEmployeeStatusUpdate: onEmployeeStatusUpdate,
          );
        },
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    required this.userLocation,
    required this.onEmployeeStatusUpdate,
  });

  final ServiceRequestModel employee;
  final LocationRecord userLocation;

  final void Function(int? id, String status) onEmployeeStatusUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${employee.requestId}'),
          Expanded(
            child: Row(
              children: [
                Text('User ID: ${employee.userId}'),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Location: ${userLocation.latitude}, ${userLocation.longitude}',
                  ),
                )
              ],
            ),
          ),
          Text('Request Time: ${employee.requestTime}'),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Text('Status: ${employee.status}')),
                const SizedBox(width: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    onEmployeeStatusUpdate(
                      employee.requestId,
                      ServiceStatus.accept.name,
                    );
                  },
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    onEmployeeStatusUpdate(
                      employee.requestId,
                      ServiceStatus.done.name,
                    );
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          Text(
            'Estimated Arrival Time: ${employee.estimatedArrivalTime}',
          ),
          Text('Employee ID: ${employee.employeeId}'),
        ],
      ),
    );
  }
}

class EmployeeLocationWidget extends StatefulWidget {
  const EmployeeLocationWidget({
    super.key,
    required this.id,
  });

  final int id;

  @override
  State<EmployeeLocationWidget> createState() => _EmployeeLocationWidgetState();
}

class _EmployeeLocationWidgetState extends State<EmployeeLocationWidget> {
  Timer? _timer;
  LocationRecord locationRecord = (longitude: '', latitude: '');

  @override
  void initState() {
    super.initState();

    _updateEmployeeLocation();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateEmployeeLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateEmployeeLocation() async {
    try {
      final locationData = await GeoLocatorService.determinePosition();
      await EmployeeService.updateEmployeeLocation(
        employeeId: widget.id,
        position: locationData,
        onError: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update location: $message'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onSuccess: () {
          if (!mounted) return;
          setState(() {
            locationRecord = (
              latitude: locationData.latitude.toString(),
              longitude: locationData.longitude.toString(),
            );
          });
        },
      );

      if (!mounted) return;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Location: lat: ${locationRecord.latitude}, long: ${locationRecord.longitude}',
    );
  }
}

typedef LocationRecord = ({String latitude, String longitude});
