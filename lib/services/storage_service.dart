import 'package:hive_flutter/hive_flutter.dart';
import '../models/recording_model.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static Box<RecordingModel>? _recordingsBox;
  static Box? _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecordingModelAdapter());
    }
    _recordingsBox = await Hive.openBox<RecordingModel>(AppConstants.recordingsBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  static Box<RecordingModel> get recordingsBox {
    if (_recordingsBox == null) throw StateError('StorageService not initialized');
    return _recordingsBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null) throw StateError('StorageService not initialized');
    return _settingsBox!;
  }

  // Recordings CRUD
  static List<RecordingModel> getAllRecordings() {
    return recordingsBox.values.toList();
  }

  static RecordingModel? getRecording(String id) {
    try {
      return recordingsBox.values.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRecording(RecordingModel recording) async {
    await recordingsBox.put(recording.id, recording);
  }

  static Future<void> deleteRecording(String id) async {
    await recordingsBox.delete(id);
  }

  static Future<void> updateRecording(RecordingModel recording) async {
    await recordingsBox.put(recording.id, recording);
  }

  // Settings
  static bool isDarkMode() {
    return _settingsBox?.get(AppConstants.keyTheme, defaultValue: false) as bool;
  }

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox?.put(AppConstants.keyTheme, value);
  }

  static String getLanguage() {
    return _settingsBox?.get(AppConstants.keyLanguage, defaultValue: 'en') as String;
  }

  static Future<void> setLanguage(String locale) async {
    await _settingsBox?.put(AppConstants.keyLanguage, locale);
  }

  static int getDefaultInterval() {
    return _settingsBox?.get(
          AppConstants.keyDefaultInterval,
          defaultValue: AppConstants.defaultIntervalSeconds,
        ) as int;
  }

  static Future<void> setDefaultInterval(int seconds) async {
    await _settingsBox?.put(AppConstants.keyDefaultInterval, seconds);
  }
}
