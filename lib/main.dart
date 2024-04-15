import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_proj/screens/admin_screen.dart';
import 'package:senior_proj/screens/employee_screen.dart';
import 'package:senior_proj/screens/fuel_delivery_screen.dart';
import 'package:senior_proj/screens/login_screen.dart';
import 'package:senior_proj/screens/mechanic_services_screen.dart';
import 'package:senior_proj/screens/moto_taxi_screen.dart';
import 'package:senior_proj/screens/register_screen.dart';
import 'package:senior_proj/screens/tow_truck_screen.dart';
import 'package:senior_proj/screens/user_screen.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();

  FlutterError.onError = (errorDetails) {
    // ignore: avoid_print
    print('FlutterError.onError: $errorDetails');
  };

  // Pass all uncaught asynchronous errors that aren't handled by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    // print('PlatformDispatcher.instance.onError: $error');

    return false;
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: LoginScreen.route,
  routes: [
    GoRoute(
      name: AdminScreen.routeNamed,
      path: AdminScreen.route,
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      name: EmployeeScreen.routeNamed,
      path: EmployeeScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = int.tryParse(param ?? '') ?? 0;

        return EmployeeScreen(id: id);
      },
    ),
    GoRoute(
      name: LoginScreen.routeNamed,
      path: LoginScreen.route,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: RegisterScreen.routeNamed,
      path: RegisterScreen.route,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      name: UserScreen.routeNamed,
      path: UserScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = param ?? '';

        return UserScreen(userId: id);
      },
    ),
    GoRoute(
      name: FuelDeliveryScreen.routeNamed,
      path: FuelDeliveryScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = int.tryParse(param ?? '') ?? 0;

        return FuelDeliveryScreen(
          requestId: id,
        );
      },
    ),
    GoRoute(
      name: MechanicServicesScreen.routeNamed,
      path: MechanicServicesScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = int.tryParse(param ?? '') ?? 0;

        return MechanicServicesScreen(
          requestId: id,
        );
      },
    ),
    GoRoute(
      name: MotoTaxiScreen.routeNamed,
      path: MotoTaxiScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = int.tryParse(param ?? '') ?? 0;

        return MotoTaxiScreen(
          requestId: id,
        );
      },
    ),
    GoRoute(
      name: TowTruckScreen.routeNamed,
      path: TowTruckScreen.route,
      builder: (context, state) {
        final param = state.pathParameters['id'];
        final id = int.tryParse(param ?? '') ?? 0;

        return TowTruckScreen(
          requestId: id,
        );
      },
    ),
  ],
);
