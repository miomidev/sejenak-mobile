import 'package:selena/models/post_comment_models/post_comment_models.dart';
import 'package:selena/models/post_likes/post_likes.dart';
import 'package:selena/models/user_models/user.dart';
import 'package:selena/services/local/json_serializable.dart';

class PostModels implements JsonSerializable {
  int? postId;
  bool? isAnonymous;
  String? title;
  String? postPicture;
  String? deskripsiPost;
  int? totalLike;
  int? totalComment;
  bool? isLiked;
  String? createdAt;
  String? updatedAt;
  User? user;
  List<LikeModel>? likes;
  List<PostCommentModels>? comments;

  PostModels({
    this.postId,
    this.postPicture,
    this.title,
    this.deskripsiPost,
    this.totalLike,
    this.isAnonymous,
    this.totalComment,
    this.isLiked,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.likes,
    this.comments,
  });

  bool isLikedByMe(int? currentUserId) {
    return likes?.any((like) => like.userId == currentUserId) ?? false;
  }

  factory PostModels.fromJson(Map<String, dynamic> json) => PostModels(
  postId: json['id'] is String ? int.tryParse(json['id']) : json['id'] as int?,
  postPicture: json['image'] as String?,
  title: json['title'] as String?,
  deskripsiPost: json['content'] as String?,
  totalLike: (json['likes'] as List?)?.length ?? 0,
  totalComment: (json['comments'] as List?)?.length ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  isAnonymous: json['is_anonymous'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  user: json['user'] != null ? User.fromJson(json['user']) : null,
  likes: (json['likes'] as List?)
      ?.map((e) => LikeModel.fromJson(e))
      .toList(),
  comments: (json['comments'] as List?)
      ?.map((e) => PostCommentModels.fromJson(e))
      .toList(),
);


  @override
  Map<String, dynamic> toJson() => {
        'id': postId,
        'image': postPicture,
        'title': title,
        'content': deskripsiPost,
        'totalLike': totalLike,
        'totalComment': totalComment,
        'isLiked': isLiked,
        'isAnonymous': isAnonymous,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user': user?.toJson(),
        'likes': likes?.map((e) => e.toJson()).toList(),
        'comments': comments?.map((e) => e.toJson()).toList(),
      };

  static List<PostModels> fromJsonList(dynamic jsonList) {
    if (jsonList is List) {
      return jsonList.map((json) => PostModels.fromJson(json)).toList();
    }
    return [];
  }
}
