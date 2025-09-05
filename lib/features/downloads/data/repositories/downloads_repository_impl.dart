import '../../domain/entities/downloaded_tone.dart';
import '../../domain/repositories/downloads_repository.dart';
import '../datasources/downloads_local_ds.dart';
import '../../../tones/domain/entities/tone.dart';

class DownloadsRepositoryImpl implements DownloadsRepository {
  final DownloadsLocalDS localDataSource;

  DownloadsRepositoryImpl(this.localDataSource);

  @override
  Future<List<DownloadedTone>> getAllDownloads() {
    return localDataSource.getAllDownloads();
  }

  @override
  Future<DownloadedTone> downloadTone(Tone tone) {
    return localDataSource.downloadTone(tone);
  }

  @override
  Future<void> deleteDownload(String id) {
    return localDataSource.deleteDownload(id);
  }

  @override
  Future<void> deleteAllDownloads() {
    return localDataSource.deleteAllDownloads();
  }

  @override
  Future<bool> isDownloaded(String id) {
    return localDataSource.isDownloaded(id);
  }

  @override
  Future<DownloadedTone?> getDownloadedTone(String id) {
    return localDataSource.getDownloadedTone(id);
  }
}