import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tones_provider.dart';
import 'tone_player_page.dart';
import '../../../../core/services/audio_service.dart';

class TonesPage extends StatefulWidget {
  final String categoryId;
  final String title;

  const TonesPage({super.key, required this.categoryId, required this.title});

  @override
  State<TonesPage> createState() => _TonesPageState();
}

class _TonesPageState extends State<TonesPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TonesProvider>().load(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Consumer<TonesProvider>(
        builder: (context, tonesProvider, child) {
          final tones = tonesProvider.getTonesForCategory(widget.categoryId);
          final isLoading = tonesProvider.isCategoryLoading(widget.categoryId);
          final hasError = tonesProvider.hasError;
          

          if (isLoading && tones.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError && tones.isEmpty) {
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
                    'Error al cargar los tonos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      tonesProvider.errorMessage ?? 'Error desconocido',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => tonesProvider.retry(widget.categoryId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (tones.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay tonos disponibles',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => tonesProvider.load(widget.categoryId),
            child: ListView.builder(
              addAutomaticKeepAlives: false,
              padding: const EdgeInsets.all(16),
              itemCount:
                  tones.length +
                  (tonesProvider.hasMoreTones(widget.categoryId) ? 1 : 0),
              itemBuilder: (context, index) {
                // Mostrar indicador de carga al final si hay más tonos
                if (index == tones.length) {
                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => tonesProvider.loadMore(widget.categoryId),
                          child: const Text('Cargar más'),
                        ),
                      ),
                    );
                  }
                }

                final tone = tones[index];
                return Card(
                  key: ValueKey(tone.id), // Add unique key for each card
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Consumer<AudioService>(
                    builder: (context, audioService, child) {
                      final isPlaying = audioService.isTonePlaying(tone.id);
                      final isAudioLoading = audioService.isLoading && audioService.currentlyPlayingId == tone.id;
                      
                      // Debug print
                      print('Card ${tone.id}: isPlaying=$isPlaying, isLoading=$isAudioLoading, currentId=${audioService.currentlyPlayingId}');
                      
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () => _toggleAudioPlay(audioService, tone),
                          child: Container(
                            key: ValueKey('${tone.id}_button'), // Unique key for button
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
                          tone.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _toggleFavorite(tone),
                              icon: const Icon(Icons.favorite_border),
                              tooltip: 'Agregar a favoritos',
                            ),
                            IconButton(
                              onPressed: () => _openPlayer(context, tone),
                              icon: const Icon(Icons.arrow_forward),
                              tooltip: 'Abrir reproductor',
                            ),
                          ],
                        ),
                        onTap: () => _openPlayer(context, tone),
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

  Future<void> _toggleAudioPlay(AudioService audioService, tone) async {
    try {
      await audioService.toggleTone(tone.id, tone.url);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, 'Error al reproducir audio: $e');
      }
    }
  }

  void _toggleFavorite(tone) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de favoritos próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPlayer(BuildContext context, tone) {
    final tonesProvider = context.read<TonesProvider>();
    final tones = tonesProvider.getTonesForCategory(widget.categoryId);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TonePlayerPage(
          tone: tone,
          categoryTitle: widget.title,
          tones: tones,
        ),
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

  void _showToneSnackBar(BuildContext context, tone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('URL: ${tone.url}'),
            if (tone.requiresAttribution && tone.attributionText != null) ...[
              const SizedBox(height: 4),
              Text(
                'Atribución: ${tone.attributionText}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
