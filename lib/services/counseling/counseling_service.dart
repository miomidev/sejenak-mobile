import 'package:dio/dio.dart';
import '../api.dart';

class CounselingService {
  Future<List<dynamic>> getCounselors() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.counselors);
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting counselors: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> requestSession(int counselorId, {String? scheduledAt}) async {
    try {
      final response = await DioHttpClient.getInstance().post(
        API.sessionRequest,
        data: {
          'counselor_id': counselorId,
          if (scheduledAt != null) 'scheduled_at': scheduledAt
        },
      );
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
        'requires_topup': response.data['requires_topup'] ?? false,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? e.message,
        'requires_topup': e.response?.data?['requires_topup'] ?? false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan sistem: $e',
        'requires_topup': false,
      };
    }
  }

  Future<List<dynamic>> getMySessions() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.mySessions);
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting sessions: $e');
      return [];
    }
  }

  Future<int> getSessionPrice() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.sessionPrice);
      return response.data['data'];
    } catch (e) {
      print('Failed to get session price: $e');
      return 500; // default
    }
  }

  Future<bool> acceptSession(int sessionId) async {
    try {
      final response = await DioHttpClient.getInstance().post(API.sessionAccept(sessionId));
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error accepting session: $e');
      return false;
    }
  }

  Future<bool> endSession(int sessionId) async {
    try {
      final response = await DioHttpClient.getInstance().post(API.sessionEnd(sessionId));
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error ending session: $e');
      return false;
    }
  }
}
