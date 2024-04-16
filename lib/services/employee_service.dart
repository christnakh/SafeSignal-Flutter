import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/service_request_model.dart';

class EmployeeService {
  const EmployeeService();

  static Future<List<ServiceRequestModel>> getEmployees({
    required int id,
    void Function(String message)? onError,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.getUri(
        Uri.parse('$kBaseUrl/employees/$id'),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Failed to load employee');
      }

      if (data.isEmpty) {
        return [];
      }

      final employees = (data as List).map((e) {
        return ServiceRequestModel.fromJson(e as Map<String, dynamic>);
      }).toList();

      return employees;
    } catch (e) {
      onError?.call(e.toString());
      return [];
    }
  }

  static Future<void> updateEmployeeLocation({
    required int employeeId,
    required Position position,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.postUri(
        Uri.parse('$kBaseUrl/locations_employe'),
        data: {
          'employee_id': employeeId,
          'longitude': position.longitude,
          'latitude': position.latitude,
        },
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to update location');
      }

      return onSuccess?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static Future<void> updateEmployeeStatus({
    required int requestId,
    required String status,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final response = await Dio().put(
        '$kBaseUrl/status/$requestId',
        data: {
          'status': status,
        },
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw Exception('Failed to update employee status');
      }

      onSuccess?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}
