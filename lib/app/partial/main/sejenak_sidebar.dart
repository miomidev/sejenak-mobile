import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/api.dart';
import 'package:selena/session/user_session.dart';

class SejenakSidebar extends StatelessWidget {
  final UserModels? user;
  const SejenakSidebar({super.key, required this.user});
  Future<void> _logout(BuildContext context) async {
    UserSession().clearUser();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: SejenakColor.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header dengan profil
            _buildProfileSection(context),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: SejenakColor.stroke.withOpacity(0.3),
                thickness: 1,
              ),
            ),

            // Menu Navigasi
            Expanded(
              child: _buildMenuItems(context),
            ),

            // Footer dengan logout
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Foto profil dengan border
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SejenakColor.secondary,
                width: 2,
              ),
            ),
            child: ClipOval(
  child: user?.user?.avatar == null || user!.user!.avatar!.isEmpty
      ? Container(
          color: SejenakColor.light,
          child: Icon(
            Icons.person,
            size: 40,
            color: SejenakColor.stroke,
          ),
        )
      : Image.network(
          user!.user!.avatar!.startsWith('http')
              ? user!.user!.avatar! // langsung pakai URL
              : "${API.endpointImage}storage/${user!.user!.avatar}", // kalau relatif
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: SejenakColor.light,
              child: Icon(
                Icons.person,
                size: 40,
                color: SejenakColor.stroke,
              ),
            );
          },
        ),
),

          ),
          const SizedBox(height: 16),

          // Nama user
          SejenakText(
            text: user?.user?.username ?? "User",
            type: SejenakTextType.h5,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email user
          if (user?.user?.email != null)
            SejenakText(
              text: user!.user!.email!,
              type: SejenakTextType.small,
              color: SejenakColor.stroke,
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 16),

          // Stats mini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SejenakColor.light,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SejenakColor.stroke.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                    count: (user?.totalPost ?? 0).toString(), label: "Post"),
                _buildMiniStat(
                    count: (user?.totalLike ?? 0).toString(), label: "Likes"),
                _buildMiniStat(
                    count: (user?.journalStreak ?? 0).toString(),
                    label: "Streak"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({required String count, required String label}) {
    return Column(
      children: [
        SejenakText(
          text: count,
          type: SejenakTextType.h5,
          fontWeight: FontWeight.bold,
          color: SejenakColor.secondary,
        ),
        SejenakText(
          text: label,
          type: SejenakTextType.small,
          color: SejenakColor.stroke,
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _buildMenuItem(
          icon: 'assets/svg/dashboard.svg',
          title: 'Dashboard',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/post_icon.svg',
          title: 'Komunitas',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/comunity',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/article.svg',
          title: 'Artikel Kesehatan',
          onTap: () {
            // Navigate to articles
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/chat_icon.svg',
          title: 'Chat Bot',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/chat',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/chat_icon.svg',
          title: 'Chat dengan Ahli',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/chat',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/journal_icon.svg',
          title: 'Journal Saya',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/journal',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/challenge.svg',
          title: 'Daily Challenge',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/dashboard',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/notification.svg',
          title: 'Notifikasi',
          onTap: () {
            // Navigate to notifications
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          icon: 'assets/svg/settings.svg',
          title: 'Pengaturan',
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pushReplacementNamed(
              context,
              '/settings',
              result: (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
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
      title: SejenakText(
        text: title,
        type: SejenakTextType.regular,
        fontWeight: FontWeight.w500,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Divider
          Divider(
            color: SejenakColor.stroke.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Logout button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: SejenakColor.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SejenakColor.error.withOpacity(0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah kamu yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout ?? false) {
                    await _logout(context);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/logout.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        SejenakColor.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SejenakText(
                      text: 'Keluar',
                      type: SejenakTextType.regular,
                      color: SejenakColor.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Version info
          SejenakText(
            text: 'Sejenak v1.0.0',
            type: SejenakTextType.small,
            color: SejenakColor.stroke.withOpacity(0.6),
          ),
        ],
      ),
    );
  }
}
