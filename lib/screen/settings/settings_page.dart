import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_container.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/session/user_session.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModels? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      user = UserSession().user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Pengaturan",
              profile: user?.user?.profil,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildProfileSection(),
          ),
          SliverToBoxAdapter(
            child: _buildAccountSection(),
          ),
          SliverToBoxAdapter(
            child: _buildAppSettingsSection(),
          ),
          SliverToBoxAdapter(
            child: _buildSupportSection(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      endDrawer: SejenakSidebar(user: user),
      bottomNavigationBar: SejenakNavbar(index: 3), // Adjust index according to your navbar
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SejenakContainer(
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                // Profile Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SejenakColor.primary.withOpacity(0.1),
                    image: user?.user?.avatar != null
                        ? DecorationImage(
                            image: NetworkImage(user!.user!.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.user?.avatar == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: SejenakColor.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SejenakText(
                        text: user?.user?.name ?? 'Nama Pengguna',
                        type: SejenakTextType.h5,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      SejenakText(
                        text: user?.user?.email ?? 'email@example.com',
                        type: SejenakTextType.small,
                        color: SejenakColor.stroke,
                      ),
                      const SizedBox(height: 4),
                      if (user?.user?.username != null)
                        SejenakText(
                          text: '@${user!.user!.username!}',
                          type: SejenakTextType.small,
                          color: SejenakColor.stroke,
                        ),
                    ],
                  ),
                ),
                // Edit Button
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: SejenakColor.primary,
                  ),
                  onPressed: _editProfile,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profile Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: user?.totalPost?.toString() ?? '0',
                  label: 'Post',
                ),
                _buildStatItem(
                  value: user?.totalJournal?.toString() ?? '0',
                  label: 'Jurnal',
                ),
                _buildStatItem(
                  value: user?.totalLike?.toString() ?? '0',
                  label: 'Suka',
                ),
                _buildStatItem(
                  value: user?.journalStreak?.toString() ?? '0',
                  label: 'Streak',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      children: [
        SejenakText(
          text: value,
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
          color: SejenakColor.primary,
        ),
        const SizedBox(height: 4),
        SejenakText(
          text: label,
          type: SejenakTextType.small,
          color: SejenakColor.stroke,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SejenakContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SejenakText(
              text: "Akun",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: "Edit Profil",
              subtitle: "Ubah informasi profil Anda",
              onTap: _editProfile,
            ),
            _buildSettingItem(
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: user?.user?.email ?? "Atur email",
              onTap: _editEmail,
            ),
            _buildSettingItem(
              icon: Icons.lock_outline_rounded,
              title: "Kata Sandi",
              subtitle: "Ubah kata sandi",
              onTap: _changePassword,
            ),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: "Notifikasi",
              subtitle: "Kelola notifikasi",
              onTap: _notificationSettings,
            ),
            _buildSettingItem(
              icon: Icons.security_outlined,
              title: "Privasi",
              subtitle: "Pengaturan privasi",
              onTap: _privacySettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SejenakContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SejenakText(
              text: "Aplikasi",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: "Bahasa",
              subtitle: "Indonesia",
              onTap: _changeLanguage,
            ),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: "Tema",
              subtitle: "Sistem",
              onTap: _changeTheme,
            ),
            _buildSettingItem(
              icon: Icons.storage_outlined,
              title: "Penyimpanan",
              subtitle: "Kelola penyimpanan",
              onTap: _storageSettings,
            ),
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              title: "Bantuan",
              subtitle: "Pusat bantuan",
              onTap: _helpCenter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SejenakContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SejenakText(
              text: "Dukungan",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.contact_support_outlined,
              title: "Hubungi Kami",
              subtitle: "Butuh bantuan?",
              onTap: _contactSupport,
            ),
            _buildSettingItem(
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              subtitle: "Versi 1.0.0",
              onTap: _aboutApp,
            ),
            _buildSettingItem(
              icon: Icons.logout_rounded,
              title: "Keluar",
              subtitle: "Keluar dari akun",
              onTap: _logout,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLogout
                      ? Colors.red.withOpacity(0.1)
                      : SejenakColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : SejenakColor.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SejenakText(
                      text: title,
                      type: SejenakTextType.regular,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 2),
                    SejenakText(
                      text: subtitle,
                      type: SejenakTextType.small,
                      color: isLogout
                          ? Colors.red.withOpacity(0.7)
                          : SejenakColor.stroke,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLogout
                    ? Colors.red.withOpacity(0.5)
                    : SejenakColor.stroke,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action Methods
  void _editProfile() {
    print('Edit profile tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
  }

  void _editEmail() {
    print('Edit email tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditEmailPage()));
  }

  void _changePassword() {
    print('Change password tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));
  }

  void _notificationSettings() {
    print('Notification settings tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
  }

  void _privacySettings() {
    print('Privacy settings tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySettingsPage()));
  }

  void _changeLanguage() {
    print('Change language tapped');
    // _showLanguageDialog();
  }

  void _changeTheme() {
    print('Change theme tapped');
    // _showThemeDialog();
  }

  void _storageSettings() {
    print('Storage settings tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => StorageSettingsPage()));
  }

  void _helpCenter() {
    print('Help center tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterPage()));
  }

  void _contactSupport() {
    print('Contact support tapped');
    // _launchContactSupport();
  }

  void _aboutApp() {
    print('About app tapped');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AboutAppPage()));
  }

  void _logout() {
    print('Logout tapped');
    _showLogoutDialog();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Implement logout logic here
    print('Logging out...');
    // Clear user session
    // Navigate to login page
  }
}