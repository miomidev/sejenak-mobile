class PostCommentLikes {
  int? commentLikeId;
  int? commentId;
  String? username;
  String? createdAt;
  String? updatedAt;

  PostCommentLikes({
    this.commentLikeId,
    this.commentId,
    this.username,
    this.createdAt,
    this.updatedAt,
  });

  factory PostCommentLikes.fromJson(Map<String, dynamic> json) {
    return PostCommentLikes(
      commentLikeId: json['commentLikeID'] as int?,
      commentId: json['commentID'] as int?,
      username: json['username'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'commentLikeID': commentLikeId,
        'commentID': commentId,
        'username': username,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
