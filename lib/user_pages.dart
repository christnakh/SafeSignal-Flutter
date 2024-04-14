import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({super.key, required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isLoading = true;

  late LocationData _currentLocation;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
      _isLoading = false;
    });
  }

  Future<int> findNearestEmployee(int role) async {
    try {
      final response = await _dio.postUri(
        Uri.parse('http://192.168.1.103:3000/find_nearest_employee'),
        data: jsonEncode({
          'user_id': widget.userId,
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
          'role': role
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Data is Empty');
      }

      print(response.statusCode);

      print(data);
      print(data.runtimeType);

      final responseData = jsonDecode(data);
      return responseData['request_id'];
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Material(child: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Service'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId = await findNearestEmployee(1); // Moto Taxi
                  if (mounted) {
                    Navigator.pushNamed(
                      context,
                      '/moto_taxi_page',
                      arguments: {'request_id': requestId},
                    );
                  }
                } catch (e) {
                  // Handle error
                  print('Error: $e');
                }
              },
              child: const Text('Moto Taxi'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  int requestId = await findNearestEmployee(2); // Fuel Delivery
                        if (!mounted) return;
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
              child: const Text('Fuel Delivery'),
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
              child: const Text('Tow Truck'),
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
              child: const Text('Mechanic Services'),
            ),
          ],
        ),
      ),
    );
  }
}
