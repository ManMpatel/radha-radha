import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class WaveformWidget extends StatefulWidget {
  final bool isAnimating;
  final double height;
  final Color? color;
  final int barCount;

  const WaveformWidget({
    super.key,
    required this.isAnimating,
    this.height = 40,
    this.color,
    this.barCount = 20,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(WaveformWidget old) {
    super.didUpdateWidget(old);
    if (widget.isAnimating && !old.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && old.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.saffronPrimary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WaveformPainter(
            progress: _controller.value,
            color: color,
            barCount: widget.barCount,
            isAnimating: widget.isAnimating,
          ),
          size: Size(double.infinity, widget.height),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int barCount;
  final bool isAnimating;
  final Random _rng = Random(42);

  _WaveformPainter({
    required this.progress,
    required this.color,
    required this.barCount,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / barCount * 0.55;

    final barWidth = size.width / barCount;
    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      double barHeight;
      if (isAnimating) {
        final phase = (i / barCount + progress) * 2 * pi;
        barHeight = size.height * (0.3 + 0.6 * ((sin(phase) + 1) / 2));
      } else {
        // Static waveform appearance
        final seed = _rng.nextDouble();
        barHeight = size.height * (0.2 + seed * 0.6);
      }
      final top = (size.height - barHeight) / 2;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + barHeight),
        paint..color = color.withOpacity(isAnimating ? 0.8 : 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.isAnimating != isAnimating;
}
