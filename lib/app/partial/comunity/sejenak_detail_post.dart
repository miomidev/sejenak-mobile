import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_primary_button.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/components/sejenak_text_field.dart';
import 'package:selena/app/partial/comunity/sejenak_comment_container.dart';
import 'package:selena/app/partial/main/sejenak_circular.dart';
import 'package:selena/app/partial/main/sejenak_error.dart';
import 'package:selena/models/post_comment_models/post_comment_models.dart';
import 'package:selena/models/post_models/post_models.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/session/user_session.dart';

class SejenakDetailPost {
  // Static method untuk memanggil showDetail
  static void showDetail(BuildContext context, PostModels post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailPostContent(post: post),
    );
  }
}

class _DetailPostContent extends StatefulWidget {
  final PostModels post;

  const _DetailPostContent({required this.post});

  @override
  State<_DetailPostContent> createState() => _DetailPostContentState();
}

class _DetailPostContentState extends State<_DetailPostContent> {
  final FocusNode _focusNode = FocusNode();
  late bool _isLiked;
  late int _likeCount;
  late List<PostCommentModels> _comments;
  bool _isLoadingComments = false;
  bool _reply = false;
  late PostCommentModels _commentForReply;
  TextEditingController commentInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked ?? false;
    _likeCount = widget.post.totalLike ?? 0;
    _comments = widget.post.comments ?? [];

    if (widget.post.postId != null && _comments.isEmpty) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    if (widget.post.postId == null) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final fetchedComments = await ComunityAction(UserSession().user!)
          .getCommentPost(widget.post.postId!);

      setState(() {
        _comments = fetchedComments;
        _isLoadingComments = false;
      });
    } catch (error) {
      print("Error getting comments: $error");
      setState(() {
        _comments = [];
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final newLikeStatus = !_isLiked;
    final newLikeCount = newLikeStatus ? _likeCount + 1 : _likeCount - 1;

    setState(() {
      _isLiked = newLikeStatus;
      _likeCount = newLikeCount;
    });

    try {
      await ComunityAction(UserSession().user!)
          .likePost(newLikeStatus, widget.post.postId!);
    } catch (error) {
      setState(() {
        _isLiked = !newLikeStatus;
        _likeCount = newLikeStatus ? _likeCount - 1 : _likeCount + 1;
      });
      print("Error liking post: $error");
    }
  }

  Future<void> _addComment() async {
    if (commentInput.text.trim().isEmpty) return;

    try {
      if (!_reply) {
        await ComunityAction(UserSession().user!)
            .commentPost(widget.post.postId!, commentInput);
      } else {
        await ComunityAction(UserSession().user!).replyCommentPost(
            _commentForReply.id!, commentInput, widget.post.postId!);
      }

      commentInput.clear();
      FocusScope.of(context).unfocus();

      setState(() {
        _reply = false;
      });

      await _loadComments();
    } catch (error) {
      print("Error adding comment: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add comment'),
        ),
      );
    }
  }

  void _handleReply(PostCommentModels comment) {
    setState(() {
      _commentForReply = comment;
      _reply = true;
    });

    String mentionText = " @${comment.user!.username!} ";
    if (!commentInput.text.contains(mentionText)) {
      commentInput.text = commentInput.text + mentionText;
    }

    Future.microtask(() {
      if (_focusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (_, controller) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: SejenakColor.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.cancel_outlined,
                            color: SejenakColor.secondary,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SejenakText(
                              text: widget.post.title ?? 'No Title',
                              type: SejenakTextType.h4,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    widget.post.postPicture ?? '',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person,
                                      size: 35,
                                      color: SejenakColor.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SejenakText(
                                        text: widget.post.isAnonymous == true
                                            ? 'Anonymous'
                                            : widget.post.user!.username!,
                                        type: SejenakTextType.regular,
                                        maxLines: 1,
                                      ),
                                      SejenakText(
                                        text: widget.post.createdAt != null &&
                                                widget.post.createdAt!.length >=
                                                    10
                                            ? widget.post.createdAt!
                                                .substring(0, 10)
                                            : 'Unknown date',
                                        type: SejenakTextType.small,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.post.postPicture != null &&
                                widget.post.postPicture!.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    "${API.endpointImage}storage/${widget.post.postPicture}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            SejenakText(
                              text:
                                  widget.post.deskripsiPost ?? 'No description',
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  child: SejenakPrimaryButton(
                                    text: "$_likeCount",
                                    action: _toggleLike,
                                    icon: _isLiked
                                        ? 'assets/svg/liked.svg'
                                        : 'assets/svg/like.svg',
                                    paddingX: 0,
                                    paddingY: 9,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 2,
                              color: SejenakColor.primary,
                            ),
                            const SizedBox(height: 24),
                            // Comments Section
                            if (_isLoadingComments)
                              const Center(child: SejenakCircular())
                            else if (_comments.isEmpty)
                              Center(
                                child: SejenakError(
                                  message: 'belum ada komentar nih..',
                                ),
                              )
                            else
                              Column(
                                children: _comments
                                    .map(
                                      (comment) => SejenakCommentContainer(
                                        id: comment.id!,
                                        postImage: comment.user?.profil
                                                ?.toString() ??
                                            '',
                                        text: comment.content ?? '',
                                        name: comment.user!.username ??
                                            'Anonymous',
                                        date:
                                            comment.createdAt ?? 'Unknown date',
                                        likes: 0,
                                        comment: 0,
                                        isLike: false,
                                        isMe: false,
                                        onReplyChanged: (isReply) {
                                          if (isReply && comment.id != null) {
                                            _handleReply(comment);
                                          }
                                        },
                                        child: comment.replies != null &&
                                                comment.replies!.isNotEmpty
                                            ? Column(
                                                children: comment.replies!
                                                    .map((commentReply) =>
                                                        SejenakCommentContainer(
                                                          id: commentReply.id!,
                                                          text: commentReply
                                                              .content!,
                                                          postImage:
                                                              commentReply.user!
                                                                  .profil
                                                                  .toString(),
                                                          name: commentReply
                                                                  .user!
                                                                  .username ??
                                                              'Anonymous',
                                                          date: commentReply
                                                                  .createdAt ??
                                                              'Unknown date',
                                                        ))
                                                    .toList(),
                                              )
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: SejenakColor.white,
                    border: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: Colors.grey[900]!,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SejenakTextField(
                          text: 'Reply to post',
                          controller: commentInput,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SejenakPrimaryButton(
                        text: "",
                        icon: "assets/svg/pen.svg",
                        action: _addComment,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
