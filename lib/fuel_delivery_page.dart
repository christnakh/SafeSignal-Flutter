import 'package:flutter/material.dart';

class FuelDeliveryPage extends StatelessWidget {
  final int requestId;

  const FuelDeliveryPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Delivery Page'),
      ),
      body: Center(
        child: Text('Request ID: $requestId'),
      ),
    );
  }
}
