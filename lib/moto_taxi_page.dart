import 'package:flutter/material.dart';

class MotoTaxiPage extends StatelessWidget {
  final int requestId;

  const MotoTaxiPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto Taxi Page'),
      ),
      body: Center(
        child: Text('Request ID: $requestId'),
      ),
    );
  }
}
