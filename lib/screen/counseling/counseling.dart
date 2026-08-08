import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/chat/sejenak_main_chat.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/screen/chat/chat_bot.dart';
import 'package:selena/session/user_session.dart';

class Counseling extends StatelessWidget {
  final UserModels? mySession;

  Counseling({super.key}) : mySession = UserSession().user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: SejenakColor.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Konseling",
              profile: mySession!.user!.avatar,
            ),
          ),
          
          // Welcome Section
          SliverToBoxAdapter(
            child: _buildWelcomeSection(),
          ),
          
          // Quick Actions
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),
          
          // Counselors List Header
          SliverToBoxAdapter(
            child: _buildCounselorsHeader(),
          ),
          
          // Counselors List
          SliverToBoxAdapter(
            child: _buildCounselorsList(context),
          ),
          
          // Articles Header
          SliverToBoxAdapter(
            child: _buildArticlesHeader(),
          ),
          
          // Articles List
          SliverToBoxAdapter(
            child: _buildArticlesList(),
          ),
        ],
      ),
      endDrawer: SejenakSidebar(user: mySession),
      bottomNavigationBar: SejenakNavbar(index: 4), // Chat/Counseling page
    );
  }

  Widget _buildWelcomeSection() {
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
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.psychology_rounded,
              size: 40,
              color: SejenakColor.secondary,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SejenakText(
                    text: "Ruang Konseling Sejenak",
                    type: SejenakTextType.h5,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4),
                  SejenakText(
                    text: "Temukan dukungan dan bimbingan profesional untuk kesehatan mentalmu",
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
  final actions = [
    {
      'icon': Icons.smart_toy_rounded,
      'title': 'Chat AI',
      'subtitle': 'Konsultasi cepat dengan AI Assistant',
      'color': SejenakColor.secondary,
      'onTap': () {
        ChatBotScreen().showChat(context);
      },
    },
    {
      'icon': Icons.person_rounded,
      'title': 'Chat Konselor',
      'subtitle': 'Ngobrol dengan konselor profesional',
      'color': SejenakColor.primary,
      'onTap': () {
        // Navigasi ke halaman chat konselor (atau modal lain)
        Navigator.pushNamed(context, '/chat-konselor');
      },
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SejenakText(
          text: "Aksi Cepat",
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 10),
        Column(
          children: actions.map((action) {
            return GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SejenakColor.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 1, color: Colors.grey[900]!),
                  boxShadow: const [
                    BoxShadow(
                      color: SejenakColor.black,
                      spreadRadius: 0.3,
                      blurRadius: 0,
                      offset: Offset(0.3, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: action['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        action['icon'] as IconData,
                        color: SejenakColor.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SejenakText(
                            text: action['title'] as String,
                            type: SejenakTextType.h5,
                            fontWeight: FontWeight.bold,
                          ),
                          SejenakText(
                            text: action['subtitle'] as String,
                            type: SejenakTextType.small,
                            color: SejenakColor.stroke,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: SejenakColor.stroke, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}


  Widget _buildCounselorsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SejenakText(
            text: "Konselor Tersedia",
            type: SejenakTextType.h5,
            fontWeight: FontWeight.bold,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SejenakColor.light,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SejenakColor.stroke.withOpacity(0.2)),
            ),
            child: SejenakText(
              text: "12 Online",
              type: SejenakTextType.small,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorsList(BuildContext context) {
    // Dummy data for counselors
    final counselors = [
      {
        'name': 'Dr. Sarah Wijaya, M.Psi',
        'specialization': 'Psikolog Klinis',
        'experience': '8 tahun',
        'rating': '4.9',
        'online': true,
        'image': '',
      },
      {
        'name': 'Budi Santoso, S.Psi',
        'specialization': 'Konselor Remaja',
        'experience': '5 tahun',
        'rating': '4.8',
        'online': true,
        'image': '',
      },
      {
        'name': 'Maya Pertiwi, M.Psi',
        'specialization': 'Terapis Keluarga',
        'experience': '10 tahun',
        'rating': '4.9',
        'online': false,
        'image': '',
      },
      {
        'name': 'Dr. Andi Pratama, Sp.KJ',
        'specialization': 'Psikiater',
        'experience': '12 tahun',
        'rating': '5.0',
        'online': true,
        'image': '',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: counselors.map((counselor) => 
          Container(
            margin: EdgeInsets.only(bottom: 8),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  SejenakMainChat(id: counselors.indexOf(counselor) + 1).showChat(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SejenakColor.light,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: SejenakColor.stroke,
                            ),
                          ),
                          if (counselor['online'] as bool)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: SejenakColor.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SejenakText(
                                  text: counselor['name'] as String,
                                  type: SejenakTextType.regular,
                                  fontWeight: FontWeight.bold,
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    SejenakText(
                                      text: counselor['rating'] as String,
                                      type: SejenakTextType.small,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            SejenakText(
                              text: counselor['specialization'] as String,
                              type: SejenakTextType.small,
                              color: SejenakColor.secondary,
                            ),
                            SizedBox(height: 4),
                            SejenakText(
                              text: "Pengalaman ${counselor['experience'] as String}",
                              type: SejenakTextType.small,
                              color: SejenakColor.stroke,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SejenakColor.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SejenakColor.secondary),
                        ),
                        child: SejenakText(
                          text: "Chat",
                          type: SejenakTextType.small,
                          color: SejenakColor.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ).toList(),
      ),
    );
  }

  Widget _buildArticlesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SejenakText(
            text: "Artikel Konselor",
            type: SejenakTextType.h5,
            fontWeight: FontWeight.bold,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SejenakColor.light,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SejenakColor.stroke.withOpacity(0.2)),
            ),
            child: SejenakText(
              text: "24 Artikel",
              type: SejenakTextType.small,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
  // Dummy data for articles
  final articles = [
    {
      'title': 'Mengelola Kecemasan di Masa Sulit',
      'author': 'Dr. Sarah Wijaya, M.Psi',
      'readTime': '5 min read',
      'category': 'Kecemasan',
      'preview': 'Pelajari cara sederhana mengatasi rasa cemas yang muncul saat menghadapi situasi sulit...'
    },
    {
      'title': 'Tips Membangun Relationship yang Sehat',
      'author': 'Budi Santoso, S.Psi',
      'readTime': '7 min read',
      'category': 'Relationship',
      'preview': 'Hubungan sehat dimulai dari komunikasi yang jujur dan saling menghargai...'
    },
    {
      'title': 'Memahami Depresi dan Cara Mengatasinya',
      'author': 'Dr. Andi Pratama, Sp.KJ',
      'readTime': '10 min read',
      'category': 'Depresi',
      'preview': 'Depresi bukan sekadar rasa sedih, kenali tanda-tandanya agar bisa segera ditangani...'
    },
    {
      'title': 'Parenting: Mendidik Anak dengan Mindfulness',
      'author': 'Maya Pertiwi, M.Psi',
      'readTime': '8 min read',
      'category': 'Parenting',
      'preview': 'Mindfulness dapat membantu orang tua lebih hadir dan memahami kebutuhan anak...'
    },
  ];

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Column(
      children: articles.map((article) => 
        Container(
          margin: EdgeInsets.only(bottom: 8),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Navigate to article detail
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SejenakColor.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SejenakText(
                        text: article['category'] as String,
                        type: SejenakTextType.small,
                        color: SejenakColor.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SejenakText(
  text: article['title'] as String,
  type: SejenakTextType.h5,
  fontWeight: FontWeight.bold,
  textAlign: TextAlign.start,
),

                    SizedBox(height: 6),
                    // 👉 Preview text
                    SejenakText(
                      text: article['preview'] as String,
                      type: SejenakTextType.small,
                      color: Colors.grey[700]!,
                      maxLines: 2,
                        textAlign: TextAlign.start,

                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SejenakText(
                          text: article['author'] as String,
                          type: SejenakTextType.small,
                          color: SejenakColor.stroke,
                        ),
                        Spacer(),
                        SejenakText(
                          text: article['readTime'] as String,
                          type: SejenakTextType.small,
                          color: SejenakColor.stroke,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ).toList(),
    ),
  );
}


  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SejenakColor.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emergency_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                SizedBox(height: 16),
                SejenakText(
                  text: "Bantuan Krisis Darurat",
                  type: SejenakTextType.h5,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                SejenakText(
                  text: "Jika Anda mengalami krisis atau membutuhkan bantuan segera, hubungi:",
                  type: SejenakTextType.small,
                  color: SejenakColor.stroke,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                _buildEmergencyContact(
                  name: "Layanan Darurat 119",
                  description: "Layanan psikologis darurat",
                  onTap: () {
                    // Call emergency number
                  },
                ),
                _buildEmergencyContact(
                  name: "Into The Light",
                  description: "Pencegahan bunuh diri Indonesia",
                  onTap: () {
                    // Call suicide prevention hotline
                  },
                ),
                _buildEmergencyContact(
                  name: "RSJ Dr. Soeharto Heerdjan",
                  description: "Rumah Sakit Jiwa Jakarta",
                  onTap: () {
                    // Call mental hospital
                  },
                ),
                SizedBox(height: 20),
                Container(
                  height: 44,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: SejenakColor.light,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SejenakColor.stroke.withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: SejenakText(
                          text: "Tutup",
                          type: SejenakTextType.regular,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyContact({
    required String name,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SejenakColor.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SejenakColor.stroke.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SejenakText(
                        text: name,
                        type: SejenakTextType.regular,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 2),
                      SejenakText(
                        text: description,
                        type: SejenakTextType.small,
                        color: SejenakColor.stroke,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}