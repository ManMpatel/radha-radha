import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/duration_formatter.dart';

class IntervalDisplay extends StatelessWidget {
  final int intervalSeconds;
  final TextStyle? textStyle;

  const IntervalDisplay({
    super.key,
    required this.intervalSeconds,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 14,
          color: AppColors.goldPrimary,
        ),
        const SizedBox(width: 4),
        Text(
          'Every ${DurationFormatter.format(intervalSeconds)}',
          style: textStyle ??
              TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
