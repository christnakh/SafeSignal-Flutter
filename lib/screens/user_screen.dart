import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_proj/components/app_loading_indicator.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/service_provider_model.dart';
import 'package:senior_proj/screens/fuel_delivery_screen.dart';
import 'package:senior_proj/screens/mechanic_services_screen.dart';
import 'package:senior_proj/screens/moto_taxi_screen.dart';
import 'package:senior_proj/screens/tow_truck_screen.dart';
import 'package:senior_proj/services/geolocator_service.dart';
import 'package:senior_proj/services/user_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key, required this.userId});

  final String userId;

  static const routeNamed = 'user';
  static const route = '/user/:id';

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;
  Timer? _timer;

  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _getUserLocation(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // getUserLocation
  Future<void> _getUserLocation() async {
    final position = await GeoLocatorService.determinePosition();
    if (_userLocation == position) return;

    unawaited(UserService.updateUserLocation(
      userId: widget.userId.toString(),
      position: position,
    ));

    if (!mounted) return;
    setState(() {
      _userLocation = position;
      _isLoading = false;
    });
  }

  Future<int?> _findNearestEmployee(int role, String type) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_userLocation == null) {
        return null;
      }

      final response = await Dio().postUri(
        Uri.parse('$kBaseUrl/find_nearest_employee'),
        data: jsonEncode({
          'user_id': widget.userId,
          'service_type': type,
          'latitude': _userLocation?.latitude,
          'longitude': _userLocation?.longitude,
          'role': role
        }),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        return null;
      }

      return data['request_id'];
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
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
                  // show location
                  if (_userLocation != null)
                    Text(
                      'Location: ${_userLocation?.latitude}, ${_userLocation?.longitude}',
                    ),
                  const SizedBox(height: 20),
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
    return ElevatedButton(
      onPressed: () async {
        showServiceDialog(context, text, () async {
          try {
            final requestId = await _findNearestEmployee(role.value, role.name);
            if (!context.mounted) return;
            if (requestId == null) {
              Future.delayed(Duration.zero, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No available employees'),
                  ),
                );
              });
              return;
            }

            final String route = switch (role) {
              ServiceProviderRoleEnum.moto => MotoTaxiScreen.routeNamed,
              ServiceProviderRoleEnum.fuelDelivery =>
                FuelDeliveryScreen.routeNamed,
              ServiceProviderRoleEnum.towTruck => TowTruckScreen.routeNamed,
              ServiceProviderRoleEnum.mechanic =>
                MechanicServicesScreen.routeNamed,
            };

            Future.delayed(Duration.zero, () {
              context
                  .goNamed(route, pathParameters: {'id': requestId.toString()});
            });
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
  }
}

Future<void> showServiceDialog(
    BuildContext ctx, String taxi, void Function() onConfirm) {
  return showDialog<Widget>(
    context: ctx,
    builder: (context) {
      return AlertDialog(
        title: Text('Are you sure you want to request $taxi'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
