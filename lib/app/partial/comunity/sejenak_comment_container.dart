import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakCommentContainer extends StatelessWidget {
  final Widget? child;
  final int id;
  final String text;
  final String name;
  final String date;
  final String postImage;
  final int likes;
  final bool isLike;
  final bool isMe;
  final int comment;
  late bool isReply = false;
  final Function(bool isReply)? onReplyChanged;

  SejenakCommentContainer({
    super.key,
    this.child,
    required this.id,
    required this.text,
    this.name = 'anonimus',
    this.date = 'jan 1, 2000',
    this.postImage = '',
    this.likes = 0,
    this.comment = 0,
    this.isLike = false,
    this.isMe = false,
    this.onReplyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(3),
      width: double.infinity,
      decoration: BoxDecoration(
        color: SejenakColor.white,
        border: const Border(
          left: BorderSide(width: 1.0, color: SejenakColor.secondary),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 1, color: SejenakColor.secondary),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: SejenakColor.stroke, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          postImage,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person,
                                size: 30, color: SejenakColor.stroke);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.5),
                    SejenakText(text: name, type: SejenakTextType.regular),
                    SejenakText(
                      text: " • ${date.substring(0, 10)}",
                      type: SejenakTextType.regular,
                      style: const TextStyle(color: SejenakColor.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        isReply = true;
                        if (onReplyChanged != null) {
                          onReplyChanged!(isReply);
                        }
                      },
                      child: SejenakText(
                        text: "Reply",
                        type: SejenakTextType.regular,
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    // SvgPicture.asset(
                    //   'assets/svg/like_comment.svg',
                    //   width: 18,
                    //   height: 18,
                    // ),
                    // SizedBox(
                    //   width: 3,
                    // ),
                    // SejenakText(text: likes.toString()),
                    // SizedBox(
                    //   width: 8,
                    // ),
                  ],
                ),
                if (child != null)
                  Padding(
                      padding: const EdgeInsets.only(left: 10), child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
