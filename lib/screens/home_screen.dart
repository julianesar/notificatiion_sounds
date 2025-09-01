import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/ringtone.dart';
import '../providers/theme_provider.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Sample categories
    final List<Category> categories = [
      Category(id: '1', name: 'Popular', icon: ' trending_up', ringtoneCount: 24),
      Category(id: '2', name: 'Nature', icon: ' forest', ringtoneCount: 18),
      Category(id: '3', name: 'Electronic', icon: ' bolt', ringtoneCount: 32),
      Category(id: '4', name: 'Classical', icon: ' music_note', ringtoneCount: 15),
      Category(id: '5', name: 'Rock', icon: ' music_video', ringtoneCount: 22),
      Category(id: '6', name: 'Jazz', icon: ' radio', ringtoneCount: 19),
    ];

    // Sample ringtones
    final List<Ringtone> ringtones = [
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
        id: '2',
        title: 'Digital Dreams',
        artist: 'Synth Masters',
        category: 'Electronic',
        duration: '0:45',
        filePath: 'assets/digital_dreams.mp3',
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
        title: const Text('Ringtone Manager'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                  category: category,
                  onTap: () {
                    // Navigate to category detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailScreen(
                          categoryName: category.name,
                          ringtones: ringtones
                              .where((r) => r.category == category.name)
                              .toList(),
                        ),
                      ),
                    );
                  },
                );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new ringtone screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(category.icon),
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${category.ringtoneCount} ringtones',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconString) {
    switch (iconString.trim()) {
      case 'trending_up':
        return Icons.trending_up;
      case 'forest':
        return Icons.forest;
      case 'bolt':
        return Icons.bolt;
      case 'music_note':
        return Icons.music_note;
      case 'music_video':
        return Icons.music_video;
      case 'radio':
        return Icons.radio;
      default:
        return Icons.category;
    }
  }
}