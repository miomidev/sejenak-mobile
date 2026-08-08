class MoodHistory {
  int? id;
  String? username;
  String? mood;
  String? createdAt;
  String? updatedAt;

  MoodHistory({
    this.id,
    this.username,
    this.mood,
    this.createdAt,
    this.updatedAt,
  });

  factory MoodHistory.fromJson(Map<String, dynamic> json) => MoodHistory(
        id: json['id'] as int?,
        username: json['username'] as String?,
        mood: json['mood'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'mood': mood,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
