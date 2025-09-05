import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/downloaded_tone_model.dart';
import '../../../tones/domain/entities/tone.dart';

abstract class DownloadsLocalDS {
  Future<List<DownloadedToneModel>> getAllDownloads();
  Future<DownloadedToneModel> downloadTone(Tone tone);
  Future<void> deleteDownload(String id);
  Future<void> deleteAllDownloads();
  Future<bool> isDownloaded(String id);
  Future<DownloadedToneModel?> getDownloadedTone(String id);
}

class DownloadsLocalDSImpl implements DownloadsLocalDS {
  static const String _downloadsKey = 'downloaded_tones';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  @override
  Future<List<DownloadedToneModel>> getAllDownloads() async {
    try {
      final prefs = await _prefs;
      final String? downloadsJson = prefs.getString(_downloadsKey);
      
      if (downloadsJson == null) return [];
      
      final List<dynamic> downloadsList = json.decode(downloadsJson);
      return downloadsList
          .map((json) => DownloadedToneModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting downloads: $e');
      return [];
    }
  }

  @override
  Future<DownloadedToneModel> downloadTone(Tone tone) async {
    try {
      // Get downloads directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory downloadsDir = Directory('${appDocDir.path}/downloads');
      
      // Create downloads directory if it doesn't exist
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Generate filename from tone title
      String filename = '${tone.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.mp3';
      final File localFile = File(path.join(downloadsDir.path, filename));

      // Check if file already exists
      if (await localFile.exists()) {
        // If file exists, add timestamp to make it unique
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        filename = '${tone.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}_$timestamp.mp3';
        final File uniqueFile = File(path.join(downloadsDir.path, filename));
        
        // Download the file
        final response = await http.get(Uri.parse(tone.url));
        if (response.statusCode == 200) {
          await uniqueFile.writeAsBytes(response.bodyBytes);
          
          // Create downloaded tone model
          final downloadedTone = DownloadedToneModel.fromTone(tone, uniqueFile.path);
          
          // Save to shared preferences
          await _saveDownload(downloadedTone);
          
          return downloadedTone;
        } else {
          throw Exception('Failed to download tone: ${response.statusCode}');
        }
      } else {
        // Download the file
        final response = await http.get(Uri.parse(tone.url));
        if (response.statusCode == 200) {
          await localFile.writeAsBytes(response.bodyBytes);
          
          // Create downloaded tone model
          final downloadedTone = DownloadedToneModel.fromTone(tone, localFile.path);
          
          // Save to shared preferences
          await _saveDownload(downloadedTone);
          
          return downloadedTone;
        } else {
          throw Exception('Failed to download tone: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error downloading tone: $e');
    }
  }

  @override
  Future<void> deleteDownload(String id) async {
    try {
      final downloads = await getAllDownloads();
      final downloadToDelete = downloads.firstWhere((d) => d.id == id);
      
      // Delete local file
      final file = File(downloadToDelete.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Remove from list and save
      downloads.removeWhere((d) => d.id == id);
      await _saveDownloadsList(downloads);
    } catch (e) {
      print('Error deleting download: $e');
    }
  }

  @override
  Future<void> deleteAllDownloads() async {
    try {
      final downloads = await getAllDownloads();
      
      // Delete all local files
      for (final download in downloads) {
        final file = File(download.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Clear shared preferences
      final prefs = await _prefs;
      await prefs.remove(_downloadsKey);
    } catch (e) {
      print('Error deleting all downloads: $e');
    }
  }

  @override
  Future<bool> isDownloaded(String id) async {
    final downloads = await getAllDownloads();
    return downloads.any((d) => d.id == id);
  }

  @override
  Future<DownloadedToneModel?> getDownloadedTone(String id) async {
    final downloads = await getAllDownloads();
    try {
      return downloads.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveDownload(DownloadedToneModel download) async {
    final downloads = await getAllDownloads();
    
    // Remove if already exists (update)
    downloads.removeWhere((d) => d.id == download.id);
    
    // Add new download
    downloads.insert(0, download); // Add to beginning for newest first
    
    await _saveDownloadsList(downloads);
  }

  Future<void> _saveDownloadsList(List<DownloadedToneModel> downloads) async {
    try {
      final prefs = await _prefs;
      final downloadsJson = json.encode(downloads.map((d) => d.toJson()).toList());
      await prefs.setString(_downloadsKey, downloadsJson);
    } catch (e) {
      print('Error saving downloads list: $e');
    }
  }

}