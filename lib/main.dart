import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'core/network/api_client.dart';
import 'features/categories/data/datasources/categories_remote_ds.dart';
import 'features/categories/data/repositories/categories_repository_impl.dart';
import 'features/categories/domain/usecases/get_categories.dart';
import 'features/categories/presentation/providers/categories_provider.dart';
import 'features/tones/data/datasources/tones_remote_ds.dart';
import 'features/tones/data/repositories/tones_repository_impl.dart';
import 'features/tones/domain/usecases/get_tones_by_category.dart';
import 'features/tones/presentation/providers/tones_provider.dart';
import 'core/services/audio_service.dart';

void main() async {
  // Asegurarse de que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización perezosa del singleton
  AppConfig.I();

  // Obtener instancia de ApiClient de forma asíncrona
  final apiClient = await ApiClient.getInstance();
  
  // Initialize audio service
  await AudioService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: AudioService.instance),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(
            GetCategories(
              CategoriesRepositoryImpl(CategoriesRemoteDS(apiClient)),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TonesProvider(
            GetTonesByCategory(TonesRepositoryImpl(TonesRemoteDS(apiClient))),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sonidos de Notificaciones',
          theme: themeProvider.currentTheme,
          darkTheme: themeProvider.currentTheme.copyWith(
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
