import 'package:flutter/material.dart';
import '../models/ringtone.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample favorite ringtones
    final List<Ringtone> favoriteRingtones = [
      Ringtone(
        id: '1',
        title: 'Morning Breeze',
        artist: 'Nature Sounds',
        category: 'Nature',
        duration: '0:30',
        filePath: 'assets/morning_breeze.mp3',
        isFavorite: true,
      ),
      Ringtone(
        id: '3',
        title: 'Beethoven Classics',
        artist: 'Beethoven',
        category: 'Classical',
        duration: '1:20',
        filePath: 'assets/beethoven.mp3',
        isFavorite: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoriteRingtones.isEmpty
          ? const Center(
              child: Text(
                'No favorite ringtones yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteRingtones.length,
              itemBuilder: (context, index) {
                final ringtone = favoriteRingtones[index];
                return _FavoriteRingtoneItem(ringtone: ringtone);
              },
            ),
    );
  }
}

class _FavoriteRingtoneItem extends StatelessWidget {
  final Ringtone ringtone;

  const _FavoriteRingtoneItem({required this.ringtone});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(ringtone.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        // Remove from favorites
      },
      child: Card(
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
          trailing: IconButton(
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              // Navigate to player screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(ringtone: ringtone),
                ),
              );
            },
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
      ),
    );
  }
}