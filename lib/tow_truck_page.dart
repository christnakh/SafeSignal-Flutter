import 'package:flutter/material.dart';

class TowTruckPage extends StatelessWidget {
  final int requestId;

  const TowTruckPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tow Truck Page'),
      ),
      body: Center(
        child: Text('Request ID: $requestId'),
      ),
    );
  }
}
