import 'package:selena/models/post_likes/post_likes.dart';
import 'package:selena/models/user_models/user.dart';
import 'package:selena/models/user_models/user_models.dart';

class PostCommentModels {
  final int? id;
  final int? postId;
  final int? userId;
  final String? content;
  final String? createdAt;
  final String? updatedAt;
  final User? user;
  final List<PostCommentModels>? replies;
  final List<dynamic>? likes;

  PostCommentModels({
    this.id,
    this.postId,
    this.userId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.replies,
    this.likes,
  });

   factory PostCommentModels.fromJson(Map<String, dynamic> json) {
  return PostCommentModels(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
    postId: json['post_id'] is int ? json['post_id'] : int.tryParse(json['post_id']?.toString() ?? ''),
    userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
    content: json['content'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
user: json['user'] != null ? User.fromJson(json['user']) : null,
    replies: (json['replies'] as List<dynamic>?)
        ?.map((r) => PostCommentModels.fromJson(r))
        .toList(),
    likes: (json['likes'] as List?)
        ?.map((e) => LikeModel.fromJson(e))
        .toList() ?? [],
  );
}



  /// ✅ Tambahan method toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'replies': replies?.map((r) => r.toJson()).toList(),
      'likes': likes,
    };
  }

  static List<PostCommentModels> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostCommentModels.fromJson(json)).toList();
  }
}
