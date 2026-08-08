import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:selena/models/journal_models/journal_models.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/local/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class JournalService {
  Future<List<JournalModels>> getAllJournal();
  Future<JournalModels?> getJournalById(int id);
  Future<void> createJournal(JournalModels journal);
  Future<void> updateJournal(JournalModels journal);
  Future<void> deleteJournal(int id);
  Future<void> syncPendingJournals();
}

class JournalApiService implements JournalService {
  final DioHttpClient _httpClient = DioHttpClient.getInstance();

  @override
  Future<List<JournalModels>> getAllJournal() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _httpClient.get(
        API.journal,
        queryParameters: {"action": "all"},
      );

      print("✅ Full Response: ${response.data}");

      if (response.data['data'] != null && response.data['data']['data'] != null) {
        final List<dynamic> journalList = response.data['data']['data'];
        final journals = JournalModels.fromJsonList(journalList);

        // ✅ Simpan ke cache SharedPreferences
        final jsonString = jsonEncode(journalList);
        await prefs.setString('cached_journals', jsonString);
        print("📦 Cached ${journals.length} journals locally.");

        return journals;
      } else {
        throw Exception("Unexpected response format: ${response.data}");
      }
    } on DioException catch (e) {
      print("⚠️ Dio Error: ${e.message}");
      final cachedData = prefs.getString('cached_journals');
      if (cachedData != null) {
        print("📂 Loading journals from cache...");
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return JournalModels.fromJsonList(jsonList);
      } else {
        throw Exception("Failed to load journals (no cache found)");
      }
    }
  }
Future<List<JournalModels>> getAllLocalAndPendingJournal() async {
  final prefs = await SharedPreferences.getInstance();
  final List<JournalModels> allJournals = [];

   final cachedData = prefs.getString('cached_journals');
  if (cachedData != null) {
    final List<dynamic> jsonList = jsonDecode(cachedData);
    allJournals.addAll(JournalModels.fromJsonList(jsonList));
  }

   final pending = await AppPreferences.loadPendingJournals();
  allJournals.addAll(
    pending.map((e) => JournalModels.fromJson(e)).toList(),
  );

  return allJournals;
}

  @override
  Future<JournalModels?> getJournalById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _httpClient.get(API.journalDetail(id));
      if (response.data['data'] != null) {
        return JournalModels.fromJson(response.data['data']);
      } else {
        throw Exception("Journal not found or invalid response format");
      }
    } on DioException catch (e) {
      print("⚠️ Dio Error (getJournalById): ${e.message}");
      // 🔁 Coba cari di cache
      final cachedData = prefs.getString('cached_journals');
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        final cachedJournals = JournalModels.fromJsonList(jsonList);
        return cachedJournals.firstWhere(
          (journal) => journal.entriesId == id,
          orElse: () => JournalModels(entriesId: id, title: "Offline", content: "No internet connection"),
        );
      }
      return null;
    }
  }

  @override
Future<void> createJournal(JournalModels journal) async {
  try {
    print("Sending journal to server...");
    await _httpClient.post(API.journal, data: journal.toJson());
    print("Journal successfully sent to server.");
  } on DioException catch (e) {
    print("Dio Error (createJournal): ${e.message}");

    if (e.type == DioExceptionType.connectionError ||
        e.message!.contains('Failed host lookup')) {
      print("No internet detected. Saving journal to pending cache...");

      // Simpan ke pending cache
      await AppPreferences.savePendingJournal(journal.toJson());
      print("Journal saved locally and will sync later.");
    } else {
      throw Exception("Failed to create journal: ${e.response?.statusCode}");
    }
  }
}
@override
Future<void> syncPendingJournals() async {
  final pendingJournals = await AppPreferences.loadPendingJournals();

  if (pendingJournals.isEmpty) {
    print("No pending journals to sync.");
    return;
  }

  print("🔄 Syncing ${pendingJournals.length} pending journals...");

  for (int i = 0; i < pendingJournals.length; i++) {
    try {
      await _httpClient.post(API.journal, data: pendingJournals[i]);
      await AppPreferences.clearPendingJournalAt(i);
      print("Synced journal ${i + 1}/${pendingJournals.length}");
    } on DioException catch (e) {
      print("Failed to sync journal ${i + 1}: ${e.message}");
      break; // stop sync kalau masih offline
    }
  }
}


  @override
  Future<void> updateJournal(JournalModels journal) async {
    try {
      await _httpClient.patch(
        API.journalDetail(journal.entriesId!),
        data: journal.toJson(),
      );
    } on DioException catch (e) {
      print("⚠️ Dio Error (updateJournal): ${e.message}");
      throw Exception("Failed to update journal: ${e.response?.statusCode}");
    }
  }

  @override
  Future<void> deleteJournal(int id) async {
    try {
      await _httpClient.delete(API.journalDetail(id));
    } on DioException catch (e) {
      print("⚠️ Dio Error (deleteJournal): ${e.message}");
      throw Exception("Failed to delete journal: ${e.response?.statusCode}");
    }
  }
}
