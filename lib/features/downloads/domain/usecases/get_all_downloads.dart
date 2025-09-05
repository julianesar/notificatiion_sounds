import '../entities/downloaded_tone.dart';
import '../repositories/downloads_repository.dart';

class GetAllDownloads {
  final DownloadsRepository repository;

  GetAllDownloads(this.repository);

  Future<List<DownloadedTone>> call() {
    return repository.getAllDownloads();
  }
}