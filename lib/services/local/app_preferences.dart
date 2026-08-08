import 'dart:convert';

import 'package:selena/services/local/json_serializable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static Future<void> saveModelList<T extends JsonSerializable>(
    String key,
    List<T> models,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        models.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(key, jsonString);
  }

   static Future<List<T>> loadModelList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map<T>((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Gagal memuat data dari SharedPreferences: $e');
      return [];
    }
  }
  static Future<void> savePendingJournal(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pending_journals') ?? [];
    list.add(jsonEncode(data));
    await prefs.setStringList('pending_journals', list);
  }

  static Future<List<Map<String, dynamic>>> loadPendingJournals() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pending_journals') ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clearPendingJournalAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pending_journals') ?? [];
    if (index < list.length) {
      list.removeAt(index);
      await prefs.setStringList('pending_journals', list);
    }
  }
  
}
