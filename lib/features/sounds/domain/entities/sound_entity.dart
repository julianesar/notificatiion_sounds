class SoundEntity {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String categoryId;
  final Duration duration;
  final int sizeInBytes;
  final String format;
  final bool isPremium;
  final int downloadCount;
  final double rating;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final List<String> tags;

  const SoundEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.categoryId,
    required this.duration,
    required this.sizeInBytes,
    required this.format,
    this.isPremium = false,
    this.downloadCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    this.thumbnailUrl,
    this.tags = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}