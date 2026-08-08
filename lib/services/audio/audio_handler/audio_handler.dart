import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class SejenakAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  SejenakAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _notifyAudioHandlerAboutPlaybackEvents() async {
  _player.playbackEventStream.listen((PlaybackEvent event) {
    final bool isPlaying = _player.playing;
    
    // Mapping processing state
    final AudioProcessingState audioProcessingState = 
        _mapProcessingState(_player.processingState);
    
    // Mapping repeat mode
    final AudioServiceRepeatMode repeatMode = 
        _player.loopMode == LoopMode.one 
            ? AudioServiceRepeatMode.one 
            : AudioServiceRepeatMode.none;

    // Build controls based on play state
    final List<MediaControl> controls = [
      MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
      MediaControl.skipToNext,
    ];

    // Create playback state
    final PlaybackState newPlaybackState = playbackState.value.copyWith(
      // Controls
      controls: controls,
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      
      // Playback status
      processingState: audioProcessingState,
      repeatMode: repeatMode,
      playing: isPlaying,
      
      // Position & speed
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      
      // Queue
      queueIndex: event.currentIndex,
    );

    // Update playback state
    playbackState.add(newPlaybackState);
  });
}

/// Helper method to map ProcessingState to AudioProcessingState
AudioProcessingState _mapProcessingState(ProcessingState state) {
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

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  // ✅ TAMBAHKAN METHOD INI - untuk handle playMediaItem dari MeditationService
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    try {
      print('🎵 playMediaItem called: ${mediaItem.title}');
      print('🔗 URL: ${mediaItem.id}');
      
      // Stop player jika sedang memutar
      await _player.stop();
      
      // Set audio source dari URL
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(mediaItem.id),
          tag: mediaItem,
        ),
      );
      
      // Update media item
      this.mediaItem.add(mediaItem);
      
      // Mulai memutar
      await _player.play();
      
      print('✅ Audio started playing');
    } catch (e) {
      print('❌ Error in playMediaItem: $e');
      rethrow;
    }
  }

  // ✅ TAMBAHKAN METHOD INI - untuk handle updateMediaItem
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  // Method tambahan untuk play dari URL langsung
  Future<void> playFromUrl(String url, String title) async {
    try {
      final mediaItem = MediaItem(
        id: url,
        title: title,
        artist: "Sejenak",
        artUri: Uri.parse("https://example.com/meditation.jpg"),
      );
      await playMediaItem(mediaItem);
    } catch (e) {
      print('❌ Error playing audio: $e');
      throw e;
    }
  }

  // ✅ TAMBAHKAN method untuk debugging
  void printPlayerState() {
    print('🎵 Player State:');
    print('   - Playing: ${_player.playing}');
    print('   - Processing State: ${_player.processingState}');
    print('   - Duration: ${_player.duration}');
    print('   - Position: ${_player.position}');
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    return super.onTaskRemoved();
  }

  @override
  Future<void> onClose() async {
    return _player.dispose();
  }
}