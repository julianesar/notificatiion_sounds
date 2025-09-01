enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static late Environment _environment;
  static late AppConfig _instance;

  final String baseUrl;
  final String apiKey;
  final bool enableLogging;
  final bool enableCrashReporting;
  final String databaseName;
  final Duration cacheTimeout;
  final int maxConcurrentDownloads;

  AppConfig._({
    required this.baseUrl,
    required this.apiKey,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.databaseName,
    required this.cacheTimeout,
    required this.maxConcurrentDownloads,
  });

  static void initialize(Environment environment) {
    _environment = environment;
    
    switch (environment) {
      case Environment.development:
        _instance = AppConfig._(
          baseUrl: 'https://dev-api.notification-sounds.com',
          apiKey: 'dev_api_key_here',
          enableLogging: true,
          enableCrashReporting: false,
          databaseName: 'notification_sounds_dev.db',
          cacheTimeout: const Duration(minutes: 5),
          maxConcurrentDownloads: 2,
        );
        break;
      case Environment.staging:
        _instance = AppConfig._(
          baseUrl: 'https://staging-api.notification-sounds.com',
          apiKey: 'staging_api_key_here',
          enableLogging: true,
          enableCrashReporting: true,
          databaseName: 'notification_sounds_staging.db',
          cacheTimeout: const Duration(minutes: 15),
          maxConcurrentDownloads: 3,
        );
        break;
      case Environment.production:
        _instance = AppConfig._(
          baseUrl: 'https://api.notification-sounds.com',
          apiKey: 'prod_api_key_here',
          enableLogging: false,
          enableCrashReporting: true,
          databaseName: 'notification_sounds.db',
          cacheTimeout: const Duration(hours: 1),
          maxConcurrentDownloads: 3,
        );
        break;
    }
  }

  static AppConfig get instance {
    return _instance;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}