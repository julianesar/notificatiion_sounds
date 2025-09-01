class Ringtone {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String duration;
  final String filePath;
  final bool isFavorite;
  final bool isDownloaded;

  Ringtone({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.duration,
    required this.filePath,
    this.isFavorite = false,
    this.isDownloaded = false,
  });

  Ringtone copyWith({
    String? id,
    String? title,
    String? artist,
    String? category,
    String? duration,
    String? filePath,
    bool? isFavorite,
    bool? isDownloaded,
  }) {
    return Ringtone(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}