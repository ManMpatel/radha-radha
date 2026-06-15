import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_playback_service.dart';

class PreviewPlayerState {
  final AudioPlayer? player;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;

  const PreviewPlayerState({
    this.player,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration,
  });

  PreviewPlayerState copyWith({
    AudioPlayer? player,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) =>
      PreviewPlayerState(
        player: player ?? this.player,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
      );
}

class PreviewPlayerNotifier extends StateNotifier<PreviewPlayerState> {
  PreviewPlayerNotifier() : super(const PreviewPlayerState());

  Future<void> _cleanup() async {
    await state.player?.stop();
    await state.player?.dispose();
    if (mounted) state = const PreviewPlayerState();
  }

  Future<void> loadFile(String filePath) async {
    await _cleanup();
    final player = await AudioPlaybackService.createPreviewPlayer(filePath);

    state = PreviewPlayerState(
      player: player,
      isPlaying: false,
      position: Duration.zero,
      duration: player.duration,
    );

    player.positionStream.listen((pos) {
      if (mounted) state = state.copyWith(position: pos);
    });
    player.playerStateStream.listen((s) {
      if (mounted) {
        state = state.copyWith(isPlaying: s.playing);
        if (s.processingState == ProcessingState.completed) {
          state = state.copyWith(isPlaying: false, position: Duration.zero);
          player.seek(Duration.zero);
        }
      }
    });
  }

  Future<void> togglePlay() async {
    final player = state.player;
    if (player == null) return;
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await state.player?.seek(position);
  }

  @override
  Future<void> dispose() async {
    await _cleanup();
    super.dispose();
  }
}

final previewPlayerProvider =
    StateNotifierProvider.autoDispose<PreviewPlayerNotifier, PreviewPlayerState>(
  (ref) {
    final notifier = PreviewPlayerNotifier();
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);
