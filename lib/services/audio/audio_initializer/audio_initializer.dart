import 'package:audio_service/audio_service.dart';
import 'package:selena/services/audio/audio_handler/audio_handler.dart';

class AudioInitializer {
  static bool _initializing = false;
  static bool _initialized = false;
  static late AudioHandler handler;

  static Future<void> init() async {
    if (_initialized) {
      print('⚠️ AudioInitializer sudah siap, skip init.');
      return;
    }
    if (_initializing) {
      print('⚠️ AudioInitializer masih berjalan, tunggu selesai...');
      // Tunggu sampai selesai
      while (!_initialized) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      return;
    }

    _initializing = true;
    print('🎧 Memulai AudioInitializer.init()...');

    try {
      handler = await AudioService.init(
        builder: () => SejenakAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.sejenak.selena.channel.audio',
          androidNotificationChannelName: 'Selena Audio',
          androidNotificationOngoing: true,
        ),
      );
      _initialized = true;
      print('✅ AudioService berhasil diinisialisasi');
    } catch (e) {
      print('❌ Error initializing service: $e');
    } finally {
      _initializing = false;
    }
  }
}
