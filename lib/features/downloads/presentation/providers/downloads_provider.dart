import 'package:flutter/material.dart';
import '../../domain/entities/downloaded_tone.dart';
import '../../domain/usecases/get_all_downloads.dart';
import '../../domain/usecases/download_tone.dart';
import '../../domain/usecases/delete_download.dart';
import '../../domain/usecases/is_downloaded.dart';
import '../../../tones/domain/entities/tone.dart';

class DownloadsProvider extends ChangeNotifier {
  final GetAllDownloads getAllDownloads;
  final DownloadTone downloadTone;
  final DeleteDownload deleteDownload;
  final IsDownloaded isDownloaded;

  DownloadsProvider({
    required this.getAllDownloads,
    required this.downloadTone,
    required this.deleteDownload,
    required this.isDownloaded,
  });

  List<DownloadedTone> _downloads = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _downloadingTones = {}; // Track which tones are currently downloading

  List<DownloadedTone> get downloads => _downloads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool isToneDownloading(String toneId) => _downloadingTones.contains(toneId);
  bool isToneDownloadedSync(String toneId) => _downloads.any((d) => d.id == toneId);

  Future<void> loadDownloads() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _downloads = await getAllDownloads();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error loading downloads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> downloadToneAsync(Tone tone) async {
    if (_downloadingTones.contains(tone.id)) {
      return false; // Already downloading
    }

    if (isToneDownloadedSync(tone.id)) {
      return true; // Already downloaded
    }

    _downloadingTones.add(tone.id);
    notifyListeners();

    try {
      final downloadedTone = await downloadTone(tone);
      _downloads.insert(0, downloadedTone); // Add to beginning for newest first
      _downloadingTones.remove(tone.id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _downloadingTones.remove(tone.id);
      notifyListeners();
      print('Error downloading tone: $e');
      return false;
    }
  }

  Future<void> deleteToneDownload(String toneId) async {
    try {
      await deleteDownload(toneId);
      _downloads.removeWhere((d) => d.id == toneId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      print('Error deleting download: $e');
    }
  }

  Future<bool> checkIfDownloaded(String toneId) async {
    try {
      return await isDownloaded(toneId);
    } catch (e) {
      print('Error checking if downloaded: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void retry() {
    loadDownloads();
  }
}