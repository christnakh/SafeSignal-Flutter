import 'package:flutter/material.dart';
import 'package:senior_proj/models/service_request_model.dart';
import 'package:senior_proj/services/request_service.dart';

class MechanicServicesScreen extends StatefulWidget {
  final int requestId;

  const MechanicServicesScreen({super.key, required this.requestId});

  static const routeNamed = 'mechanic_services';
  static const route = '/mechanic_services/:id';

  @override
  State<MechanicServicesScreen> createState() => _MechanicServicesScreenState();
}

class _MechanicServicesScreenState extends State<MechanicServicesScreen> {
  bool _isLoading = true;

  late final ServiceRequestModel _request;

  @override
  void initState() {
    super.initState();

    RequestService.getRequest(widget.requestId).then(
      (value) {
        if (!mounted) return;
        setState(
          () {
            _request = value;
            _isLoading = false;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Services Page'),
      ),
      body: Column(
        children: <Widget>[
          Text('Request ID: ${_request.requestId}'),
          Text('User ID: ${_request.userId}'),
          Text('Request Time: ${_request.requestTime}'),
          Text('Service Type: ${_request.serviceType}'),
          Text('Details: ${_request.details}'),
          Text('Status: ${_request.status}'),
          Text('Estimated Arrival Time: ${_request.estimatedArrivalTime}'),
          Text('Employee ID: ${_request.employeeId}'),
        ],
      ),
    );
  }
}
