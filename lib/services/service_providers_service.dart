import 'package:dio/dio.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/service_provider_model.dart';

class ServiceProvidersService {
  const ServiceProvidersService();

  static Future<void> createServiceProvider({
    required ServiceProviderModel provider,
    void Function(String message)? onError,
    void Function()? onSuccess,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.postUri(
        Uri.parse('$kBaseUrl/service_providers'),
        data: provider.toJson(),
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to add service provider');
      }

      onSuccess?.call();
    } catch (e) {
      onError?.call('Error adding service provider: $e');
    }
  }

  static Future<void> fetchServiceProviders({
    void Function(String message)? onError,
    void Function(List<ServiceProviderModel> providers)? onSuccess,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.getUri(
        Uri.parse('$kBaseUrl/service_providers'),
      );

      final data = response.data;
      if (data is! List<dynamic> || data.isEmpty) {
        throw Exception(
          'No service providers found or invalid type ${data.runtimeType}',
        );
      }

      onSuccess?.call(
          data.map((json) => ServiceProviderModel.fromJson(json)).toList());
    } catch (e) {
      onError?.call('Error fetching service providers: $e');
    }
  }

  static Future<void> updateServiceProvider({
    required ServiceProviderModel provider,
    void Function(String message)? onError,
    void Function()? onSuccess,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.putUri(
        Uri.parse('$kBaseUrl/service_providers/${provider.id}'),
        data: provider.toJson(),
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to update service provider');
      }

      onSuccess?.call();
    } catch (e) {
      onError?.call('Error updating service provider: $e');
    }
  }

  static Future<void> deleteServiceProvider({
    required int id,
    void Function(String message)? onError,
    void Function()? onSuccess,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.deleteUri(
        Uri.parse('$kBaseUrl/service_providers/$id'),
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to delete service provider');
      }

      onSuccess?.call();
    } catch (e) {
      onError?.call('Error deleting service provider: $e');
    }
  }
}
