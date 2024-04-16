import 'package:flutter/material.dart';
import 'package:senior_proj/models/service_request_model.dart';
import 'package:senior_proj/services/request_service.dart';

class FuelDeliveryScreen extends StatefulWidget {
  const FuelDeliveryScreen({super.key, required this.requestId});
  final int requestId;

  static const routeNamed = 'fuel_delivery';
  static const route = '/fuel_delivery/:id';

  @override
  State<FuelDeliveryScreen> createState() => _FuelDeliveryScreenState();
}

class _FuelDeliveryScreenState extends State<FuelDeliveryScreen> {
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
        title: const Text('Fuel Delivery Page'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Request ID: ${_request.requestId}'),
                const SizedBox(height: 8),
                Text('User ID: ${_request.userId}'),
                const SizedBox(height: 8),
                Text('Request Time: ${_request.requestTime}'),
                const SizedBox(height: 8),
                Text('Service Type: ${_request.serviceType?.name}'),
                const SizedBox(height: 8),
                Text('Details: ${_request.details}'),
                const SizedBox(height: 8),
                Text('Status: ${_request.status.name}'),
                const SizedBox(height: 8),
                Text(
                  'Estimated Arrival Time: ${_request.estimatedArrivalTime}',
                ),
                const SizedBox(height: 8),
                Text('Employee ID: ${_request.employeeId}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
