import 'package:hive/hive.dart';
import 'sensor_service.dart';

class SensorCache {
  static const String _boxName = 'sensor_cache';
  static const String _pendingKey = 'pending_sensor_data';
  
  late Box _box;
  
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }
  
  Future<void> savePendingSensorData(SensorData data) async {
    final pendingList = getPendingSensorData();
    pendingList.add(data.toJson());
    await _box.put(_pendingKey, pendingList);
  }
  
  List<Map<String, dynamic>> getPendingSensorData() {
    final data = _box.get(_pendingKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<void> removePendingSensorData(int index) async {
    final pendingList = getPendingSensorData();
    if (index < pendingList.length) {
      pendingList.removeAt(index);
      await _box.put(_pendingKey, pendingList);
    }
  }
  
  Future<void> clearPendingSensorData() async {
    await _box.delete(_pendingKey);
  }
  
  int get pendingCount => getPendingSensorData().length;
  
  Future<void> saveLastSyncTime(DateTime time) async {
    await _box.put('last_sync_time', time.toIso8601String());
  }
  
  DateTime? getLastSyncTime() {
    final timeStr = _box.get('last_sync_time');
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }
  
  Future<void> saveDailySteps(int steps) async {
    await _box.put('daily_steps', steps);
  }
  
  int get dailySteps => _box.get('daily_steps') ?? 0;

  Future<void> saveScreenData(double screenOnHours, int lateNightMinutes) async {
    final screenData = {
      'screen_on_hours': screenOnHours,
      'late_night_screen_minutes': lateNightMinutes,
    };
    await _box.put('screen_cache', screenData);
  }
  
  Map<String, dynamic> getScreenData() {
    final data = _box.get('screen_cache');
    if (data == null) return {'screen_on_hours': 0, 'late_night_screen_minutes': 0};
    return Map<String, dynamic>.from(data);
  }

  Future<void> saveLastBackgroundSync(DateTime time) async {
    await _box.put('last_background_sync', time.toIso8601String());
  }
  
  DateTime? getLastBackgroundSync() {
    final timeStr = _box.get('last_background_sync');
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }
}
