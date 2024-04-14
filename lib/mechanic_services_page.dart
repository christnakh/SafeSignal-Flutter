import 'package:flutter/material.dart';

class MechanicServicesPage extends StatelessWidget {
  final int requestId;

  const MechanicServicesPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanic Services Page'),
      ),
      body: Center(
        child: Text('Request ID: $requestId'),
      ),
    );
  }
}
