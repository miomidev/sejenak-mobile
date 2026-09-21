import 'package:dio/dio.dart';
import '../api.dart';

class TransactionService {
  Future<Map<String, dynamic>> checkout(String packageName, int tokenAmount, int price) async {
    try {
      final response = await DioHttpClient.getInstance().post(
        API.checkout,
        data: {
          'package_name': packageName,
          'token_amount': tokenAmount,
          'price': price,
        },
      );
      
      return response.data;
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

  Future<List<dynamic>> getTokenPackages() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.tokenPackages);
      return response.data['data'];
    } on DioException catch (e) {
      print('Failed to get token packages: ${e.message}');
      return [];
    }
  }

  Future<List<dynamic>> getMyTransactions() async {
    try {
      final response = await DioHttpClient.getInstance().get(API.myTransactions);
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
}
