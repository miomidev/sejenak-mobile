class MeditationModels {
  final int id;
  final String title;
  final String filePath;
  final String category;

  MeditationModels({
    required this.id,
    required this.title,
    required this.filePath,
    required this.category,
  });

  factory MeditationModels.fromJson(Map<String, dynamic> json) {
    return MeditationModels(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
