import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_calendar.dart';
import 'package:selena/app/components/sejenak_floating_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/journal/sejenak_journal.dart';
import 'package:selena/app/partial/journal/sejenak_journal_list.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/app/partial/main/sejenak_error.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/journal_models/journal_models.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/journal/journal.dart';
import 'package:selena/services/local/app_preferences.dart';
import 'package:selena/session/user_session.dart';

class Journal extends StatefulWidget {
  @override
  _JournalState createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  final UserModels? user = UserSession().user;
  final JournalApiService journalService = JournalApiService();
  late Future<List<JournalModels>> result;
  List<JournalModels> _journals = [];

  @override
  void initState() {
    super.initState();
    _loadCachedThenRemote();
  }

  void _loadJournals() {
    setState(() {
      result = journalService.getAllJournal();
    });
  }

  void _loadCachedThenRemote() async {
    List<JournalModels> localJournals =
        await journalService.getAllLocalAndPendingJournal();

    if (localJournals.isNotEmpty) {
      setState(() {
        _journals = localJournals;
        result = Future.value(localJournals);
      });
    }

    final fetched = journalService.getAllLocalAndPendingJournal();

    fetched.then((fetchedJournals) async {
      setState(() {
        _journals = fetchedJournals;
        result = Future.value(fetchedJournals);
      });

      // Simpan ke cache
      await AppPreferences.saveModelList<JournalModels>(
        'cached_journals',
        fetchedJournals,
      );

      final refreshedPending = await AppPreferences.loadPendingJournals();
      final refreshedPendingModels =
          refreshedPending.map((e) => JournalModels.fromJson(e)).toList();

      if (refreshedPendingModels.isNotEmpty) {
        setState(() {
          _journals = [..._journals, ...refreshedPendingModels];
        });
      }
    }).catchError((e) {
      if (localJournals.isEmpty) {
        setState(() {
          result = Future.error(e);
        });
      }
    });
  }

  void _deleteJournalFromList(int journalId) {
    setState(() {
      _journals.removeWhere((journal) => journal.entriesId == journalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<JournalModels>>(
        future: result,
        builder: (context, snapshot) {
          print("Connection: ${snapshot.connectionState}");
          print("Has Data: ${snapshot.hasData}");
          print("Data: ${snapshot.data}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          List<JournalModels> journals = snapshot.data!;
          return _buildJournalList(journals, context);
        },
      ),
      floatingActionButton: SejenakFloatingButton(
        onPressed: () =>
            SejenakJournal(onJournalSaved: _loadJournals).showEditMode(context),
      ),
      endDrawer: SejenakSidebar(user: user),
      bottomNavigationBar: SejenakNavbar(index: 3),
    );
  }

  Widget _buildLoadingState() {
    final String? profileImage = user?.user?.avatar;

    return Column(
      children: [
        SejenakHeaderPage(
          text: "Journal",
          profile: profileImage,
        ),
        Expanded(
          child: Center(child: SejenakCircular()),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    final String? profileImage = user?.user?.avatar;

    return Column(
      children: [
        SejenakHeaderPage(
          text: "Journal",
          profile: profileImage,
        ),
        Expanded(
          child: SejenakError(message: error),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final String? profileImage = user?.user?.avatar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SejenakHeaderPage(
          text: "Journal",
          profile: profileImage,
        ),

        // Calendar Section dengan container
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          child: SejenakCalendar(),
        ),

        Expanded(
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 64,
                    color: SejenakColor.stroke.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  SejenakText(
                    text: "Belum Ada Journal",
                    type: SejenakTextType.h5,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  SejenakText(
                    text:
                        "Mulai tulis journal pertamamu untuk merefleksikan hari-harimu",
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: SejenakColor.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => SejenakJournal(
                          onJournalSaved: _loadJournals,
                        ).showEditMode(context),
                        child: Center(
                          child: SejenakText(
                            text: "Tulis Journal Pertama",
                            type: SejenakTextType.regular,
                            color: SejenakColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJournalList(List<JournalModels> journals, BuildContext context) {
    final String? profileImage = user?.user?.avatar;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SejenakHeaderPage(
            text: "Journal",
            profile: profileImage,
          ),
        ),

        // Journal Stats
        SliverToBoxAdapter(
          child: _buildJournalStats(journals),
        ),

        // Journal List Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SejenakText(
                  text: "Journal Saya",
                  type: SejenakTextType.h5,
                  fontWeight: FontWeight.bold,
                ),
                SejenakText(
                  text: "${journals.length} Entri",
                  type: SejenakTextType.small,
                  color: SejenakColor.stroke,
                ),
              ],
            ),
          ),
        ),

        // Journal List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final journal = journals[index];
              final int? journalId = journal.entriesId;
              final String title = journal.title ?? 'Tanpa Judul';
              final String content = journal.content ?? 'Tanpa Konten';
              final String? createdAt = journal.createdAt;

              return Padding(
                key: ValueKey('journal_$journalId'),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Container(
                  child: SejenakJournalList(
                    title: title,
                    text: content,
                    action: () async {
                      if (journalId != null) {
                        SejenakJournal(
                          id: journalId,
                          initialTitle: journal.title,
                          initialContent: journal.content,
                        ).showJournalView(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Journal ID tidak valid"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    onEdit: () async {
                      if (journalId != null) {
                        SejenakJournal(
                          id: journalId,
                          initialTitle: journal.title,
                          initialContent: journal.content,
                          onJournalSaved: _loadJournals,
                        ).showEditMode(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Tidak dapat mengedit journal tanpa ID"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    onDelete: () async {
                      if (journalId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Tidak dapat menghapus journal tanpa ID"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Hapus Journal"),
                          content: Text(
                              "Apakah Anda yakin ingin menghapus journal ini?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Hapus",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await journalService.deleteJournal(journalId);
                          _deleteJournalFromList(journalId);
                          print("Journal deleted");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Journal berhasil dihapus"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal menghapus journal: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
            childCount: journals.length,
          ),
        ),
      ],
    );
  }

  Widget _buildJournalStats(List<JournalModels> journals) {
    // Hitung statistik dengan null safety
    int totalJournals = journals.length;

    int thisMonth = DateTime.now().month;
    int monthlyJournals = journals.where((journal) {
      if (journal.createdAt == null) return false;
      try {
        DateTime journalDate = DateTime.parse(journal.createdAt!);
        return journalDate.month == thisMonth;
      } catch (e) {
        return false;
      }
    }).length;

    // Handle null untuk journal streak
    int journalStreak = user?.journalStreak ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              value: totalJournals.toString(),
              label: "Total Journal",
              icon: Icons.library_books_rounded,
            ),
            _buildStatItem(
              value: monthlyJournals.toString(),
              label: "Bulan Ini",
              icon: Icons.calendar_today_rounded,
            ),
            _buildStatItem(
              value: journalStreak.toString(),
              label: "Streak",
              icon: Icons.local_fire_department_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: SejenakColor.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SejenakColor.secondary),
          ),
          child: Icon(
            icon,
            size: 24,
            color: SejenakColor.secondary,
          ),
        ),
        SizedBox(height: 8),
        SejenakText(
          text: value,
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
        ),
        SejenakText(
          text: label,
          type: SejenakTextType.small,
          color: SejenakColor.stroke,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getMoodFromJournal(JournalModels journal) {
    // Logic untuk menentukan mood dari journal dengan null safety
    final String? content = journal.content;
    if (content == null) return '😐';

    final String contentLower = content.toLowerCase();

    if (contentLower.contains('senang') ||
        contentLower.contains('bahagia') ||
        contentLower.contains('gembira')) {
      return '😊';
    } else if (contentLower.contains('sedih') ||
        contentLower.contains('kecewa') ||
        contentLower.contains('pilu')) {
      return '😔';
    } else if (contentLower.contains('marah') ||
        contentLower.contains('kesal') ||
        contentLower.contains('jengkel')) {
      return '😠';
    } else {
      return '😐';
    }
  }
}
