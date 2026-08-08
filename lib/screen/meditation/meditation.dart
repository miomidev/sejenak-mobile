import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:selena/app/components/sejenak_container.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/app/partial/main/sejenak_error.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/meditation_models/meditation_models.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/meditation/meditation_service.dart';
import 'package:selena/session/user_session.dart';

class Meditation extends StatefulWidget {
  final UserModels? user;
  
  Meditation({super.key}) : user = UserSession().user;

  @override
  State<Meditation> createState() => _MeditationState();
}

class _MeditationState extends State<Meditation> {
  MeditationModels? dailyMeditation;
  late Future<List<dynamic>> _initializationFuture;
  late MeditationService service;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<List<dynamic>> _initializeData() async {
    try {
      // Initialize service
      service = await MeditationService.create();
      
      // Fetch daily meditation
      final meditation = await service.getDailyMeditation();
      
      return [service, meditation];
    } catch (e) {
      print('❌ Error initializing: $e');
      return [service, null];

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
  future: _initializationFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingState();
    }

    // kalau error, jangan return SejenakError, tapi tampilkan UI dengan state kosong
    if (snapshot.hasError) {
      print("⚠️ Meditation page error: ${snapshot.error}");
      return _buildMainContent(context); // tetap tampil, tapi tanpa data
    }

    if (!snapshot.hasData || snapshot.data!.length < 2) {
      return _buildEmptyState(context);
    }

    service = snapshot.data![0] as MeditationService;
    dailyMeditation = snapshot.data![1] as MeditationModels?;

    return _buildMainContent(context);
  },
),

      endDrawer: SejenakSidebar(user: widget.user),
      bottomNavigationBar: SejenakNavbar(index: 2),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SejenakCircular(),
          SizedBox(height: 16),
          Text('Menyiapkan meditasi...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initializationFuture = _initializeData();
                  });
                },
                child: Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Meditasi",
              profile: widget.user?.user?.avatar,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildWelcomeSection(),
          ),
          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),
          SejenakContainer(
            // padding: const EdgeInsets.all(16),
            child: SejenakText(
              text: "Belum ada meditasi harian untuk hari ini.",
              type: SejenakTextType.small,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SejenakHeaderPage(
            text: "Meditasi",
            profile: widget.user?.user?.avatar,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildWelcomeSection(),
        ),
        SliverToBoxAdapter(
          child: _buildActionButtons(),
        ),
        SliverToBoxAdapter(
          child: _buildDailyMeditation(),
        ),
        SliverToBoxAdapter(
          child: _buildMeditationSummary(),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SejenakContainer(
        child: Row(
          children: [
            const Icon(Icons.self_improvement_rounded, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SejenakText(
                    text: "Selamat Datang di Ruang Meditasi",
                    type: SejenakTextType.h5,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4),
                  SejenakText(
                    text: "Temukan kedamaian dan ketenangan melalui latihan mindfulness",
                    type: SejenakTextType.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              title: "Start Meditation",
              subtitle: "Latihan mindfulness",
              icon: Icons.spa_rounded,
              color: SejenakColor.primary,
              onTap: _navigateToMeditationPage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              title: "Start Exercise",
              subtitle: "Latihan pernapasan",
              icon: Icons.fitness_center_rounded,
              color: SejenakColor.secondary,
              onTap: _navigateToExercisePage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 1.0,
          color: color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                SejenakText(
                  text: title,
                  type: SejenakTextType.small,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                SejenakText(
                  text: subtitle,
                  type: SejenakTextType.regular,
                  color: SejenakColor.stroke,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyMeditation() {
    return StreamBuilder<PlaybackState>(
      stream: service.playbackState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;
        final processingState = state?.processingState ?? AudioProcessingState.idle;
        final isLoading = processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering;

        if (dailyMeditation == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: const SejenakContainer(
              // padding: EdgeInsets.all(16),
              child: SejenakText(
                text: "Belum ada meditasi harian untuk hari ini.",
                type: SejenakTextType.small,
              ),
            ),
          );
        }

        final title = dailyMeditation!.title;
        final desc = "Nikmati sesi ${dailyMeditation!.category} hari ini";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              color: SejenakColor.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1.0,
                color: SejenakColor.secondary.withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: SejenakColor.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SejenakText(
                            text: title,
                            type: SejenakTextType.h5,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          SejenakText(
                            text: desc,
                            type: SejenakTextType.small,
                            color: SejenakColor.stroke,
                          ),
                          if (isLoading) ...[
                            const SizedBox(height: 8),
                            const LinearProgressIndicator(
                              color: SejenakColor.secondary, 
                              backgroundColor: SejenakColor.light,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          backgroundColor: SejenakColor.light,
                          color: SejenakColor.secondary,
                        ),
                      )
                    else if (isPlaying)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.pause_rounded,
                                color: Colors.black54, size: 30),
                            onPressed: () => service.pauseAudio(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop_rounded,
                                color: Colors.redAccent, size: 30),
                            onPressed: () => service.stopAudio(),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: Colors.black54, size: 30),
                        onPressed: () {
                          if (dailyMeditation != null) {
                            service.playAudio(dailyMeditation!);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeditationSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SejenakText(
        text: "Ringkasan Meditasi (coming soon...)",
        type: SejenakTextType.small,
        color: SejenakColor.stroke,
      ),
    );
  }

  void _navigateToMeditationPage() {
    print('Navigate to meditation page');
    Navigator.pushReplacementNamed(context, '/meditation-list-page');
  }

  void _navigateToExercisePage() {
    print('Navigate to exercise page');
    // TODO: Implement navigation
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}