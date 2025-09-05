import '../repositories/downloads_repository.dart';

class IsDownloaded {
  final DownloadsRepository repository;

  IsDownloaded(this.repository);

  Future<bool> call(String id) {
    return repository.isDownloaded(id);
  }
}