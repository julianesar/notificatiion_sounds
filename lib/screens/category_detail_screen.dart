import 'package:flutter/material.dart';
import '../models/ringtone.dart';
import 'player_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final List<Ringtone> ringtones;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.ringtones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: ringtones.length,
        itemBuilder: (context, index) {
          final ringtone = ringtones[index];
          return _RingtoneListItem(ringtone: ringtone);
        },
      ),
    );
  }
}

class _RingtoneListItem extends StatelessWidget {
  final Ringtone ringtone;

  const _RingtoneListItem({required this.ringtone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          ringtone.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${ringtone.artist} • ${ringtone.duration}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                ringtone.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: ringtone.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                // Toggle favorite status
              },
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Download ringtone
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to player screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(ringtone: ringtone),
            ),
          );
        },
      ),
    );
  }
}