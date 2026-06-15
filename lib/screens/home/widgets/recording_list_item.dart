import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/recording_model.dart';
import '../../../providers/recordings_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/interval_display.dart';
import '../../../widgets/waveform_widget.dart';
import '../../edit_recording/edit_recording_screen.dart';
import 'package:radharadha/generated/app_localizations.dart';

class RecordingListItem extends ConsumerStatefulWidget {
  final RecordingModel recording;
  final int index;

  const RecordingListItem({
    super.key,
    required this.recording,
    required this.index,
  });

  @override
  ConsumerState<RecordingListItem> createState() => _RecordingListItemState();
}

class _RecordingListItemState extends ConsumerState<RecordingListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recording;
    final notifier = ref.read(recordingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context, l10n),
      onDismissed: (_) => notifier.deleteRecording(r.id),
      child: GlassCard(
        glowActive: r.isActive,
        onTap: () {
          setState(() => _expanded = !_expanded);
          HapticFeedback.selectionClick();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: r.isActive ? AppColors.activeGreen : AppColors.stoppedRed,
                    boxShadow: r.isActive
                        ? [
                            BoxShadow(
                              color: AppColors.activeGreen.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                ),
                const SizedBox(width: 10),
                // Name and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.fileName,
                        style: TextStyle(color: textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      IntervalDisplay(intervalSeconds: r.intervalSeconds),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Controls
                _ActionButtons(
                  recording: r,
                  onToggle: () {
                    notifier.toggleActive(r.id);
                    HapticFeedback.mediumImpact();
                  },
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditRecordingScreen(recording: r),
                    ),
                  ),
                  onDelete: () async {
                    final confirmed = await _confirmDelete(context, l10n);
                    if (confirmed == true) notifier.deleteRecording(r.id);
                  },
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              WaveformWidget(
                isAnimating: r.isActive,
                height: 40,
                color: r.isActive ? AppColors.saffronPrimary : textSecondary,
              ).animate().fadeIn().slideY(begin: -0.3),
            ],
          ],
        ),
      ),
    )
        .animate(delay: (widget.index * 60).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.deleteMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.stoppedRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final RecordingModel recording;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.recording,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(
          recording.isActive ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
          recording.isActive ? AppColors.stoppedRed : AppColors.activeGreen,
          onToggle,
        ),
        _iconBtn(Icons.edit_rounded, AppColors.goldDark, onEdit),
        _iconBtn(Icons.delete_outline_rounded, AppColors.stoppedRed, onDelete),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.stoppedRed,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
    );
  }
}
