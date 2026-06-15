import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/duration_formatter.dart';
import 'package:radharadha/generated/app_localizations.dart';

class IntervalPickerWidget extends StatefulWidget {
  final int initialSeconds;
  final ValueChanged<int> onChanged;

  const IntervalPickerWidget({
    super.key,
    required this.initialSeconds,
    required this.onChanged,
  });

  @override
  State<IntervalPickerWidget> createState() => _IntervalPickerWidgetState();
}

class _IntervalPickerWidgetState extends State<IntervalPickerWidget> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  late FixedExtentScrollController _hCtrl;
  late FixedExtentScrollController _mCtrl;
  late FixedExtentScrollController _sCtrl;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialSeconds ~/ 3600;
    _minutes = (widget.initialSeconds % 3600) ~/ 60;
    _seconds = widget.initialSeconds % 60;
    _hCtrl = FixedExtentScrollController(initialItem: _hours);
    _mCtrl = FixedExtentScrollController(initialItem: _minutes);
    _sCtrl = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _mCtrl.dispose();
    _sCtrl.dispose();
    super.dispose();
  }

  int get _totalSeconds => _hours * 3600 + _minutes * 60 + _seconds;

  void _notify() {
    final total = _totalSeconds;
    if (total >= AppConstants.minIntervalSeconds) {
      widget.onChanged(total);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer_rounded, color: AppColors.goldPrimary, size: 18),
            const SizedBox(width: 6),
            Text(
              l10n.playEvery,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                DurationFormatter.format(_totalSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SpinnerColumn(
              controller: _hCtrl,
              count: 24,
              label: l10n.hours,
              textColor: textColor,
              labelColor: labelColor,
              onChanged: (v) {
                setState(() => _hours = v);
                _notify();
              },
            ),
            _Colon(color: textColor),
            _SpinnerColumn(
              controller: _mCtrl,
              count: 60,
              label: l10n.minutes,
              textColor: textColor,
              labelColor: labelColor,
              onChanged: (v) {
                setState(() => _minutes = v);
                _notify();
              },
            ),
            _Colon(color: textColor),
            _SpinnerColumn(
              controller: _sCtrl,
              count: 60,
              label: l10n.seconds,
              textColor: textColor,
              labelColor: labelColor,
              onChanged: (v) {
                setState(() => _seconds = v);
                _notify();
              },
            ),
          ],
        ),
        if (_totalSeconds < AppConstants.minIntervalSeconds)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.minIntervalNote,
              style: const TextStyle(
                color: AppColors.stoppedRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _SpinnerColumn extends StatefulWidget {
  final FixedExtentScrollController controller;
  final int count;
  final String label;
  final Color textColor;
  final Color labelColor;
  final ValueChanged<int> onChanged;

  const _SpinnerColumn({
    required this.controller,
    required this.count,
    required this.label,
    required this.textColor,
    required this.labelColor,
    required this.onChanged,
  });

  @override
  State<_SpinnerColumn> createState() => _SpinnerColumnState();
}

class _SpinnerColumnState extends State<_SpinnerColumn> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.controller.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListWheelScrollView.useDelegate(
              controller: widget.controller,
              itemExtent: 36,
              perspective: 0.004,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (v) {
                setState(() => _selected = v);
                widget.onChanged(v);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.count,
                builder: (context, index) {
                  final isSelected = _selected == index;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.saffronPrimary
                            : widget.textColor.withOpacity(0.5),
                        fontSize: isSelected ? 22 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            widget.label,
            style: TextStyle(color: widget.labelColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  final Color color;
  const _Colon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
