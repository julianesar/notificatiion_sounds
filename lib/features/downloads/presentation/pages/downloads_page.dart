import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/downloads_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../tones/presentation/pages/tone_player_page.dart';
import '../../../tones/domain/entities/tone.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadsProvider>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descargas'),
        actions: [
          IconButton(
            onPressed: () => _showDownloadLocationInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información de descargas',
          ),
          Consumer<DownloadsProvider>(
            builder: (context, downloadsProvider, child) {
              if (downloadsProvider.downloads.isEmpty) return const SizedBox();
              
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar todo', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<DownloadsProvider>(
        builder: (context, downloadsProvider, child) {
          final downloads = downloadsProvider.downloads;
          final isLoading = downloadsProvider.isLoading;
          final hasError = downloadsProvider.hasError;

          if (isLoading && downloads.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError && downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar las descargas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      downloadsProvider.errorMessage ?? 'Error desconocido',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => downloadsProvider.retry(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (downloads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay descargas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los tonos que descargues aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => downloadsProvider.loadDownloads(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final download = downloads[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Consumer<AudioService>(
                    builder: (context, audioService, child) {
                      final isPlaying = audioService.isTonePlaying(download.id);
                      final isAudioLoading = audioService.isLoading && 
                          audioService.currentlyPlayingId == download.id;
                      
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () => _toggleAudioPlay(audioService, download),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isAudioLoading
                                  ? SizedBox(
                                      key: const ValueKey('loading'),
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying ? Icons.stop : Icons.play_arrow,
                                      key: ValueKey(isPlaying ? 'stop' : 'play'),
                                      color: Theme.of(context).primaryColor,
                                    ),
                            ),
                          ),
                        ),
                        title: Text(
                          download.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.download_done, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Descargado el ${_formatDate(download.downloadedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showOptionsMenu(context, download),
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'Opciones',
                            ),
                          ],
                        ),
                        onTap: () => _openPlayer(context, download),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleAudioPlay(AudioService audioService, download) async {
    try {
      // Use local file path instead of URL for downloaded tones
      await audioService.toggleTone(download.id, 'file://${download.localPath}');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Error al reproducir audio: $e');
      }
    }
  }

  void _openPlayer(BuildContext context, download) {
    // Convert downloaded tone to regular tone for player
    final tone = Tone(
      id: download.id,
      title: download.title,
      url: 'file://${download.localPath}', // Use local file
      requiresAttribution: download.requiresAttribution,
      attributionText: download.attributionText,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TonePlayerPage(
          tone: tone,
          categoryTitle: 'Descargas',
          tones: [tone], // Single tone for downloaded items
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, download) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Abrir reproductor'),
                onTap: () {
                  Navigator.pop(context);
                  _openPlayer(context, download);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar(context, 'Compartiendo ${download.title}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar descarga', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, download);
                },
              ),
              if (download.requiresAttribution) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Información de atribución'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAttributionDialog(context, download);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, download) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar descarga'),
        content: Text('¿Estás seguro de que quieres eliminar "${download.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadsProvider>().deleteToneDownload(download.id);
              _showSnackBar(context, 'Descarga eliminada');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todo'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las descargas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear all functionality
              _showSnackBar(context, 'Función próximamente disponible');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAttributionDialog(BuildContext context, download) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de atribución'),
        content: Text(
          download.attributionText ?? 'Sin información disponible',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDownloadLocationInfo(BuildContext context) {
    final String downloadLocation = Platform.isAndroid 
        ? 'Documentos de la aplicación/downloads/'
        : 'Documentos de la aplicación/downloads/';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.folder_open),
            SizedBox(width: 8),
            Text('Ubicación de descargas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tus tonos descargados se guardan en:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                downloadLocation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (Platform.isAndroid) ...[
              const Text(
                '📱 En Android:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Los archivos están en el área privada de la app'),
              const Text('• Solo accesibles desde esta aplicación'),
              const Text('• Se eliminan si desinstalas la app'),
              const SizedBox(height: 8),
            ],
            if (Platform.isIOS) ...[
              const Text(
                '🍎 En iOS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Los archivos están en el área privada de la app'),
              const Text('• Solo accesibles desde esta aplicación'),
              const Text('• Se eliminan si desinstalas la app'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Permisos: No requeridos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}