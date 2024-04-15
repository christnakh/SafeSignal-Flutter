import 'package:dio/dio.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/service_request_model.dart';

class RequestService {
  const RequestService();

  static Future<ServiceRequestModel> getRequest(int requestId) async {
    final Dio dio = Dio();
    try {
      final response = await dio.getUri(
        Uri.parse('$kBaseUrl/service_requests/$requestId'),
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data.isEmpty) {
        throw Exception('Service request not found');
      }

      if (response.statusCode == 404) {
        throw Exception('Service request not found');
      }

      return ServiceRequestModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching service request');
    }
  }
}
