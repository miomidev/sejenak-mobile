import 'package:dio/dio.dart';
import 'package:selena/models/user_models/user.dart';
import 'package:selena/services/api.dart';

class ChatServices {
  late List<User> _konselor;
  Future<List<User>> getAllKonselor() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.konselor);
      print("✅ RESPONSE RAW JSON:");
      print(response.data);

      if (response.data['body'] is List) {
        _konselor = User.fromJsonList(response.data['body']);
        print("Response: ${_konselor.toList()}");
        return _konselor;
      } else {
        throw Exception("Unexpected response format");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");
      throw Exception("Failed to load posts: ${e.response?.statusCode}");
    }
  }
}
