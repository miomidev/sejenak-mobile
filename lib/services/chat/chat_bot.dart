import 'package:dio/dio.dart';

import '../api.dart';

class ChatBotService {
  final DioHttpClient _httpClient = DioHttpClient.getInstance();

  Future<String> sendMessage(String message) async {
    try {
      final response = await _httpClient.post(API.chatBot, data: {"message": message});

      if (response.statusCode == 200 && response.data['ai_response'] != null) {
        return response.data['ai_response'];
      } else {
        throw Exception("Invalid response format: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("ChatBot error: ${e.message}");
    }
  }
}
