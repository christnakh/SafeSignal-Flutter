import 'package:flutter/material.dart';

class TowTruckPage extends StatelessWidget {
  final String userId;

  TowTruckPage({required this.userId, required int requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tow Truck Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Tow Truck Page!',
              style: TextStyle(fontSize: 24.0),
            ),
            Text(
              'User ID: $userId',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
