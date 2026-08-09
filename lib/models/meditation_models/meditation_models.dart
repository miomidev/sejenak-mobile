class MeditationModels {
  final int id;
  final String title;
  final String filePath;
  final String category;
  final bool isPremium;

  MeditationModels({
    required this.id,
    required this.title,
    required this.filePath,
    required this.category,
    this.isPremium = false,
  });

  factory MeditationModels.fromJson(Map<String, dynamic> json) {
    return MeditationModels(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? '',
      category: json['category'] ?? '',
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
    );
  }
}
