import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/app/partial/comunity/sejenak_create_post.dart';
import 'package:selena/root/sejenak_color.dart';
import 'package:selena/screen/comunity/comunity.dart';
import 'package:selena/services/api.dart';
import 'package:selena/services/comunity/comunity.dart';
import 'package:selena/session/user_session.dart';

class SejenakPostContainer extends StatefulWidget {
  final String title;
  final String profile;
  final String text;
  final String name;
  final String date;
  final String postImage;
  final int likes;
  final bool isLike;
  final bool isAnonymous;
  final bool isMe;
  final int comment;
  final int postId; // Tambahkan postId
  final VoidCallback commentAction;
  final Function(bool isLiked, int newLikes) likeAction;
  final Function(int postId)? onEdit; // Callback dengan postId
  final Function(int postId)? onDelete; // Callback dengan postId
  final Function(int postId)? onReport; // Callback dengan postId

  const SejenakPostContainer({
    super.key,
    required this.title,
    required this.text,
    required this.postId, // Wajib ada postId
    this.name = 'anonimus',
    this.isAnonymous = false,
    this.date = 'jan 1, 2000',
    this.postImage = '',
    this.likes = 0,
    this.profile = "",
    this.comment = 0,
    this.isLike = false,
    required this.commentAction,
    required this.likeAction,
    this.isMe = false,
    this.onEdit,
    this.onDelete,
    this.onReport,
  });

  @override
  _SejenakPostContainerState createState() => _SejenakPostContainerState();
}

class _SejenakPostContainerState extends State<SejenakPostContainer> {
  late int likes;
  late bool isLike;
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    likes = widget.likes;
    isLike = widget.isLike;
  }

  void toggleLike() {
    setState(() {
      if (isLike) {
        likes--;
      } else {
        likes++;
      }
      isLike = !isLike;
    });
    widget.likeAction(isLike, likes);
  }

  // Fungsi edit post
  void _editPost() {
    SejenakCreatePost(
      id: widget.postId,
      initialTitle: widget.title ?? ' ',
      initialContent: widget.text,
      initialImage: widget.postImage,
      initialIsAnonymous: widget.isAnonymous,
    ).showCreateContainer(context);
    // widget.onEdit?.call(widget.postId);
  }

  // Fungsi delete post
  void _deletePost() {
    // print("Delete post dengan ID: ${widget.postId}");
   ComunityServices(UserSession().user!).deletePost(widget.postId);
    widget.onDelete?.call(widget.postId);
  }

  // Fungsi report post
  void _reportPost() {
    print("Report post dengan ID: ${widget.postId}");
    // Tambahkan logika report post di sini
    // Contoh: Tampilkan dialog report
    widget.onReport?.call(widget.postId);
  }

  void _showMenu(BuildContext context) {
    final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height * 2,
      ),
      items: [
        // Menu untuk post milik sendiri
        if (widget.isMe) ...[
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20, color: SejenakColor.secondary),
                SizedBox(width: 8),
                Text('Edit Post'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Post'),
              ],
            ),
          ),
        ],
        // Menu untuk post orang lain
        if (!widget.isMe) ...[
          PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.report, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text('Laporkan'),
              ],
            ),
          ),
        ],
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'edit':
            _editPost();
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
          case 'report':
            _reportPost();
            break;
        }
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Post'),
          content: Text('Apakah Anda yakin ingin menghapus post ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: SejenakColor.secondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost();
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      width: double.maxFinite,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SejenakText(
                          text: widget.title,
                          type: SejenakTextType.h5,
                          textAlign: TextAlign.left,
                        ),
                        SejenakText(
                          text: widget.text.length > 100
                              ? "${widget.text.substring(0, 100)}..."
                              : widget.text,
                          type: SejenakTextType.small,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
                widget.postImage == ""
                    ? SizedBox()
                    : Container(
                        height: 110,
                        width: 113,
                        child: Stack(
                          children: [
                            Image.network(
                              widget.postImage,
                              width: 79,
                              height: 78,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: -15,
                              left: -20,
                              child: SvgPicture.asset(
                                'assets/svg/frame_post.svg',
                                width: 119,
                                height: 113,
                                colorFilter: ColorFilter.mode(
                                    SejenakColor.primary, BlendMode.srcIn),
                              ),
                            ),
                            Positioned(
                              top: 60,
                              child: SvgPicture.asset(
                                'assets/svg/stample.svg',
                                width: 85,
                                height: 30,
                              ),
                            )
                          ],
                        ),
                      ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ClipOval(
                          child: widget.isAnonymous
                              ? Container(
                                  width: 30,
                                  height: 30,
                                  color: SejenakColor.light,
                                  child: Icon(
                                    Icons.no_accounts,
                                    size: 20,
                                    color: SejenakColor.stroke,
                                  ),
                                )
                              : widget.profile == ""
                                  ? Container(
                                      width: 30,
                                      height: 30,
                                      color: SejenakColor.light,
                                      child: Icon(Icons.person, size: 20),
                                    )
                                  : Image.network(
                                      widget.profile,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 30,
                                          height: 30,
                                          color: SejenakColor.light,
                                          child: Icon(Icons.person, size: 20),
                                        );
                                      },
                                    ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SejenakText(
                                text: widget.isAnonymous
                                    ? 'Anonymous'
                                    : widget.name,
                                type: SejenakTextType.regular,
                                maxLines: 1,
                              ),
                              SejenakText(
                                text: widget.date,
                                type: SejenakTextType.small,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Like
                  GestureDetector(
                    onTap: toggleLike,
                    child: IntrinsicWidth(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/like.svg',
                            width: 20,
                            height: 20,
                            colorFilter: isLike
                                ? ColorFilter.mode(
                                    SejenakColor.secondary, BlendMode.srcIn)
                                : ColorFilter.mode(
                                    SejenakColor.stroke, BlendMode.srcIn),
                          ),
                          SizedBox(width: 4),
                          SizedBox(
                            width: 10,
                            child: Text(
                              likes.toString(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: "Exo2",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Tombol Comment
                  GestureDetector(
                    onTap: widget.commentAction,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/comment.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              SejenakColor.stroke, BlendMode.srcIn),
                        ),
                        SizedBox(width: 4),
                        Text(
                          widget.comment.toString(),
                          style: TextStyle(
                            fontFamily: "Exo2",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8),

                  // Hamburger menu yang bisa diklik
                  GestureDetector(
                    key: _menuKey,
                    onTap: () => _showMenu(context),
                    child: SvgPicture.asset(
                      'assets/svg/humberger_menu.svg',
                      width: 23,
                      height: 23,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}