class AppConstants {
  AppConstants._();

  static const String appName = 'Radha Radha';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.radhaapps.radharadha';
  static const String developerName = 'Radha Apps';

  // Hive box names
  static const String recordingsBox = 'recordings';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String keyTheme = 'theme';
  static const String keyLanguage = 'language';
  static const String keyDefaultInterval = 'default_interval';

  // Intervals
  static const int minIntervalSeconds = 3;
  static const int defaultIntervalSeconds = 600; // 10 minutes

  // Foreground task
  static const int foregroundTaskId = 1001;
  static const String foregroundTaskChannelId = 'radha_radha_bg';
  static const String foregroundTaskChannelName = 'Radha Radha';

  // Notification (minimized/silent)
  static const String notificationTitle = '';
  static const String notificationText = '';

  // Audio
  static const List<String> supportedExtensions = ['mp3', 'wav', 'm4a', 'aac', 'ogg'];
  static const String defaultRecordFormat = 'm4a';

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // UI
  static const double cardBorderRadius = 20;
  static const double buttonBorderRadius = 30;
  static const double inputBorderRadius = 16;
}
