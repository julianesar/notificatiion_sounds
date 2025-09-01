import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class FileUtils {
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> getAppCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  static Future<Directory> getSoundsDirectory() async {
    final documentsDir = await getAppDocumentsDirectory();
    final soundsDir = Directory('${documentsDir.path}/${AppConstants.soundsDirectoryName}');
    
    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }
    
    return soundsDir;
  }

  static Future<Directory> getCacheDirectory() async {
    final cacheDir = await getAppCacheDirectory();
    final appCacheDir = Directory('${cacheDir.path}/${AppConstants.cacheDirectoryName}');
    
    if (!await appCacheDir.exists()) {
      await appCacheDir.create(recursive: true);
    }
    
    return appCacheDir;
  }

  static Future<String> generateSoundFilePath(String soundId, String extension) async {
    final soundsDir = await getSoundsDirectory();
    return '${soundsDir.path}/$soundId.$extension';
  }

  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }

  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot != -1 && lastDot < fileName.length - 1) {
      return fileName.substring(lastDot + 1).toLowerCase();
    }
    return '';
  }

  static bool isSupportedAudioFormat(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.supportedAudioFormats.contains(extension);
  }

  static Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    if (await cacheDir.exists()) {
      await deleteDirectory(cacheDir.path);
      await cacheDir.create();
    }
  }

  static Future<int> getCacheSizeInBytes() async {
    final cacheDir = await getCacheDirectory();
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  static Future<List<File>> getDownloadedSounds() async {
    final soundsDir = await getSoundsDirectory();
    if (!await soundsDir.exists()) return [];

    final files = <File>[];
    await for (final entity in soundsDir.list()) {
      if (entity is File && isSupportedAudioFormat(entity.path)) {
        files.add(entity);
      }
    }
    return files;
  }
}