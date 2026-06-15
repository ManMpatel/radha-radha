import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlaybackService {
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
    ));
  }

  static Future<void> playFile(String recordingId, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      await stopPlaying(recordingId);

      final player = AudioPlayer();
      _players[recordingId] = player;

      await player.setFilePath(filePath);
      await player.play();

      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
          _players.remove(recordingId);
        }
      });
    } catch (e) {
      _players.remove(recordingId);
      rethrow;
    }
  }

  static Future<void> stopPlaying(String recordingId) async {
    final player = _players[recordingId];
    if (player != null) {
      await player.stop();
      await player.dispose();
      _players.remove(recordingId);
    }
  }

  static Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
      await player.dispose();
    }
    _players.clear();
  }

  static bool isPlaying(String recordingId) {
    return _players.containsKey(recordingId);
  }

  static Future<Duration?> getFileDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      final duration = await player.setFilePath(filePath);
      await player.dispose();
      return duration;
    } catch (_) {
      return null;
    }
  }

  static Future<AudioPlayer> createPreviewPlayer(String filePath) async {
    final player = AudioPlayer();
    await player.setFilePath(filePath);
    return player;
  }

  static void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
