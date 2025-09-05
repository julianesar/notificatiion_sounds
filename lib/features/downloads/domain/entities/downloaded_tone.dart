import 'package:flutter/foundation.dart';

@immutable
class DownloadedTone {
  final String id;
  final String title;
  final String url;
  final String localPath;
  final DateTime downloadedAt;
  final bool requiresAttribution;
  final String? attributionText;

  const DownloadedTone({
    required this.id,
    required this.title,
    required this.url,
    required this.localPath,
    required this.downloadedAt,
    required this.requiresAttribution,
    this.attributionText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedTone && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DownloadedTone(id: $id, title: $title, localPath: $localPath, downloadedAt: $downloadedAt)';
}