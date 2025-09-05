import '../repositories/downloads_repository.dart';

class DeleteDownload {
  final DownloadsRepository repository;

  DeleteDownload(this.repository);

  Future<void> call(String id) {
    return repository.deleteDownload(id);
  }
}