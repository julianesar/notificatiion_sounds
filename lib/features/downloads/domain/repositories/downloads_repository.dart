import '../entities/downloaded_tone.dart';
import '../../../tones/domain/entities/tone.dart';

abstract class DownloadsRepository {
  Future<List<DownloadedTone>> getAllDownloads();
  Future<DownloadedTone> downloadTone(Tone tone);
  Future<void> deleteDownload(String id);
  Future<void> deleteAllDownloads();
  Future<bool> isDownloaded(String id);
  Future<DownloadedTone?> getDownloadedTone(String id);
}