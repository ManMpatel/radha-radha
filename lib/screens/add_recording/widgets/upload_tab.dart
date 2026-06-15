import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../providers/audio_state_provider.dart';
import '../../../services/recording_service.dart';
import '../../../widgets/waveform_widget.dart';
import 'package:radharadha/generated/app_localizations.dart';

class UploadTab extends ConsumerStatefulWidget {
  final ValueChanged<String?> onFileSelected;
  final String? selectedPath;

  const UploadTab({
    super.key,
    required this.onFileSelected,
    this.selectedPath,
  });

  @override
  ConsumerState<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends ConsumerState<UploadTab> {
  bool _isLoading = false;
  String? _fileName;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    if (widget.selectedPath != null) {
      _fileName = widget.selectedPath!.split(Platform.pathSeparator).last;
      _loadDuration(widget.selectedPath!);
    }
  }

  Future<void> _loadDuration(String path) async {
    final p = AudioPlayer();
    final d = await p.setFilePath(path);
    await p.dispose();
    if (mounted) setState(() => _duration = d);
  }

  Future<void> _pickFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final source = result.files.single.path!;
        final dest = await RecordingService.copyFileToAppStorage(source);
        setState(() {
          _fileName = result.files.single.name;
        });
        await _loadDuration(dest);
        ref.read(previewPlayerProvider.notifier).loadFile(dest);
        widget.onFileSelected(dest);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnsupportedFormat),
            backgroundColor: AppColors.goldDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          // Upload zone
          GestureDetector(
            onTap: _isLoading ? null : () => _pickFile(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.selectedPath != null
                      ? AppColors.saffronPrimary
                      : AppColors.goldPrimary.withOpacity(0.4),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                color: (isDark ? AppColors.darkCard : AppColors.lightCard)
                    .withOpacity(0.6),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.saffronPrimary,
                      ),
                    )
                  : widget.selectedPath == null
                      ? _UploadPrompt(l10n: l10n, subColor: subColor)
                      : _FilePreview(
                          fileName: _fileName ?? '',
                          duration: _duration,
                          textColor: textColor,
                          subColor: subColor,
                        ),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

          // Audio preview player
          if (widget.selectedPath != null && preview.player != null) ...[
            const SizedBox(height: 20),
            _AudioPreviewPlayer(
              preview: preview,
              isDark: isDark,
              l10n: l10n,
            ).animate().fadeIn(delay: 100.ms),
          ],

          const SizedBox(height: 16),
          Text(
            l10n.supportedFormats,
            style: TextStyle(color: subColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _UploadPrompt extends StatelessWidget {
  final AppLocalizations l10n;
  final Color subColor;
  const _UploadPrompt({required this.l10n, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload_rounded, size: 52, color: AppColors.goldPrimary),
        const SizedBox(height: 12),
        Text(
          l10n.tapToUpload,
          style: TextStyle(
            color: subColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FilePreview extends StatelessWidget {
  final String fileName;
  final Duration? duration;
  final Color textColor;
  final Color subColor;

  const _FilePreview({
    required this.fileName,
    this.duration,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.audio_file_rounded, size: 44, color: AppColors.saffronPrimary),
          const SizedBox(height: 12),
          Text(
            fileName,
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (duration != null) ...[
            const SizedBox(height: 6),
            Text(
              DurationFormatter.formatPlayback(duration!),
              style: TextStyle(color: subColor, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioPreviewPlayer extends ConsumerWidget {
  final PreviewPlayerState preview;
  final bool isDark;
  final AppLocalizations l10n;

  const _AudioPreviewPlayer({
    required this.preview,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(previewPlayerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          WaveformWidget(
            isAnimating: preview.isPlaying,
            height: 36,
          ),
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
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
        ],
      ),
    );
  }
}
