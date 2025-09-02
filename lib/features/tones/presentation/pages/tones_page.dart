import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tones_provider.dart';

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
        builder: (context, provider, child) {
          final tones = provider.getTonesForCategory(widget.categoryId);
          final isLoading = provider.isCategoryLoading(widget.categoryId);
          final hasError = provider.hasError;

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
                      provider.errorMessage ?? 'Error desconocido',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.retry(widget.categoryId),
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
            onRefresh: () => provider.load(widget.categoryId),
            child: ListView.builder(
              addAutomaticKeepAlives: false,
              padding: const EdgeInsets.all(16),
              itemCount:
                  tones.length +
                  (provider.hasMoreTones(widget.categoryId) ? 1 : 0),
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
                          onPressed: () => provider.loadMore(widget.categoryId),
                          child: const Text('Cargar más'),
                        ),
                      ),
                    );
                  }
                }

                final tone = tones[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.audiotrack,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      tone.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: tone.attributionText != null
                        ? Text(
                            tone.attributionText!,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    trailing: tone.requiresAttribution
                        ? const Icon(Icons.info, color: Colors.orange)
                        : const Icon(Icons.play_arrow),
                    onTap: () => _showToneSnackBar(context, tone),
                  ),
                );
              },
            ),
          );
        },
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
