import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:selena/services/api.dart';
import 'package:selena/session/user_session.dart';
import 'sensor_service.dart';
import 'sensor_cache.dart';

class SensorSyncService {
  final SensorService _sensorService;
  final SensorCache _sensorCache;
  final DioHttpClient _httpClient = DioHttpClient.getInstance();
  Timer? _periodicTimer;
  bool _isSyncing = false;
  
  static const int _syncIntervalMinutes = 60;
  
  SensorSyncService({
    required SensorService sensorService,
    required SensorCache sensorCache,
  }) : _sensorService = sensorService,
       _sensorCache = sensorCache;
  
  Future<void> init() async {
    await _sensorCache.init();
    _setupConnectivityListener();
  }
  
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.last : ConnectivityResult.none;
      if (result != ConnectivityResult.none) {
        syncPendingData();
      }
    });
  }
  
  void startPeriodicSync() {
    _periodicTimer = Timer.periodic(
      Duration(minutes: _syncIntervalMinutes),
      (_) => syncNow(),
    );
  }
  
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
  }
  
  Future<void> syncNow() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      final sensorData = await _sensorService.collectSensorData();
      await _sensorCache.savePendingSensorData(sensorData);
      await syncPendingData();
    } catch (e) {
      print('Error syncing sensor data: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> syncPendingData() async {
    final token = UserSession().user?.token;
    if (token == null || token.isEmpty) return;
    
    final pendingData = _sensorCache.getPendingSensorData();
    if (pendingData.isEmpty) return;
    
    _httpClient.setToken(token);
    
    final List<int> successfulIndexes = [];
    
    for (int i = 0; i < pendingData.length; i++) {
      try {
        final data = pendingData[i];
        final response = await _httpClient.post(
          '${API.endpoint}/v2/human-capacity/sync-sensors',
          data: data,
        );
        
        if (response.statusCode == 200) {
          successfulIndexes.add(i);
          print('Synced sensor data for ${data['date']}');
        }
      } on DioException catch (e) {
        print('Failed to sync sensor data: ${e.message}');
        if (e.response?.statusCode == 401) {
          break;
        }
      } catch (e) {
        print('Unexpected error syncing: $e');
      }
    }
    
    for (int i = successfulIndexes.length - 1; i >= 0; i--) {
      await _sensorCache.removePendingSensorData(successfulIndexes[i]);
    }
    
    await _sensorCache.saveLastSyncTime(DateTime.now());
  }
  
  Future<void> forceSyncToday() async {
    final sensorData = await _sensorService.collectSensorData();
    await _sensorCache.savePendingSensorData(sensorData);
    await syncPendingData();
  }
  
  int get pendingCount => _sensorCache.pendingCount;
  
  DateTime? get lastSyncTime => _sensorCache.getLastSyncTime();
  
  void dispose() {
    stopPeriodicSync();
    _sensorService.stopListening();
  }
}
