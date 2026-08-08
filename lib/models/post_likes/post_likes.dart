class LikeModel {
  int? id;
  int? userId;
  int? postId;
  int? commentId;
  String? createdAt;
  String? updatedAt;

  LikeModel({
    this.id,
    this.userId,
    this.postId,
    this.commentId,
    this.createdAt,
    this.updatedAt,
  });

factory LikeModel.fromJson(Map<String, dynamic> json) => LikeModel(
  id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
  userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
  postId: json['post_id'] is int ? json['post_id'] : int.tryParse(json['post_id']?.toString() ?? ''),
  commentId: json['comment_id'] is int ? json['comment_id'] : int.tryParse(json['comment_id']?.toString() ?? ''),
  createdAt: json['created_at']?.toString(),
  updatedAt: json['updated_at']?.toString(),
);


  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "post_id": postId,
        "comment_id": commentId,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
