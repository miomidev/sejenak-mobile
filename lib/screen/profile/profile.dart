import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/api.dart';
import 'package:selena/session/user_session.dart';

class Profile extends StatelessWidget {
  final UserModels? user;

  Profile({super.key}) : user = UserSession().user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: SejenakColor.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Profil",
              profile: user!.user!.profil,
            ),
          ),
          
          // Profile Info Section
          SliverToBoxAdapter(
            child: _buildProfileInfo(),
          ),
          
          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),
          
          // Menu Section
          SliverToBoxAdapter(
            child: _buildMenuSection(),
          ),
          
          // Settings Section
          SliverToBoxAdapter(
            child: _buildSettingsSection(context),
          ),
        ],
      ),
      endDrawer: SejenakSidebar(user: user),
      bottomNavigationBar: SejenakNavbar(index: 3),
    );
  }

  Widget _buildProfileInfo() {
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
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SejenakColor.secondary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: user?.user?.profil == null || user!.user!.profil!.isEmpty
                        ? Container(
                            color: SejenakColor.light,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: SejenakColor.stroke,
                            ),
                          )
                        : Image.network(
                            "${API.endpointImage}storage/${user!.user!.profil}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: SejenakColor.light,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: SejenakColor.stroke,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: SejenakColor.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SejenakColor.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: SejenakColor.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // User Name
            SejenakText(
              text: user?.user?.username ?? "User",
              type: SejenakTextType.h4,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 4),
            
            // Email
            SejenakText(
              text: user?.user?.email ?? "email@example.com",
              type: SejenakTextType.small,
              color: SejenakColor.stroke,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            // Edit Profile Button
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: SejenakColor.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SejenakColor.secondary),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to edit profile
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/edit.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            SejenakColor.secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        SejenakText(
                          text: "Edit Profil",
                          type: SejenakTextType.regular,
                          color: SejenakColor.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
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
        child: Column(
          children: [
            SejenakText(
              text: "Statistik Saya",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: "24",
                  label: "Post",
                  icon: 'assets/svg/post_icon.svg',
                ),
                _buildStatItem(
                  value: "156",
                  label: "Likes",
                  icon: 'assets/svg/like.svg',
                ),
                _buildStatItem(
                  value: "18",
                  label: "Journal",
                  icon: 'assets/svg/journal.svg',
                ),
                _buildStatItem(
                  value: "7",
                  label: "Streak",
                  icon: 'assets/svg/fire.svg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required String icon,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: SejenakColor.light,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SejenakColor.stroke.withOpacity(0.3)),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                SejenakColor.secondary,
                BlendMode.srcIn,
              ),
            ),
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
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SejenakText(
              text: "Aktivitas Saya",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12),
            _buildMenuButton(
              icon: 'assets/svg/my_posts.svg',
              title: 'Postingan Saya',
              subtitle: 'Lihat semua postingan yang kamu buat',
              onTap: () {
                // Navigate to my posts
              },
            ),
            _buildMenuButton(
              icon: 'assets/svg/my_journals.svg',
              title: 'Journal Saya',
              subtitle: 'Lihat semua journal yang telah ditulis',
              onTap: () {
                // Navigate to my journals
              },
            ),
            _buildMenuButton(
              icon: 'assets/svg/liked_posts.svg',
              title: 'Postingan Disukai',
              subtitle: 'Postingan yang pernah kamu like',
              onTap: () {
                // Navigate to liked posts
              },
            ),
            _buildMenuButton(
              icon: 'assets/svg/achievements.svg',
              title: 'Pencapaian',
              subtitle: 'Lihat pencapaian dan badge kamu',
              onTap: () {
                // Navigate to achievements
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SejenakColor.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      SejenakColor.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SejenakText(
                      text: title,
                      type: SejenakTextType.regular,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 2),
                    SejenakText(
                      text: subtitle,
                      type: SejenakTextType.small,
                      color: SejenakColor.stroke,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: SejenakColor.stroke.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SejenakText(
              text: "Pengaturan",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12),
            _buildSettingButton(
              icon: 'assets/svg/notification.svg',
              title: 'Notifikasi',
              onTap: () {
                // Navigate to notification settings
              },
            ),
            _buildSettingButton(
              icon: 'assets/svg/privacy.svg',
              title: 'Privasi & Keamanan',
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            _buildSettingButton(
              icon: 'assets/svg/help.svg',
              title: 'Bantuan & Dukungan',
              onTap: () {
                // Navigate to help center
              },
            ),
            _buildSettingButton(
              icon: 'assets/svg/about.svg',
              title: 'Tentang Aplikasi',
              onTap: () {
                // Navigate to about page
              },
            ),
            SizedBox(height: 16),
            
            // Logout Button
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: SejenakColor.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SejenakColor.error.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Show logout confirmation dialog
                    _showLogoutDialog(context);
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/logout.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            SejenakColor.error,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        SejenakText(
                          text: 'Keluar',
                          type: SejenakTextType.regular,
                          color: SejenakColor.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingButton({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SejenakColor.light,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      SejenakColor.stroke,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SejenakText(
                  text: title,
                  type: SejenakTextType.regular,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: SejenakColor.stroke.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                SvgPicture.asset(
                  'assets/svg/logout.svg',
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    SejenakColor.error,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 16),
                SejenakText(
                  text: "Keluar Akun",
                  type: SejenakTextType.h5,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                SejenakText(
                  text: "Apakah kamu yakin ingin keluar dari akun?",
                  type: SejenakTextType.small,
                  color: SejenakColor.stroke,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
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
                                text: "Batal",
                                type: SejenakTextType.regular,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: SejenakColor.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Perform logout
                              Navigator.pop(context);
                              // Add logout logic here
                            },
                            child: Center(
                              child: SejenakText(
                                text: "Keluar",
                                type: SejenakTextType.regular,
                                color: SejenakColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}