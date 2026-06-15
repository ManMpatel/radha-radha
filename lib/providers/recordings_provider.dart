import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording_model.dart';
import '../services/storage_service.dart';
import '../services/background_task_service.dart';

class RecordingsNotifier extends StateNotifier<List<RecordingModel>> {
  RecordingsNotifier() : super([]) {
    _loadAll();
  }

  void _loadAll() {
    state = StorageService.getAllRecordings();
  }

  Future<void> addRecording(RecordingModel recording) async {
    await StorageService.saveRecording(recording);
    _loadAll();
  }

  Future<void> updateRecording(RecordingModel recording) async {
    await StorageService.updateRecording(recording);
    _loadAll();
  }

  Future<void> deleteRecording(String id) async {
    final recording = state.firstWhere((r) => r.id == id, orElse: () => throw StateError('Not found'));
    if (recording.isActive) {
      BackgroundTaskService.stopRecordingTimer(id);
    }
    await StorageService.deleteRecording(id);
    _loadAll();
  }

  Future<void> toggleActive(String id) async {
    final index = state.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final recording = state[index];
    final newActive = !recording.isActive;

    final updated = recording.copyWith(isActive: newActive);
    await StorageService.updateRecording(updated);

    if (newActive) {
      await BackgroundTaskService.startService();
      BackgroundTaskService.startRecordingTimer(
        id,
        recording.filePath,
        recording.intervalSeconds,
      );
    } else {
      BackgroundTaskService.stopRecordingTimer(id);
    }

    _loadAll();
  }

  Future<void> startAll() async {
    bool anyStarted = false;
    for (final r in state) {
      if (!r.isActive) {
        final updated = r.copyWith(isActive: true);
        await StorageService.updateRecording(updated);
        anyStarted = true;
      }
    }
    if (anyStarted) {
      await BackgroundTaskService.startService();
      for (final r in state) {
        BackgroundTaskService.startRecordingTimer(r.id, r.filePath, r.intervalSeconds);
      }
      _loadAll();
    }
  }

  Future<void> stopAll() async {
    for (final r in state) {
      if (r.isActive) {
        final updated = r.copyWith(isActive: false);
        await StorageService.updateRecording(updated);
      }
    }
    BackgroundTaskService.stopAllTimers();
    await BackgroundTaskService.stopService();
    _loadAll();
  }

  Future<void> updateLastPlayed(String id) async {
    final recording = StorageService.getRecording(id);
    if (recording == null) return;
    final updated = recording.copyWith(lastPlayedAt: DateTime.now());
    await StorageService.updateRecording(updated);
    _loadAll();
  }

  int get activeCount => state.where((r) => r.isActive).length;

  void restoreActiveTimers() async {
    final activeRecordings = state.where((r) => r.isActive).toList();
    if (activeRecordings.isEmpty) return;
    await BackgroundTaskService.startService();
    for (final r in activeRecordings) {
      BackgroundTaskService.startRecordingTimer(r.id, r.filePath, r.intervalSeconds);
    }
  }
}

final recordingsProvider = StateNotifierProvider<RecordingsNotifier, List<RecordingModel>>(
  (ref) => RecordingsNotifier(),
);
