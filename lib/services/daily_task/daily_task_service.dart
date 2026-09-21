import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:selena/services/api.dart';
import 'package:selena/session/user_session.dart';

class DailyTaskService {
  final Dio _dio;

  DailyTaskService() : _dio = Dio() {
    _dio.options.headers = {
      'Authorization': 'Bearer ${UserSession().user?.token}',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>?> getDailyTasks() async {
    try {
      final response = await _dio.get(API.dailyTasks);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error getting daily tasks: $e");
      return null;
    }
  }

  Future<bool> generateTasks() async {
    try {
      final response = await _dio.post(API.generateDailyTasks);
      return response.statusCode == 200;
    } catch (e) {
      print("Error generating daily tasks: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> completeTask(int id) async {
    try {
      final response = await _dio.put(API.completeDailyTask(id));
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error completing task: $e");
      return null;
    }
  }
}
