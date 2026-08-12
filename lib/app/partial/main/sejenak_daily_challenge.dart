import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/daily_task/daily_task_service.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/session/user_session.dart';

class DailyChallengeCard extends StatefulWidget {
  const DailyChallengeCard({super.key});

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard> {
  final DailyTaskService _dailyTaskService = DailyTaskService();
  Map<String, dynamic>? _taskData;
  bool _isLoading = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDailyTasks();
  }

  Future<void> _fetchDailyTasks() async {
    setState(() => _isLoading = true);
    var data = await _dailyTaskService.getDailyTasks();
    
    // If no tasks exist for today, generate them automatically
    if (data != null && (data['tasks'] as List).isEmpty) {
      await _dailyTaskService.generateTasks();
      data = await _dailyTaskService.getDailyTasks();
    }
    
    if (mounted) {
      setState(() {
        _taskData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeTask(int taskId) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    
    final result = await _dailyTaskService.completeTask(taskId);
    
    if (mounted) {
      setState(() => _isActionLoading = false);
      if (result != null) {
        // Update user tokens balance locally
        final earned = result['points_earned'] ?? 0;
        final currentBalance = UserSession().user?.user?.tokensBalance ?? 0;
        
        // This is a bit hacky because User is immutable, but we can update the session
        if (UserSession().user?.user != null) {
           final updatedUser = UserSession().user!.user!.copyWith(
             tokensBalance: currentBalance + (earned as num).toInt(),
           );
           final currentModels = UserSession().user!;
           final updatedModels = UserModels(
             code: currentModels.code,
             status: currentModels.status,
             token: currentModels.token,
             refreshToken: currentModels.refreshToken,
             expiresIn: currentModels.expiresIn,
             refreshExpiresIn: currentModels.refreshExpiresIn,
             user: updatedUser,
             totalPost: currentModels.totalPost,
             totalJournal: currentModels.totalJournal,
             totalLike: currentModels.totalLike,
             journalThisMonth: currentModels.journalThisMonth,
             journalStreak: currentModels.journalStreak,
             postStreak: currentModels.postStreak,
           );
           UserSession().setUser(updatedModels);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Challenge Selesai! Kamu mendapatkan $earned Token."),
            backgroundColor: SejenakColor.secondary,
          )
        );
        
        _fetchDailyTasks(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyelesaikan challenge. Coba lagi."))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildContainer(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: SejenakColor.secondary),
          ),
        )
      );
    }

    if (_taskData == null || (_taskData!['tasks'] as List).isEmpty) {
      return _buildContainer(
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: SejenakText(
              text: "Belum ada tantangan hari ini.",
              type: SejenakTextType.regular,
              color: SejenakColor.stroke,
            ),
          ),
        )
      );
    }

    // Find the first pending task
    final tasks = _taskData!['tasks'] as List;
    final pendingTasks = tasks.where((t) => t['status'] != 'completed').toList();
    
    if (pendingTasks.isEmpty) {
      return _buildContainer(
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.stars_rounded, color: SejenakColor.orange, size: 40),
                SizedBox(height: 8),
                SejenakText(
                  text: "Wah hebat! Semua challenge hari ini selesai.",
                  type: SejenakTextType.regular,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      );
    }

    final activeTask = pendingTasks.first;
    final completedCount = tasks.length - pendingTasks.length;
    final totalCount = tasks.length;

    return _buildContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SejenakText(
                  text: "Daily Challenge",
                  type: SejenakTextType.h5,
                  fontWeight: FontWeight.bold,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SejenakColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SejenakColor.secondary),
                  ),
                  child: SejenakText(
                    text: "$completedCount/$totalCount Selesai",
                    type: SejenakTextType.small,
                    fontWeight: FontWeight.bold,
                    color: SejenakColor.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SejenakText(
              text: activeTask['title'] ?? 'Lakukan tantangan ini',
              type: SejenakTextType.regular,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 4),
            SejenakText(
              text: activeTask['description'] ?? '',
              type: SejenakTextType.small,
              color: SejenakColor.stroke,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isActionLoading ? null : () => _completeTask(activeTask['id']),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: SejenakColor.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isActionLoading 
                          ? const SizedBox(
                              width: 20, height: 20, 
                              child: CircularProgressIndicator(color: SejenakColor.primary, strokeWidth: 2)
                            )
                          : const SejenakText(
                              text: "Lakukan Challenge",
                              type: SejenakTextType.regular,
                              color: SejenakColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SejenakColor.light,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SejenakColor.stroke.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          size: 14,
                          color: SejenakColor.orange,
                        ),
                        const SizedBox(width: 2),
                        SejenakText(
                          text: "+${activeTask['points']}",
                          type: SejenakTextType.small,
                          color: SejenakColor.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SejenakColor.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1.0, color: Colors.grey[900]!),
        boxShadow: const [
          BoxShadow(
            color: SejenakColor.black,
            spreadRadius: 0.4,
            blurRadius: 0,
            offset: Offset(0.3, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
