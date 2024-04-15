import 'package:dio/dio.dart';
import 'package:senior_proj/constants/environment.dart';
import 'package:senior_proj/models/user_locations_model.dart';
import 'package:senior_proj/models/user_model.dart';

class UserService {
  const UserService();

  static Future<void> login({
    required String email,
    required String password,
    required LoginType type,
    void Function(String message)? onError,
    void Function(User userID)? onSuccess,
  }) async {
    final Dio dio = Dio();
    try {
      final route = getLoginTypeRoute(type);
      final response = await dio.postUri(
        Uri.parse('$kBaseUrl/$route'),
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        onSuccess?.call(User.fromJson(data));
      } else {
        throw Exception('Failed to login status: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static Future<void> register({
    required User user,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.postUri(
        Uri.parse('$kBaseUrl/users'),
        data: user.toJson(),
      );

      if (response.statusCode == 201) {
        onSuccess?.call();
      } else {
        throw Exception('Failed to register status: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static String getLoginTypeRoute(LoginType type) {
    switch (type) {
      case LoginType.user:
        return 'login';
      case LoginType.admin:
        return 'loginadmin';
      case LoginType.provider:
        return 'provider/login';
    }
  }

  static Future<UserLocationModel?> getUserLocation({
    required int userId,
    void Function(String message)? onError,
  }) async {
    final Dio dio = Dio();
    try {
      final response = await dio.getUri(
        Uri.parse('$kBaseUrl/locations_user/$userId'),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return UserLocationModel.fromJson(data);
      } else {
        throw Exception('Failed to get user location');
      }
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }
}
