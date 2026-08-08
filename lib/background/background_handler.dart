import 'dart:convert';
import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/sensor/background_safe_sensor_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Hive.initFlutter();
    
    final sensorBox = await Hive.openBox('sensor_cache');
    
    switch (task) {
      case 'sensor_sync':
        await _handleSensorSync(sensorBox);
        break;
      case 'journal_sync':
        await _handleJournalSync();
        break;
      case 'full_sync':
        await _handleSensorSync(sensorBox);
        await _handleJournalSync();
        break;
      case Workmanager.iOSBackgroundTask:
        await _handleIOSBackgroundFetch(sensorBox);
        break;
      default:
        print('Background task unknown: $task');
        break;
    }
    
    return Future.value(true);
  });
}

Future<void> _handleSensorSync(Box sensorBox) async {
  try {
    final sensorService = BackgroundSafeSensorService();
    final sensorData = await sensorService.collectBackgroundSafeData();
    
    final pendingList = _getPendingData(sensorBox);
    final screenData = _getScreenDataFromCache(sensorBox);
    
    final fullData = {
      'date': sensorData.date.toIso8601String().split('T')[0],
      'sleep_hours': sensorData.sleepHours,
      'deep_sleep_hours': sensorData.sleepHours * 0.3,
      'screen_on_hours': screenData['screen_on_hours'] ?? 0,
      'late_night_screen_minutes': screenData['late_night_screen_minutes'] ?? 0,
      'step_count': sensorData.stepCount,
      'active_minutes': sensorData.activeMinutes,
      'calendar_events_count': 0,
    };
    
    pendingList.add(fullData);
    await sensorBox.put('pending_sensor_data', jsonEncode(pendingList));
    
    await _syncPendingData(sensorBox);
    
    await sensorBox.put('last_background_sync', DateTime.now().toIso8601String());
    
    print('Background sensor sync completed: ${sensorData.date}');
  } catch (e) {
    print('Background sensor sync error: $e');
  }
}

Future<void> _handleJournalSync() async {
  try {
    print('Background journal sync triggered');
  } catch (e) {
    print('Background journal sync error: $e');
  }
}

Future<void> _handleIOSBackgroundFetch(Box sensorBox) async {
  try {
    await _syncPendingData(sensorBox);
    print('iOS background fetch completed');
  } catch (e) {
    print('iOS background fetch error: $e');
  }
}

List<Map<String, dynamic>> _getPendingData(Box sensorBox) {
  final data = sensorBox.get('pending_sensor_data');
  if (data == null) return [];
  final decoded = jsonDecode(data);
  return List<Map<String, dynamic>>.from(decoded);
}

Map<String, dynamic> _getScreenDataFromCache(Box sensorBox) {
  final data = sensorBox.get('screen_cache');
  if (data == null) return {};
  return jsonDecode(data);
}

Future<void> _syncPendingData(Box sensorBox) async {
  final pendingList = _getPendingData(sensorBox);
  if (pendingList.isEmpty) return;
  
  final dio = Dio(BaseOptions(
    baseUrl: API.endpoint,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  
  final List<int> successfulIndexes = [];
  
  for (int i = 0; i < pendingList.length; i++) {
    try {
      final response = await dio.post(
        '/v2/human-capacity/sync-sensors',
        data: pendingList[i],
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        successfulIndexes.add(i);
        print('Synced sensor data for ${pendingList[i]['date']}');
      }
    } on DioException catch (e) {
      print('Failed to sync: ${e.message}');
      break;
    } catch (e) {
      print('Unexpected sync error: $e');
    }
  }
  
  for (int i = successfulIndexes.length - 1; i >= 0; i--) {
    pendingList.removeAt(successfulIndexes[i]);
  }
  
  await sensorBox.put('pending_sensor_data', jsonEncode(pendingList));
}
