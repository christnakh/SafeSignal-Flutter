import 'package:flutter/material.dart';

class FuelDeliveryPage extends StatelessWidget {
  final String userId;

  FuelDeliveryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Delivery Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Fuel Delivery Page!',
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
