import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_floating_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/comunity/sejenak_create_post.dart';
import 'package:selena/app/partial/comunity/sejenak_detail_post.dart';
import 'package:selena/app/partial/comunity/sejenak_post_container.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/app/partial/main/sejenak_error.dart';
import 'package:selena/app/partial/main/sejenak_header_page.dart';
import 'package:selena/app/partial/main/sejenak_sidebar.dart';
import 'package:selena/app/partial/sejenak_navbar.dart';
import 'package:selena/models/post_models/post_models.dart';
import 'package:selena/models/user_models/user_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/screen/profile/profile.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/session/user_session.dart';

class Dashboard extends StatelessWidget {
  final UserModels? mySession;
  final ComunityServices comunity;
  final Future<List<PostModels>> recentPosts;
  final ComunityAction comunityAction;

  Dashboard({super.key})
      : mySession = UserSession().user,
        comunity = ComunityServices(UserSession().user!),
        comunityAction = ComunityAction(UserSession().user!),
        recentPosts = ComunityServices(UserSession().user!).getAllMyPosts() {
    assert(mySession != null, "User tidak boleh null!");
    print(mySession!.user!.toString());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SejenakHeaderPage(
              text: "Dashboard",
              profile: mySession!.user!.avatar,
            ),
          ),

          // Streak & Daily Challenge Section
          SliverToBoxAdapter(
            child: _buildStreakSection(),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),

          // Quick Actions - Menu Utama
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),

          // Daily Challenge
          SliverToBoxAdapter(
            child: _buildDailyChallenge(),
          ),

          // Recent Posts Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SejenakText(
                text: "Post Anda di Komunitas",
                type: SejenakTextType.h5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Recent Posts List
          _buildRecentPostsList(),
        ],
      ),
      endDrawer: SejenakSidebar(user: mySession),
      floatingActionButton: SejenakFloatingButton(
        onPressed: () => SejenakCreatePost().showCreateContainer(context),
      ),
      bottomNavigationBar: SejenakNavbar(index: 0),
    );
  }

  Widget _buildStreakSection() {
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
          children: [
            // Streak Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SejenakText(
                    text: "Streak Hari Ini",
                    type: SejenakTextType.regular,
                    color: SejenakColor.stroke,
                  ),
                  SizedBox(height: 4),
                  (mySession?.journalStreak != null &&
                          mySession!.journalStreak! > 0)
                      ? Row(
                          children: [
                            SejenakText(
                              text: (mySession!.journalStreak!).toString(),
                              type: SejenakTextType.h4,
                              fontWeight: FontWeight.bold,
                              color: SejenakColor.secondary,
                            ),
                            SizedBox(width: 4),
                            SejenakText(
                              text: "hari berturut-turut",
                              type: SejenakTextType.small,
                              color: SejenakColor.stroke,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SejenakText(
                              text: "hikss... belum ada streak",
                              type: SejenakTextType.small,
                              color: SejenakColor.stroke,
                            ),
                          ],
                        ),
                  SizedBox(height: 8),
                  SejenakText(
                    text: "tulis journal untuk membuat streak!",
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                  ),
                ],
              ),
            ),

            // Fire Icon
            Container(
              width: 100,
              height: 100,
              child: (mySession?.journalStreak != null &&
                      mySession!.journalStreak! > 0)
                  ? Image.asset(
                      'assets/icon/icon_streak.png',
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      'assets/icon/icon_sad.png',
                      fit: BoxFit.contain,
                    ),
            )
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: 'assets/svg/post_icon.svg',
              value: (mySession?.totalPost ?? 0).toString(),
              label: "Post",
            ),
            _buildStatItem(
              icon: 'assets/svg/like.svg',
              value: (mySession?.totalLike ?? 0).toString(),
              label: "Like Diterima",
            ),
            _buildStatItem(
              icon: 'assets/svg/journal_icon.svg',
              value: (mySession?.totalJournal ?? 0).toString(),
              label: "Journal",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
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
        const SizedBox(height: 8),
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

  Widget _buildQuickActions(BuildContext context) {
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
              text: "Menu Utama",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionItem(
                  icon: 'assets/svg/post_icon.svg',
                  label: 'Komunitas',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/comunity',
                      result: (Route<dynamic> route) => false,
                    );
                  },
                ),
                _buildActionItem(
                  icon: 'assets/svg/article.svg',
                  label: 'Artikel',
                  onTap: () {},
                ),
                _buildActionItem(
                  icon: 'assets/svg/chat_icon.svg',
                  label: 'Chat Bot',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/chat',
                      result: (Route<dynamic> route) => false,
                    );
                  },
                ),
                _buildActionItem(
                  icon: 'assets/svg/chat_icon.svg',
                  label: 'Chat Ahli',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/chat',
                      result: (Route<dynamic> route) => false,
                    );
                  },
                ),
                _buildActionItem(
                  icon: 'assets/svg/journal_icon.svg',
                  label: 'Tulis Journal',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/journal',
                      result: (Route<dynamic> route) => false,
                    );
                  },
                ),
                _buildActionItem(
                  icon: 'assets/svg/logo_mini.svg',
                  label: 'Challenge',
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/journal',
                      result: (Route<dynamic> route) => false,
                    );
                  },
                ),
                _buildActionItem(
                  icon: 'assets/svg/profil_default.svg',
                  label: 'Profil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: SejenakColor.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: SejenakColor.secondary),
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
          const SizedBox(height: 6),
          SejenakText(
            text: label,
            type: SejenakTextType.small,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SejenakText(
                  text: "Daily Challenge",
                  type: SejenakTextType.h5,
                  fontWeight: FontWeight.bold,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SejenakColor.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SejenakColor.secondary),
                  ),
                  child: SejenakText(
                    text: "Hari 7",
                    type: SejenakTextType.small,
                    fontWeight: FontWeight.bold,
                    color: SejenakColor.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SejenakText(
              text: "Tuliskan 3 hal yang kamu syukuri hari ini",
              type: SejenakTextType.regular,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: SejenakColor.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SejenakText(
                        text: "Lakukan Challenge",
                        type: SejenakTextType.regular,
                        color: SejenakColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SejenakColor.light,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: SejenakColor.stroke.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/check.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        SejenakColor.stroke,
                        BlendMode.srcIn,
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
  }

  Widget _buildRecentPostsList() {
    return FutureBuilder<List<PostModels>>(
      future: recentPosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Center(child: SejenakCircular()),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: SejenakError(
              message: snapshot.error.toString(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
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
                child: Center(
                  child: SejenakText(
                    text: "Anda belum membuat postingan",
                    type: SejenakTextType.regular,
                    color: SejenakColor.stroke,
                  ),
                ),
              ),
            ),
          );
        }

        List<PostModels> posts = snapshot.data!.toList();

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var post = posts[index];
              return _buildPostItem(post, context);
            },
            childCount: posts.length,
          ),
        );
      },
    );
  }

  Widget _buildPostItem(PostModels post, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SejenakPostContainer(
        postId: post.postId!,
        title: post.title ?? "Judul Kosong",
        profile: post.user?.profil == null
            ? ""
            : "${API.endpointImage}storage/${post.user?.profil}",
        postImage: post.postPicture == null
            ? ""
            : "${API.endpointImage}storage/${post.postPicture}",
        text: post.deskripsiPost ?? "Tidak ada konten",
        likes: post.totalLike ?? 0,
        isMe: post.user?.id == mySession?.user?.id,
        isAnonymous: post.isAnonymous ?? false,
        comment: post.totalComment ?? 0,
        name: post.user?.username ?? "anonymous",
        isLike: post.isLikedByMe(mySession?.user?.id),
        date: post.createdAt!.substring(0, 10),
        commentAction: () =>SejenakDetailPost.showDetail(context, post),
        likeAction: (bool isLiked, int postID) async {
          comunityAction.likePost(isLiked, post.postId!);
        },
      ),
    );
  }
}
