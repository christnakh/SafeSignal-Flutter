import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_proj/components/app_loading_indicator.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/service_provider_model.dart';
import 'package:senior_proj/screens/fuel_delivery_screen.dart';
import 'package:senior_proj/screens/mechanic_services_screen.dart';
import 'package:senior_proj/screens/moto_taxi_screen.dart';
import 'package:senior_proj/screens/tow_truck_screen.dart';
import 'package:senior_proj/services/geolocator_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key, required this.userId});

  final String userId;

  static const routeNamed = 'user';
  static const route = '/user/:id';

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = false;

  Future<int> _findNearestEmployee(int role) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final position = await GeoLocatorService.determinePosition();

      final response = await Dio().postUri(
        Uri.parse('$kBaseUrl/find_nearest_employee'),
        data: jsonEncode({
          'user_id': widget.userId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'role': role
        }),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Data is Empty');
      }

      final responseData = jsonDecode(data);

      print(responseData);

      return responseData['request_id'];
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Service'),
      ),
      body: Center(
        child: _isLoading
            ? const AppLoadingIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildNavigationButton(
                    'Moto Taxi',
                    ServiceProviderRoleEnum.moto,
                  ),
                  const SizedBox(height: 20),
                  buildNavigationButton(
                    'Fuel Delivery',
                    ServiceProviderRoleEnum.fuelDelivery,
                  ),
                  const SizedBox(height: 20),
                  buildNavigationButton(
                    'Tow Truck',
                    ServiceProviderRoleEnum.towTruck,
                  ),
                  const SizedBox(height: 20),
                  buildNavigationButton(
                    'Mechanic Services',
                    ServiceProviderRoleEnum.mechanic,
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildNavigationButton(String text, ServiceProviderRoleEnum role) {
    return Builder(builder: (ctx) {
      return ElevatedButton(
        onPressed: () async {
          await showServiceDialog(text, () async {
            try {
              int requestId = await _findNearestEmployee(role.value);
              if (!context.mounted) return;

              final String route = switch (role) {
                ServiceProviderRoleEnum.moto => MotoTaxiScreen.routeNamed,
                ServiceProviderRoleEnum.fuelDelivery =>
                  FuelDeliveryScreen.routeNamed,
                ServiceProviderRoleEnum.towTruck => TowTruckScreen.routeNamed,
                ServiceProviderRoleEnum.mechanic =>
                  MechanicServicesScreen.routeNamed,
              };

              ctx.goNamed(route, pathParameters: {'id': requestId.toString()});
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                ),
              );
            }
          });
        },
        child: Text(text),
      );
    });
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
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
