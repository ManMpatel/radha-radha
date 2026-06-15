import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/gradient_button.dart';
import 'package:radharadha/generated/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddTap;

  const EmptyStateWidget({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FloatingLotus()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -8, end: 8, duration: 2000.ms, curve: Curves.easeInOut),
            const SizedBox(height: 32),
            Text(
              l10n.noRecordingsYet,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              l10n.addFirstRecording,
              style: TextStyle(color: subColor, fontSize: 15),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            GradientButton(
              label: l10n.addRecording,
              icon: Icons.add_rounded,
              onPressed: onAddTap,
              width: 220,
            ).animate().fadeIn(delay: 400.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                ),
          ],
        ),
      ),
    );
  }
}

class _FloatingLotus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronPrimary.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Text('🪷', style: TextStyle(fontSize: 56)),
      ),
    );
  }
}
