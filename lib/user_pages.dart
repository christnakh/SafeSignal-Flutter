import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'fuel_delivery_page.dart';
import 'mechanic_services_page.dart';
import 'moto_taxi_page.dart';
import 'tow_truck_page.dart';

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
    LocationData? locationData;

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
      _currentLocation = locationData!;
      _isLoading = false;
    });
  }

  Future<int> findNearestEmployee(int role) async {
    try {
      final response = await _dio.post(
        'http://192.168.1.103:3000/find_nearest_employee',
        data: {
          'user_id': widget.userId,
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
          'role': role
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Data is Empty');
      }

      final responseData = jsonDecode(data);
      return responseData['request_id'];
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
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
                  // Navigate to Moto Taxi page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MotoTaxiPage(requestId: requestId),
                    ),
                  );
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
                  // Navigate to Fuel Delivery page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FuelDeliveryPage(requestId: requestId),
                    ),
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
                  // Navigate to Tow Truck page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TowTruckPage(requestId: requestId),
                    ),
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
                  // Navigate to Mechanic Services page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MechanicServicesPage(requestId: requestId),
                    ),
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
