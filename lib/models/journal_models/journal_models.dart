import 'package:selena/services/local/json_serializable.dart';

class JournalModels  implements JsonSerializable{
  int? entriesId;
  String? content;
  String? title;
  String? createdAt;
  String? updatedAt;

  JournalModels({
    this.entriesId,
    this.content,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory JournalModels.fromJson(Map<String, dynamic> json) => JournalModels(
        entriesId: json['id'] as int?, // ✅ fix key dari "entriesID" ke "id"
        content: json['content'] as String?,
        title: json['title'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
@override
  Map<String, dynamic> toJson() => {
        'id': entriesId, // ✅ konsisten dengan API
        'content': content,
        'title': title,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static List<JournalModels> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => JournalModels.fromJson(json)).toList();
  }
}
