import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print(serviceEnabled);
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print(permission);
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(permission);
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<int> findNearestEmployee(int role) async {
    try {
      final position = await _determinePosition();

      final response = await _dio.post(
        'http://192.168.1.103:3000/find_nearest_employee',
        data: {
          'user_id': widget.userId,
          'latitude': position.latitude,
          'longitude': position.longitude,
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

  Future<void> showServiceDialog(String taxi, void Function() onConfirm) {
    return showDialog<Widget>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to request $taxi'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: onConfirm,
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButton(String text, int role) {
    return Builder(builder: (ctx) {
      return ElevatedButton(
        onPressed: () async {
          await showServiceDialog(text, () async {
            try {
              int requestId = await findNearestEmployee(role);
              if (!ctx.mounted) return;

              Navigator.pushReplacement(ctx,
                  MaterialPageRoute(builder: (context) {
                switch (role) {
                  case 1:
                    return MotoTaxiPage(requestId: requestId);
                  case 2:
                    return FuelDeliveryPage(requestId: requestId);
                  case 3:
                    return TowTruckPage(requestId: requestId);
                  case 4:
                    return MechanicServicesPage(requestId: requestId);
                  default:
                    throw Exception('Invalid Role');
                }
              }));
            } catch (e) {
              print('Error: $e');
            }
          });
        },
        child: Text(text),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Service'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildNavigationButton('Moto Taxi', 1),
            _buildNavigationButton('Fuel Delivery', 2),
            _buildNavigationButton('Tow Truck', 3),
            _buildNavigationButton('Mechanic Services', 4),
          ],
        ),
      ),
    );
  }
}
