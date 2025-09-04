import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/tone.dart';
import '../../../../core/services/audio_service.dart';

class TonePlayerPage extends StatefulWidget {
  final Tone tone;
  final String categoryTitle;

  const TonePlayerPage({
    super.key,
    required this.tone,
    required this.categoryTitle,
  });

  @override
  State<TonePlayerPage> createState() => _TonePlayerPageState();
}

class _TonePlayerPageState extends State<TonePlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    final audioService = context.read<AudioService>();
    try {
      await audioService.toggleTone(widget.tone.id, widget.tone.url);
    } catch (e) {
      _showErrorSnackBar('Error al reproducir audio: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


  void _seekTo(double value) async {
    final audioService = context.read<AudioService>();
    final duration = audioService.duration;
    if (duration != null) {
      final position = Duration(milliseconds: (value * duration.inMilliseconds).round());
      await audioService.seekTo(position);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          'Reproductor',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Album Art / Visualization
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.8),
                          colorScheme.secondary.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * 3.14159,
                          child: Icon(
                            Icons.audiotrack,
                            size: 120,
                            color: colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Song Info
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      widget.tone.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.categoryTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress Bar
              Consumer<AudioService>(
                builder: (context, audioService, child) {
                  final duration = audioService.duration ?? Duration.zero;
                  final position = audioService.position;
                  final progress = audioService.progress;
                  
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: colorScheme.surfaceContainerHighest,
                          thumbColor: colorScheme.primary,
                          overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: duration.inMilliseconds > 0 ? _seekTo : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              audioService.formatDuration(position),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              audioService.formatDuration(duration),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      final audioService = context.read<AudioService>();
                      audioService.seekTo(Duration.zero);
                    },
                    icon: Icon(
                      Icons.replay_10,
                      size: 32,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Consumer<AudioService>(
                    builder: (context, audioService, child) {
                      final isCurrentTonePlaying = audioService.isTonePlaying(widget.tone.id);
                      final isLoading = audioService.isLoading && audioService.currentlyPlayingId == widget.tone.id;
                      
                      // Control animation based on audio service state
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          if (isCurrentTonePlaying && !_rotationController.isAnimating) {
                            _rotationController.repeat();
                          } else if (!isCurrentTonePlaying && _rotationController.isAnimating) {
                            _rotationController.stop();
                          }
                        }
                      });
                      
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: isLoading ? null : _togglePlayPause,
                          icon: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  isCurrentTonePlaying ? Icons.stop : Icons.play_arrow,
                                  size: 40,
                                  color: colorScheme.onPrimary,
                                ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      final audioService = context.read<AudioService>();
                      final currentPosition = audioService.position;
                      final newPosition = currentPosition + const Duration(seconds: 10);
                      audioService.seekTo(newPosition);
                    },
                    icon: Icon(
                      Icons.forward_10,
                      size: 32,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
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
                leading: const Icon(Icons.download),
                title: const Text('Descargar'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar(context, 'Función de descarga próximamente');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar(context, 'Compartiendo ${widget.tone.title}');
                },
              ),
              if (widget.tone.requiresAttribution) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Información de atribución'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAttributionDialog(context);
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAttributionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de atribución'),
        content: Text(widget.tone.attributionText ?? 'Sin información disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}