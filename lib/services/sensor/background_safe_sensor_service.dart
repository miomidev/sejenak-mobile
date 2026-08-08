import 'package:health/health.dart';
import 'dart:async';

class BackgroundSensorData {
  final double sleepHours;
  final int stepCount;
  final int activeMinutes;
  final DateTime date;

  BackgroundSensorData({
    required this.sleepHours,
    required this.stepCount,
    required this.activeMinutes,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().split('T')[0],
    'sleep_hours': sleepHours,
    'step_count': stepCount,
    'active_minutes': activeMinutes,
  };
}

class BackgroundSafeSensorService {
  final Health _health = Health();

  Future<BackgroundSensorData> collectBackgroundSafeData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = now.subtract(Duration(days: 1));

    final sleepHours = await _getSleepData(yesterday, now);
    final activeMinutes = await _getActiveMinutesData(today, now);
    final stepCount = await _getStepCount(today, now);

    return BackgroundSensorData(
      sleepHours: sleepHours,
      stepCount: stepCount,
      activeMinutes: activeMinutes,
      date: now,
    );
  }

  Future<double> _getSleepData(DateTime start, DateTime end) async {
    try {
      final types = [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_DEEP];
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );
      double total = 0.0;
      for (var d in data) {
        final val = d.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toDouble();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getActiveMinutesData(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.EXERCISE_TIME],
      );
      int total = 0;
      for (var d in data) {
        final val = d.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toInt();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getStepCount(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.STEPS],
      );
      int total = 0;
      for (var d in data) {
        final val = d.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toInt();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}

