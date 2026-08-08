import 'package:flutter/material.dart';
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
import 'package:selena/services/api.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/services/local/app_preferences.dart';
import 'package:selena/session/user_session.dart';

class Comunity extends StatefulWidget {
  const Comunity({super.key});

  @override
  State<Comunity> createState() => _ComunityState();
}

class _ComunityState extends State<Comunity> {
  final UserModels? mySession = UserSession().user;
  late final ComunityServices comunity;
  late final ComunityAction comunityAction;

  List<PostModels> posts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    assert(mySession != null, "User tidak boleh null!");
    comunity = ComunityServices(mySession!);
    comunityAction = ComunityAction(mySession!);

    _loadPosts();
  }

  /// Langkah utama: tampilkan cache dulu, baru fetch data dari server
  Future<void> _loadPosts({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 1️⃣ Ambil cache lokal dulu
      if (!forceRefresh) {
        final cached = await AppPreferences.loadModelList<PostModels>(
          'cached_posts',
          (json) => PostModels.fromJson(json),
        );
print('post');
        if (cached.isNotEmpty) {
          setState(() => posts = cached);
        }
      }

      // 2️⃣ Fetch data terbaru dari server
      final fetched = await comunity.getAllPosts();

      // 3️⃣ Cek apakah data berbeda dengan cache
      final cachedPosts = posts;
      // final isDifferent = !_isSamePosts(cachedPosts, fetched);

      // 4️⃣ Update UI & simpan cache baru
      // if (isDifferent || forceRefresh) {
        setState(() => posts = fetched);
        await AppPreferences.saveModelList('cached_posts', fetched);
      // }
    } catch (e) {
      // 5️⃣ Jika error & cache kosong, tampilkan error
      if (posts.isEmpty) {
        setState(() => error = e.toString());
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Bandingkan list post apakah sama
  bool _isSamePosts(List<PostModels> a, List<PostModels> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].postId != b[i].postId || a[i].updatedAt != b[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  /// Refresh manual (misalnya lewat tombol atau pull-to-refresh)
  Future<void> _onRefresh() async {
    await _loadPosts(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBody(),
      ),
      endDrawer: SejenakSidebar(user: mySession),
      floatingActionButton: SejenakFloatingButton(
  onPressed: () {
    final user = UserSession().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamu harus login dulu untuk membuat post")),
      );
      return;
    }
    SejenakCreatePost(isCreate: true).showCreateContainer(context);
  },
),

      bottomNavigationBar: SejenakNavbar(index: 1),
    );
  }

  Widget _buildBody() {
    if (isLoading && posts.isEmpty) return _buildLoadingState();
    if (error != null) return _buildErrorState(error!);
    if (posts.isEmpty) return _buildEmptyState(context);
    return _buildCommunityContent(posts, context);
  }

  Widget _buildLoadingState() => Column(
        children: [
          SejenakHeaderPage(
            text: "Komunitas",
            profile: mySession!.user!.avatar,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SejenakCircular(),
                  const SizedBox(height: 16),
                  SejenakText(
                    text: "Memuat cerita komunitas...",
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildErrorState(String error) => Column(
        children: [
          SejenakHeaderPage(
            text: "Komunitas",
            profile: mySession!.user!.avatar,
          ),
          Expanded(
            child: SejenakError(message: error),
          ),
        ],
      );

  Widget _buildEmptyState(BuildContext context) => Column(
        children: [
          SejenakHeaderPage(
            text: "Komunitas",
            profile: mySession!.user!.avatar,
          ),
          _buildCommunityStats(0, 0, 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 80, color: SejenakColor.stroke.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  SejenakText(
                    text: "Komunitas Masih Sepi",
                    type: SejenakTextType.h4,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SejenakText(
                    text:
                        "Jadilah yang pertama berbagi cerita dan pengalaman untuk menginspirasi orang lain",
                    type: SejenakTextType.small,
                    color: SejenakColor.stroke,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: SejenakColor.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            SejenakCreatePost().showCreateContainer(context),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  color: SejenakColor.primary, size: 20),
                              const SizedBox(width: 8),
                              SejenakText(
                                text: "Buat Post Pertama",
                                type: SejenakTextType.regular,
                                color: SejenakColor.primary,
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
          ),
        ],
      );

  Widget _buildCommunityContent(List<PostModels> posts, BuildContext context) {
    int totalLikes = posts.fold(0, (sum, post) => sum + (post.totalLike ?? 0));
    int totalComments =
        posts.fold(0, (sum, post) => sum + (post.totalComment ?? 0));
    int activeUsers = posts.map((post) => post.user?.id ?? 0).toSet().length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SejenakHeaderPage(
            text: "Komunitas",
            profile: mySession!.user!.avatar,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildCommunityStats(totalLikes, totalComments, activeUsers),
        ),
        SliverToBoxAdapter(child: _buildWelcomeMessage()),
        SliverToBoxAdapter(child: _buildPostsHeader(posts.length)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildPostItem(posts[index], context),
            childCount: posts.length,
          ),
        ),
        SliverToBoxAdapter(child: _buildLoadMoreIndicator()),
      ],
    );
  }

  Widget _buildCommunityStats(int totalLikes, int totalComments, int activeUsers) =>
      Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.favorite_rounded, totalLikes.toString(),
                  "Total Likes", Colors.red[400]!),
              _buildStatItem(Icons.chat_bubble_rounded,
                  totalComments.toString(), "Komentar", Colors.blue[400]!),
              _buildStatItem(Icons.people_rounded, activeUsers.toString(),
                  "Aktif", Colors.green[400]!),
            ],
          ),
        ),
      );

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        SejenakText(
            text: value, type: SejenakTextType.h5, fontWeight: FontWeight.bold),
        SejenakText(
            text: label, type: SejenakTextType.small, color: SejenakColor.stroke),
      ],
    );
  }

  Widget _buildWelcomeMessage() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: SejenakColor.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              width: 1.0, color: SejenakColor.secondary.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.emoji_objects_rounded,
                  color: SejenakColor.secondary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SejenakText(
                      text: "Selamat datang di Komunitas!",
                      type: SejenakTextType.regular,
                      fontWeight: FontWeight.bold,
                      color: SejenakColor.secondary,
                    ),
                    const SizedBox(height: 4),
                    SejenakText(
                      text:
                          "Bagikan pengalamanmu, beri dukungan, dan temukan inspirasi dari sesama",
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

  Widget _buildPostsHeader(int postCount) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SejenakText(
              text: "Cerita Komunitas ($postCount)",
              type: SejenakTextType.h5,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      );

  Widget _buildPostItem(PostModels post, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          commentAction: () =>
          SejenakDetailPost.showDetail(context, post),

          likeAction: (bool isLiked, int postID) async {
            comunityAction.likePost(isLiked, post.postId!);
          },
        ),
      );

  Widget _buildLoadMoreIndicator() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(16),
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
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: SejenakColor.secondary, size: 32),
            const SizedBox(height: 8),
            SejenakText(
              text: "Kamu sudah sampai akhir!",
              type: SejenakTextType.regular,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            SejenakText(
              text:
                  "Terima kasih telah menjadi bagian dari komunitas yang saling mendukung",
              type: SejenakTextType.small,
              color: SejenakColor.stroke,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: SejenakColor.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SejenakColor.secondary),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _onRefresh,
                  child: Center(
                    child: SejenakText(
                      text: "Muat Ulang",
                      type: SejenakTextType.small,
                      color: SejenakColor.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
