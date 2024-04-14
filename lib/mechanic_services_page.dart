import 'package:flutter/material.dart';

class MechanicServicesPage extends StatelessWidget {
  final String userId;

  MechanicServicesPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mechanic Services Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Mechanic Services Page!',
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
