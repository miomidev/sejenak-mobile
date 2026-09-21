import 'package:dio/dio.dart';
import '../api.dart';

class ProposalService {
  Future<Map<String, dynamic>> submitProposal(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      
      FormData formData = FormData.fromMap({
        "document": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await DioHttpClient.getInstance().post(
        API.proposals,
        data: formData,
      );
      
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan sistem: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getMyProposal() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.myProposal);
      return {
        'success': response.data['success'] ?? false,
        'data': response.data['data'],
      };
    } catch (e) {
      print('Error getting proposal: $e');
      return {
        'success': false,
        'data': null,
      };
    }
  }
}
