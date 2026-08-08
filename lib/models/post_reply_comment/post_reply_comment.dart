import 'package:selena/models/user_models/user.dart';

class PostReplyComment {
  int? id;
  int? commentId;
  int? userId;
  String? content;
  String? createdAt;
  String? updatedAt;
  User? user;
      
  PostReplyComment({
    this.id,
    this.commentId,
    this.userId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PostReplyComment.fromJson(Map<String, dynamic> json) {
    return PostReplyComment(
      id: json['id'] as int?,
      commentId: json['comment_id'] as int?,
      userId: json['user_id'] as int?,
      content: json['content'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'comment_id': commentId,
        'user_id': userId,
        'content': content,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user': user?.toJson(),
      };
}
