import 'package:flutter/material.dart';
import 'package:senior_proj/services/request_service.dart';

class MechanicServicesPage extends StatefulWidget {
  final int requestId;

  const MechanicServicesPage({super.key, required this.requestId});

  @override
  State<MechanicServicesPage> createState() => _MechanicServicesPageState();
}

class _MechanicServicesPageState extends State<MechanicServicesPage> {
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
