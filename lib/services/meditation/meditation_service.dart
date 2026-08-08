import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:selena/app/helper/get_local_assets_url.dart';
import 'package:selena/models/meditation_models/meditation_models.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/audio/audio_initializer/audio_initializer.dart';

class MeditationService {
  final DioHttpClient _httpClient = DioHttpClient.getInstance();
  late final AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  MeditationService._();

  /// Factory method untuk membuat instance dan inisialisasi audio handler
  static Future<MeditationService> create() async {
    final service = MeditationService._();
    await service._initialize();
    print('✅ MeditationService initialized with audio_service');
    return service;
  }
  AudioHandler get audioHandler => AudioInitializer.handler;

  Future<void> _initialize() async {
    _audioPlayer = AudioPlayer();

    // Inisialisasi AudioHandler
    // audioHandler = await AudioService.init(
    //   builder: () => _SejenakAudioHandler(_audioPlayer),
    //   config: const AudioServiceConfig(
    //     androidNotificationChannelId: 'com.sejenak.meditation.channel',
    //     androidNotificationChannelName: 'Meditation Audio',
    //     androidNotificationOngoing: true,
    //     androidStopForegroundOnPause: true,
    //   ),
    // );

    _isInitialized = true;
  }

  /// Ambil list audio meditation dari API
  Future<List<MeditationModels>> getAudios() async {
    try {
      final response = await _httpClient.get(API.meditationAudios);
      if (response.statusCode == 200) {
        final List<dynamic> audiosData = response.data['data'];
        return audiosData
            .map((json) => MeditationModels.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load audios');
      }
    } catch (e) {
      print('❌ Error in getAudios(): $e');
      rethrow;
    }
  }

  /// Ambil daily meditation dari API
  Future<MeditationModels?> getDailyMeditation() async {
    try {
      final response = await _httpClient.get(API.meditationDaily);
      if (response.statusCode == 200 &&
          (response.data['status'] == 'success' ||
              response.data['success'] == true)) {
        final data = response.data['data'];
        return MeditationModels.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load daily data');
      }
    } catch (e) {
      print('❌ Error in getDailyMeditation(): $e');
      rethrow;
    }
  }

  /// Mainkan audio meditation dengan notifikasi aktif
  Future<void> playAudio(MeditationModels model) async {
    if (!_isInitialized) throw Exception('Service belum siap');

    final String audioUrl = "${API.endpointImage}storage/${model.filePath}";
    print('🎧 Playing meditation audio from: $audioUrl');
final artUri = await getLocalAssetImageUri('assets/splash/splash.png');

    final mediaItem = MediaItem(
      id: audioUrl,
      title: model.title,
      artist: "Meditation Daily",
      artUri: artUri,
    );

    await audioHandler.updateMediaItem(mediaItem);
    await audioHandler.playMediaItem(mediaItem);
  }

  Future<void> pauseAudio() async => await audioHandler.pause();
  Future<void> resumeAudio() async => await audioHandler.play();
  Future<void> stopAudio() async => await audioHandler.stop();

  Future<void> seekAudio(Duration position) async =>
      await audioHandler.seek(position);

  /// ✅ Stream untuk UI update
  Stream<PlaybackState> get playbackState => audioHandler.playbackState;
  Stream<MediaItem?> get mediaItemStream => audioHandler.mediaItem;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

/// ✅ Custom AudioHandler (menghubungkan just_audio ke audio_service)
class _SejenakAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  _SejenakAudioHandler(this._player) {
    // Update playback state ke audio_service
    _player.playerStateStream.listen((state) {
      final processingState = _translateProcessingState(state.processingState);

      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        processingState: processingState,
        controls: [
          MediaControl.pause,
          MediaControl.stop,
        ],
      ));
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _player.setUrl(mediaItem.id);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  AudioProcessingState _translateProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
