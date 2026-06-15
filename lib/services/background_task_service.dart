import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:just_audio/just_audio.dart';
import '../core/constants/app_constants.dart';

// Top-level entry point required by flutter_foreground_task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(RadhaTaskHandler());
}

class RadhaTaskHandler extends TaskHandler {
  final Map<String, Timer> _timers = {};
  final Map<String, AudioPlayer> _players = {};

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Main periodic heartbeat — timers handle their own scheduling
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _stopAllTimers();
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      switch (action) {
        case 'start':
          _startTimer(
            data['id'] as String,
            data['filePath'] as String,
            data['intervalSeconds'] as int,
          );
          break;
        case 'stop':
          _stopTimer(data['id'] as String);
          break;
        case 'stopAll':
          _stopAllTimers();
          break;
        case 'skipOnCall':
          _handleCallStarted();
          break;
        case 'resumeAfterCall':
          // Timers auto-resume; no extra action needed
          break;
      }
    }
  }

  void _startTimer(String id, String filePath, int intervalSeconds) {
    _stopTimer(id);
    _timers[id] = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _playAudio(id, filePath),
    );
  }

  void _stopTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _players[id]?.stop();
    _players[id]?.dispose();
    _players.remove(id);
  }

  void _stopAllTimers() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }

  void _handleCallStarted() {
    // Reset all timers — they will fire at their next interval after call ends
    final entries = Map<String, Timer>.from(_timers);
    for (final entry in entries.entries) {
      entry.value.cancel();
    }
    _timers.clear();
  }

  Future<void> _playAudio(String id, String filePath) async {
    try {
      final existing = _players[id];
      if (existing != null && existing.playing) return;

      final player = AudioPlayer();
      _players[id] = player;
      await player.setFilePath(filePath);
      await player.play();
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
          if (_players[id] == player) _players.remove(id);
        }
      });
    } catch (_) {
      _players.remove(id);
    }
  }
}

class BackgroundTaskService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.foregroundTaskChannelId,
        channelName: AppConstants.foregroundTaskChannelName,
        channelDescription: '',
        channelImportance: NotificationChannelImportance.NONE,
        priority: NotificationPriority.MIN,
        enableVibration: false,
        playSound: false,
        showWhen: false,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> startService() async {
    await init();
    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      notificationTitle: '',
      notificationText: '',
      callback: startCallback,
    );
  }

  static Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  static void sendData(Map<String, dynamic> data) {
    FlutterForegroundTask.sendDataToTask(data);
  }

  static void startRecordingTimer(String id, String filePath, int intervalSeconds) {
    sendData({
      'action': 'start',
      'id': id,
      'filePath': filePath,
      'intervalSeconds': intervalSeconds,
    });
  }

  static void stopRecordingTimer(String id) {
    sendData({'action': 'stop', 'id': id});
  }

  static void stopAllTimers() {
    sendData({'action': 'stopAll'});
  }

  static void notifyCallStarted() {
    sendData({'action': 'skipOnCall'});
  }

  static void notifyCallEnded() {
    sendData({'action': 'resumeAfterCall'});
  }

}
