class Notifications {
  int? id;
  String? username;
  int? typeId;
  String? type;
  String? createdAt;
  String? updatedAt;

  Notifications({
    this.id,
    this.username,
    this.typeId,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        id: json['id'] as int?,
        username: json['username'] as String?,
        typeId: json['typeID'] as int?,
        type: json['type'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'typeID': typeId,
        'type': type,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
