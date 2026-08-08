import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:screen_state/screen_state.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:convert';

class SensorData {
  final double sleepHours;
  final double deepSleepHours;
  final double screenOnHours;
  final int lateNightScreenMinutes;
  final int stepCount;
  final int activeMinutes;
  final DateTime date;

  SensorData({
    required this.sleepHours,
    required this.deepSleepHours,
    required this.screenOnHours,
    required this.lateNightScreenMinutes,
    required this.stepCount,
    required this.activeMinutes,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().split('T')[0],
    'sleep_hours': sleepHours,
    'deep_sleep_hours': deepSleepHours,
    'screen_on_hours': screenOnHours,
    'late_night_screen_minutes': lateNightScreenMinutes,
    'step_count': stepCount,
    'active_minutes': activeMinutes,
  };

  factory SensorData.empty() => SensorData(
    sleepHours: 0,
    deepSleepHours: 0,
    screenOnHours: 0,
    lateNightScreenMinutes: 0,
    stepCount: 0,
    activeMinutes: 0,
    date: DateTime.now(),
  );
}

class SensorService {
  final Health _health = Health();
  final Screen _screenState = Screen();
  
  StreamSubscription<StepCount>? _pedometerSub;
  StreamSubscription<ScreenStateEvent>? _screenSub;
  
  int _currentSteps = 0;
  int _currentActiveMinutes = 0;
  double _currentScreenOnHours = 0;
  int _currentLateNightMinutes = 0;
  
  final StreamController<SensorData> _sensorStreamController = 
      StreamController<SensorData>.broadcast();
  
  Stream<SensorData> get sensorStream => _sensorStreamController.stream;

  Future<bool> requestPermissions() async {
    final healthStatus = await _health.requestAuthorization([
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.STEPS,
      HealthDataType.EXERCISE_TIME,
    ]);
    return healthStatus;
  }

  Future<void> startListening() async {
    await _startPedometer();
    await _startScreenState();
  }

  Future<void> _startPedometer() async {
    try {
      _pedometerSub = Pedometer.stepCountStream.listen(
        (StepCount event) {
          _currentSteps = event.steps;
        },
        onError: (error) {
          print('Pedometer error: $error');
        },
      );
    } catch (e) {
      print('Failed to start pedometer: $e');
    }
  }

  Future<void> _startScreenState() async {
    try {
      _screenSub = _screenState.screenStateStream?.listen(
        (ScreenStateEvent event) {
          _handleScreenEvent(event);
        },
        onError: (error) {
          print('Screen state error: $error');
        },
      );
    } catch (e) {
      print('Failed to start screen state: $e');
    }
  }

  void _handleScreenEvent(ScreenStateEvent event) {
    final now = DateTime.now();
    if (event == ScreenStateEvent.SCREEN_ON) {
      _currentScreenOnHours += 0.0167;
    } else if (event == ScreenStateEvent.SCREEN_OFF) {
      if (now.hour >= 22 || now.hour < 5) {
        _currentLateNightMinutes += 1;
      }
    }
    _saveScreenDataToCache();
  }

  void _saveScreenDataToCache() {
    try {
      final screenData = {
        'screen_on_hours': _currentScreenOnHours,
        'late_night_screen_minutes': _currentLateNightMinutes,
      };
      final box = Hive.box('sensor_cache');
      box.put('screen_cache', jsonEncode(screenData));
    } catch (e) {
      print('Failed to save screen data to cache: $e');
    }
  }

  Future<double> getSleepHours() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      
      final types = [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_DEEP];
      
      bool granted = await _health.requestAuthorization(types);
      if (!granted) return 0;
      
      final sleepData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );
      
      double totalSleep = 0;
      double deepSleep = 0;
      
      for (var data in sleepData) {
        final val = data.value;
        double numVal = (val is NumericHealthValue) ? val.numericValue.toDouble() : 0.0;
        if (data.type == HealthDataType.SLEEP_ASLEEP) {
          totalSleep += numVal;
        } else if (data.type == HealthDataType.SLEEP_DEEP) {
          deepSleep += numVal;
        }
      }
      
      final combinedSleep = totalSleep + deepSleep;
      return combinedSleep > 0 ? combinedSleep : 0;
    } catch (e) {
      print('Failed to get sleep data: $e');
      return 0;
    }
  }

  Future<int> getActiveMinutes() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      bool granted = await _health.requestAuthorization([HealthDataType.EXERCISE_TIME]);
      if (!granted) return 0;
      
      final activeData = await _health.getHealthDataFromTypes(
        startTime: today,
        endTime: now,
        types: [HealthDataType.EXERCISE_TIME],
      );
      
      int totalMinutes = 0;
      for (var data in activeData) {
        final val = data.value;
        if (val is NumericHealthValue) {
          totalMinutes += val.numericValue.toInt();
        }
      }
      return totalMinutes;
    } catch (e) {
      print('Failed to get active minutes: $e');
      return 0;
    }
  }

  Future<SensorData> collectSensorData() async {
    final sleepHours = await getSleepHours();
    final activeMinutes = await getActiveMinutes();
    
    return SensorData(
      sleepHours: sleepHours,
      deepSleepHours: sleepHours * 0.3,
      screenOnHours: _currentScreenOnHours,
      lateNightScreenMinutes: _currentLateNightMinutes,
      stepCount: _currentSteps,
      activeMinutes: activeMinutes,
      date: DateTime.now(),
    );
  }

  void resetDailyCounters() {
    _currentScreenOnHours = 0;
    _currentLateNightMinutes = 0;
    _currentSteps = 0;
    _currentActiveMinutes = 0;
  }

  void stopListening() {
    _pedometerSub?.cancel();
    _screenSub?.cancel();
    _sensorStreamController.close();
  }
}
