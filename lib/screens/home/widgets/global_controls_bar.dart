import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/recordings_provider.dart';
import '../../../widgets/gradient_button.dart';
import 'package:radharadha/generated/app_localizations.dart';

class GlobalControlsBar extends ConsumerWidget {
  const GlobalControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingsProvider);
    final notifier = ref.read(recordingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCount = recordings.where((r) => r.isActive).length;
    final total = recordings.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.8)
            : AppColors.lightSurface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              label: l10n.startAll,
              icon: Icons.play_arrow_rounded,
              onPressed: total == 0 ? null : () => notifier.startAll(),
              height: 42,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GradientButton(
              label: l10n.stopAll,
              icon: Icons.stop_rounded,
              gradient: const [AppColors.goldDark, AppColors.goldPrimary],
              onPressed: activeCount == 0 ? null : () => notifier.stopAll(),
              height: 42,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 10),
          _CountBadge(active: activeCount, total: total),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int active;
  final int total;

  const _CountBadge({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: active > 0 ? AppColors.primaryGradient : null,
        color: active == 0
            ? (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCard
                : AppColors.lightCard)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$active',
            style: TextStyle(
              color: active > 0 ? Colors.white : AppColors.lightTextSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            'active',
            style: TextStyle(
              color: active > 0 ? Colors.white70 : AppColors.lightTextSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
