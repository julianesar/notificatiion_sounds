import '../../domain/entities/downloaded_tone.dart';
import '../../../tones/domain/entities/tone.dart';

class DownloadedToneModel extends DownloadedTone {
  const DownloadedToneModel({
    required super.id,
    required super.title,
    required super.url,
    required super.localPath,
    required super.downloadedAt,
    required super.requiresAttribution,
    super.attributionText,
  });

  factory DownloadedToneModel.fromTone(Tone tone, String localPath) {
    return DownloadedToneModel(
      id: tone.id,
      title: tone.title,
      url: tone.url,
      localPath: localPath,
      downloadedAt: DateTime.now(),
      requiresAttribution: tone.requiresAttribution,
      attributionText: tone.attributionText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'localPath': localPath,
      'downloadedAt': downloadedAt.millisecondsSinceEpoch,
      'requiresAttribution': requiresAttribution,
      'attributionText': attributionText,
    };
  }

  factory DownloadedToneModel.fromJson(Map<String, dynamic> json) {
    return DownloadedToneModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      localPath: json['localPath'],
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(json['downloadedAt']),
      requiresAttribution: json['requiresAttribution'] ?? false,
      attributionText: json['attributionText'],
    );
  }
}