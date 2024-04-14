import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  final String userId;

  UserPage({required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late LocationData _currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _currentLocation = _locationData;
    });
  }

  Future<int> findNearestEmployee(int role) async {
    if (_currentLocation == null) {
      await _getLocation(); // Ensure location is fetched before proceeding
    }

    if (_currentLocation == null) {
      throw Exception('Location not available');
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.103:3000/find_nearest_employee'),
        body: jsonEncode({
          'user_id': widget.userId,
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
          'role': role
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['request_id'];
      } else {
        throw Exception('Failed to find nearest employee');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Service'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId = await findNearestEmployee(1); // Moto Taxi
                  Navigator.pushNamed(
                    context,
                    '/moto_taxi_page',
                    arguments: {'request_id': requestId},
                  );
                } catch (e) {
                  // Handle error
                  print('Error: $e');
                }
              },
              child: Text('Moto Taxi'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId = await findNearestEmployee(2); // Fuel Delivery
                  Navigator.pushNamed(
                    context,
                    '/fuel_delivery_page',
                    arguments: {'request_id': requestId},
                  );
                } catch (e) {
                  // Handle error
                  print('Error: $e');
                }
              },
              child: Text('Fuel Delivery'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId = await findNearestEmployee(3); // Tow Truck
                  Navigator.pushNamed(
                    context,
                    '/tow_truck_page',
                    arguments: {'request_id': requestId},
                  );
                } catch (e) {
                  // Handle error
                  print('Error: $e');
                }
              },
              child: Text('Tow Truck'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId =
                      await findNearestEmployee(4); // Mechanic Services
                  Navigator.pushNamed(
                    context,
                    '/mechanic_services_page',
                    arguments: {'request_id': requestId},
                  );
                } catch (e) {
                  // Handle error
                  print('Error: $e');
                }
              },
              child: Text('Mechanic Services'),
            ),
          ],
        ),
      ),
    );
  }
}
