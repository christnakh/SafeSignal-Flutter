import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:math';

class MotoTaxiPage extends StatefulWidget {
  final String userId;

  MotoTaxiPage({required this.userId});

  @override
  _MotoTaxiPageState createState() => _MotoTaxiPageState();
}

class _MotoTaxiPageState extends State<MotoTaxiPage> {
  late Timer _locationTimer;
  geo.Position? _currentLocation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _locationTimer.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await geo.Geolocator.checkPermission();
    if (status == geo.LocationPermission.denied ||
        status == geo.LocationPermission.deniedForever) {
      final permission = await geo.Geolocator.requestPermission();
      if (permission != geo.LocationPermission.whileInUse &&
          permission != geo.LocationPermission.always) {
        return;
      }
    }
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = position;
      });
      if (_currentLocation != null) {
        _sendUserLocationToServer(_currentLocation!);
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _sendUserLocationToServer(geo.Position position) async {
    try {
      final url = Uri.parse('http://192.168.1.103:3000/locations_user');

      final response = await http.post(
        url,
        body: {
          'user_id': widget.userId,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        },
      );
      if (response.statusCode == 201) {
        print('Location sent to server successfully');
      } else {
        print('Failed to send location to server');
      }
    } catch (e) {
      print('Error sending location to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moto Taxi Page'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : _buildPage(_currentLocation!),
    );
  }

  Widget _buildPage(geo.Position userLocation) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Moto Taxi Page!',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 20),
          Text(
            'Current Location: (${userLocation.latitude}, ${userLocation.longitude})',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // Call the method to request service
              // await _requestServiceFromNearestProvider(userLocation);
            },
            child: Text('Request Service'),
          ),
        ],
      ),
    );
  }
}
