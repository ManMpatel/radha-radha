import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../providers/audio_state_provider.dart';
import '../../../services/recording_service.dart';
import '../../../widgets/animated_mic_button.dart';
import '../../../widgets/waveform_widget.dart';
import 'package:radharadha/generated/app_localizations.dart';

class RecordTab extends ConsumerStatefulWidget {
  final ValueChanged<String?> onRecordingComplete;
  final String? existingPath;

  const RecordTab({
    super.key,
    required this.onRecordingComplete,
    this.existingPath,
  });

  @override
  ConsumerState<RecordTab> createState() => _RecordTabState();
}

class _RecordTabState extends ConsumerState<RecordTab> {
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _recordedPath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.existingPath != null) {
      _recordedPath = widget.existingPath;
      _hasRecording = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(previewPlayerProvider.notifier).loadFile(widget.existingPath!);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) RecordingService.cancelRecording();
    super.dispose();
  }

  Future<void> _toggleRecording(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording(context, l10n);
    }
  }

  Future<void> _startRecording(BuildContext context, AppLocalizations l10n) async {
    final hasPermission = await RecordingService.hasPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.microphonePermission),
            backgroundColor: AppColors.goldDark,
          ),
        );
      }
      return;
    }

    await RecordingService.startRecording();
    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
      _hasRecording = false;
      _recordedPath = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await RecordingService.stopRecording();
    if (path != null && mounted) {
      setState(() {
        _isRecording = false;
        _hasRecording = true;
        _recordedPath = path;
      });
      ref.read(previewPlayerProvider.notifier).loadFile(path);
      widget.onRecordingComplete(path);
    }
  }

  void _reRecord() async {
    ref.read(previewPlayerProvider.notifier).dispose();
    if (_recordedPath != null) {
      await RecordingService.deleteRecordingFile(_recordedPath!);
    }
    setState(() {
      _hasRecording = false;
      _recordedPath = null;
    });
    widget.onRecordingComplete(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final preview = ref.watch(previewPlayerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Mic button
          Center(
            child: AnimatedMicButton(
              isRecording: _isRecording,
              onTap: () => _toggleRecording(context),
              size: 100,
            ),
          ),
          const SizedBox(height: 20),
          // Status text
          if (_isRecording)
            Text(
              l10n.recordingInProgress,
              style: const TextStyle(
                color: AppColors.stoppedRed,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn()
          else if (!_hasRecording)
            Text(
              l10n.pressToRecord,
              style: TextStyle(color: subColor, fontSize: 14),
            ).animate().fadeIn(),

          const SizedBox(height: 16),

          // Timer
          if (_isRecording)
            Text(
              DurationFormatter.formatDuration(_elapsed),
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ).animate().fadeIn(),

          // Waveform while recording
          if (_isRecording) ...[
            const SizedBox(height: 16),
            const WaveformWidget(
              isAnimating: true,
              height: 50,
              barCount: 30,
            ).animate().fadeIn(),
          ],

          // Preview player after recording
          if (_hasRecording && preview.player != null) ...[
            const SizedBox(height: 20),
            _PreviewSection(
              preview: preview,
              isDark: isDark,
              l10n: l10n,
              onReRecord: _reRecord,
            ).animate().fadeIn(delay: 100.ms),
          ],
        ],
      ),
    );
  }
}

class _PreviewSection extends ConsumerWidget {
  final PreviewPlayerState preview;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onReRecord;

  const _PreviewSection({
    required this.preview,
    required this.isDark,
    required this.l10n,
    required this.onReRecord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(previewPlayerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          WaveformWidget(isAnimating: preview.isPlaying, height: 40),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  preview.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.saffronPrimary,
                ),
                onPressed: () => notifier.togglePlay(),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: AppColors.saffronPrimary,
                    inactiveTrackColor: AppColors.saffronPrimary.withOpacity(0.2),
                    thumbColor: AppColors.saffronPrimary,
                  ),
                  child: Slider(
                    value: preview.duration != null
                        ? preview.position.inMilliseconds /
                            (preview.duration!.inMilliseconds == 0
                                ? 1
                                : preview.duration!.inMilliseconds)
                        : 0,
                    onChanged: (v) {
                      if (preview.duration != null) {
                        notifier.seek(
                          Duration(
                            milliseconds:
                                (v * preview.duration!.inMilliseconds).round(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Text(
                preview.duration != null
                    ? DurationFormatter.formatPlayback(preview.duration!)
                    : '--:--',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onReRecord,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.reRecord),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.stoppedRed,
            ),
          ),
        ],
      ),
    );
  }
}
