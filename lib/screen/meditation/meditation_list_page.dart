import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:selena/app/components/sejenak_container.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/meditation_models/meditation_models.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/meditation/meditation_service.dart';
import 'package:selena/session/user_session.dart';

class MeditationListPage extends StatefulWidget {
  final UserModels? user;

  MeditationListPage({super.key}) : user = UserSession().user;

  @override
  State<MeditationListPage> createState() => _MeditationListPageState();
}

class _MeditationListPageState extends State<MeditationListPage> {
  late MeditationService service;
  bool isServiceReady = false;
  bool isLoading = true;
  String? errorMessage;
  List<MeditationModels> meditationAudios = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    try {
      service = await MeditationService.create();
      setState(() {
        isServiceReady = true;
      });
      await _fetchMeditationAudios();
    } catch (e) {
      print('❌ Error initializing service: $e');
      setState(() {
        errorMessage = "Gagal menginisialisasi layanan audio";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMeditationAudios() async {
    try {
      final result = await service.getAudios();
      setState(() {
        meditationAudios = result;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching meditation audios: $e');
      setState(() {
        errorMessage = "Gagal memuat daftar meditasi";
        isLoading = false;
      });
    }
  }

  List<MeditationModels> get filteredAudios {
    if (searchQuery.isEmpty) {
      return meditationAudios;
    }
    return meditationAudios.where((audio) {
      return audio.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          audio.category.toLowerCase().contains(searchQuery.toLowerCase());
          // (audio.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Meditasi",
              profile: user?.user?.profil,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSearchSection(),
          ),
          _buildMeditationList(),
        ],
      ),
      endDrawer: SejenakSidebar(user: user),
      bottomNavigationBar: SejenakNavbar(index: 2),
    );
  }

  Widget _buildSearchSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Focus(
          onFocusChange: (hasFocus) {},
          child: TextField(
            cursorColor: SejenakColor.primary,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Cari meditasi...",
              hintStyle: TextStyle(
                color: SejenakColor.stroke.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 4),
                decoration: BoxDecoration(
                  color: SejenakColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.search, color: SejenakColor.primary.withOpacity(0.8)),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildMeditationList() {
    if (!isServiceReady || isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                CircularProgressIndicator(color: SejenakColor.primary),
                const SizedBox(height: 16),
                SejenakText(
                  text: "Memuat audio meditasi...",
                  type: SejenakTextType.small,
                  color: SejenakColor.stroke,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              SejenakText(
                text: "Gagal memuat data meditasi",
                type: SejenakTextType.h5,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              SejenakText(
                text: errorMessage!,
                type: SejenakTextType.small,
                color: SejenakColor.stroke,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMeditationAudios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SejenakColor.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredAudios.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.audiotrack_rounded, size: 48, color: SejenakColor.stroke),
              const SizedBox(height: 16),
              SejenakText(
                text: searchQuery.isEmpty ? "Belum ada audio meditasi" : "Tidak ditemukan",
                type: SejenakTextType.h5,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              SejenakText(
                text: searchQuery.isEmpty 
                  ? "Audio meditasi akan segera tersedia"
                  : "Coba kata kunci lain",
                type: SejenakTextType.small,
                color: SejenakColor.stroke,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final audio = filteredAudios[index];
          return _buildAudioItem(audio, index);
        },
        childCount: filteredAudios.length,
      ),
    );
  }

 Widget _buildAudioItem(MeditationModels audio, int index) {
  return StreamBuilder<MediaItem?>(
    stream: service.mediaItemStream,
    builder: (context, mediaSnapshot) {
      final currentMediaItem = mediaSnapshot.data;
      final isCurrentAudio = currentMediaItem?.id?.contains(audio.filePath) ?? false;

      return StreamBuilder<PlaybackState>(
        stream: service.playbackState,
        builder: (context, stateSnapshot) {
          final playbackState = stateSnapshot.data;
          final isPlaying = playbackState?.playing ?? false;
          final isCurrentPlaying = isCurrentAudio && isPlaying;
          final isLoading = playbackState?.processingState == AudioProcessingState.loading ||
              playbackState?.processingState == AudioProcessingState.buffering;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                
                color: isCurrentAudio
                    ? SejenakColor.secondary.withOpacity(0.1)
                    : Colors.white,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 12,
                //     offset: const Offset(0, 5),
                //   ),
                // ],
                border: Border.all(
                  color: isCurrentPlaying
                      ? SejenakColor.stroke.withOpacity(0.3)
                      : SejenakColor.secondary.withOpacity(0.3),
                  width: 1.4,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (isCurrentAudio && isPlaying) {
                      await service.pauseAudio();
                    } else if (isCurrentAudio && !isPlaying) {
                      await service.resumeAudio();
                    } else {
                      await service.playAudio(audio);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // === ICON CONTAINER ===
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCurrentPlaying
                                  ? [
                                      SejenakColor.primary,
                                      SejenakColor.primary.withOpacity(0.8)
                                    ]
                                  : [
                                      SejenakColor.light,
                                      SejenakColor.light.withOpacity(0.9)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: SejenakColor.primary.withOpacity(
                                    isCurrentPlaying ? 0.3 : 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim,
                                child: child,
                              ),
                              child: isCurrentPlaying
                                  ? const Icon(Icons.equalizer_rounded,
                                      key: ValueKey('equalizer'),
                                      color: Colors.white,
                                      size: 30)
                                  : SvgPicture.asset(
                                      'assets/svg/icon.svg',
                                      key: const ValueKey('svg'),
                                      width: 28,
                                      height: 28,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        // === CONTENT ===
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SejenakText(
                                text: audio.title,
                                type: SejenakTextType.h5,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
                              if (audio.category.isNotEmpty)
                                SejenakText(
                                  text: "Sesi ${audio.category}",
                                  type: SejenakTextType.small,
                                  color: SejenakColor.stroke,
                                ),
                              if (isLoading) ...[
                                const SizedBox(height: 10),
                                const LinearProgressIndicator(
                                  color: SejenakColor.primary,
                                  backgroundColor: SejenakColor.light,
                                  minHeight: 3,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // === CONTROL BUTTONS ===
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCurrentAudio && isLoading
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    backgroundColor: SejenakColor.light,
                                    color: SejenakColor.primary,
                                  ),
                                )
                              : isCurrentPlaying
                                  ? Row(
                                      key: const ValueKey('playing'),
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.pause_rounded,
                                              color: Colors.black87, size: 30),
                                          onPressed: () => service.pauseAudio(),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.stop_rounded,
                                              color: Colors.redAccent, size: 30),
                                          onPressed: () => service.stopAudio(),
                                        ),
                                      ],
                                    )
                                  : IconButton(
                                      key: const ValueKey('play'),
                                      icon: const Icon(Icons.play_arrow_rounded,
                                          color: Colors.black87, size: 32),
                                      onPressed: () {
                                        service.playAudio(audio);
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  
  
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}