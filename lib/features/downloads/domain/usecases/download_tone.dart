import '../entities/downloaded_tone.dart';
import '../repositories/downloads_repository.dart';
import '../../../tones/domain/entities/tone.dart';

class DownloadTone {
  final DownloadsRepository repository;

  DownloadTone(this.repository);

  Future<DownloadedTone> call(Tone tone) {
    return repository.downloadTone(tone);
  }
}