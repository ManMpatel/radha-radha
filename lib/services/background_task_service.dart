import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:just_audio/just_audio.dart';
import '../core/constants/app_constants.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(RadhaTaskHandler());
}

class RadhaTaskHandler extends TaskHandler {
  final Map<String, Timer> _timers = {};
  final Map<String, AudioPlayer> _players = {};
  final Set<String> _starting = {};

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // ignore: avoid_print
    print('[Radha] Task handler started');
    // Configure audio session in THIS isolate
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      // ignore: avoid_print
      print('[Radha] Audio session configured');
    } catch (e) {
      // ignore: avoid_print
      print('[Radha] Audio session error: $e');
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _stopAllTimers();
  }

  @override
  void onReceiveData(Object data) {
    // ignore: avoid_print
    print('[Radha] onReceiveData called, type=${data.runtimeType}, data=$data');

    // FIX: data arrives as Map<Object?, Object?> from platform channel —
    // NOT Map<String, dynamic>. Must use Map.from() to cast safely.
    if (data is! Map) {
      // ignore: avoid_print
      print('[Radha] Unexpected data type: ${data.runtimeType}');
      return;
    }

    final map = Map<String, dynamic>.from(data);
    final action = map['action'] as String?;
    // ignore: avoid_print
    print('[Radha] Action received: $action');

    switch (action) {
      case 'start':
        _startTimer(
          map['id'] as String,
          map['filePath'] as String,
          map['intervalSeconds'] as int,
        );
        break;
      case 'stop':
        _stopTimer(map['id'] as String);
        break;
      case 'stopAll':
        _stopAllTimers();
        break;
      case 'skipOnCall':
        _handleCallStarted();
        break;
      case 'resumeAfterCall':
        break;
    }
  }

  void _startTimer(String id, String filePath, int intervalSeconds) {
    // ignore: avoid_print
    print('[Radha] Starting timer: id=$id interval=${intervalSeconds}s');
    _stopTimer(id);
    _timers[id] = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _playAudio(id, filePath),
    );
  }

  Future<void> _stopTimer(String id) async {
    _timers[id]?.cancel();
    _timers.remove(id);
    _starting.remove(id);
    final player = _players.remove(id);
    if (player != null) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {}
    }
  }

  Future<void> _stopAllTimers() async {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _starting.clear();
    final players = Map<String, AudioPlayer>.from(_players);
    _players.clear();
    for (final p in players.values) {
      try {
        await p.stop();
        await p.dispose();
      } catch (_) {}
    }
  }

  Future<void> _handleCallStarted() async {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _starting.clear();
    final players = Map<String, AudioPlayer>.from(_players);
    _players.clear();
    for (final p in players.values) {
      try {
        await p.stop();
        await p.dispose();
      } catch (_) {}
    }
  }

  Future<void> _playAudio(String id, String filePath) async {
    // ignore: avoid_print
    print('[Radha] _playAudio called: id=$id');

    if (_starting.contains(id)) {
      // ignore: avoid_print
      print('[Radha] Skipping — already starting: $id');
      return;
    }

    try {
      _starting.add(id);

      final existing = _players[id];
      if (existing != null && existing.playing) {
        // ignore: avoid_print
        print('[Radha] Skipping — already playing: $id');
        return;
      }

      if (existing != null) {
        _players.remove(id);
        try {
          await existing.stop();
          await existing.dispose();
        } catch (_) {}
      }

      final session = await AudioSession.instance;
      await session.setActive(true);

      final player = AudioPlayer();
      _players[id] = player;
      await player.setFilePath(filePath);
      await player.play();
      // ignore: avoid_print
      print('[Radha] Playing audio: $filePath');

      player.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed) {
          if (_players[id] == player) {
            _players.remove(id);
            try {
              await player.dispose();
            } catch (_) {}
          }
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('[Radha] _playAudio error ($id): $e');
      final p = _players.remove(id);
      try {
        await p?.stop();
        await p?.dispose();
      } catch (_) {}
    } finally {
      _starting.remove(id);
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

  static void startRecordingTimer(
      String id, String filePath, int intervalSeconds) {
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