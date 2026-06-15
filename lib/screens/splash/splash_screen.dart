import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/recordings_provider.dart';
import '../../services/audio_playback_service.dart';
import '../../services/background_task_service.dart';
import '../../services/phone_call_service.dart';
import '../home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _rayController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await AudioPlaybackService.init();
    await BackgroundTaskService.init();
    PhoneCallService.init();

    // Wire phone call service to background task
    PhoneCallService.addCallStartListener(() {
      BackgroundTaskService.notifyCallStarted();
    });
    PhoneCallService.addCallEndListener(() {
      BackgroundTaskService.notifyCallEnded();
    });

    // Restore any previously active timers
    ref.read(recordingsProvider.notifier).restoreActiveTimers();

    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _rayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.saffronPrimary, AppColors.goldPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Sacred geometry background pattern
            _SacredPattern(rotateController: _rotateController),
            // Light rays
            _LightRays(rayController: _rayController),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lotus icon
                  _LotusAnimation(rotateController: _rotateController),
                  const SizedBox(height: 32),
                  // Devanagari title
                  const Text(
                    'राधा राधा',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  const Text(
                    'Radha Radha',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.8),
                      strokeWidth: 2,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotusAnimation extends StatelessWidget {
  final AnimationController rotateController;
  const _LotusAnimation({required this.rotateController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotateController,
      builder: (_, __) {
        return Transform.scale(
          scale: 1.0 + 0.05 * sin(rotateController.value * 2 * pi),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('🪷', style: TextStyle(fontSize: 60)),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1));
  }
}

class _SacredPattern extends StatelessWidget {
  final AnimationController rotateController;
  const _SacredPattern({required this.rotateController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: rotateController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(size.width, size.height),
          painter: _SacredPatternPainter(rotateController.value),
        );
      },
    );
  }
}

class _SacredPatternPainter extends CustomPainter {
  final double progress;
  _SacredPatternPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final rotation = progress * 2 * pi;

    for (int i = 0; i < 6; i++) {
      final angle = rotation + (i * pi / 3);
      final r = size.width * 0.35;
      final cx = center.dx + r * cos(angle);
      final cy = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
    canvas.drawCircle(center, size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(_SacredPatternPainter old) => old.progress != progress;
}

class _LightRays extends StatelessWidget {
  final AnimationController rayController;
  const _LightRays({required this.rayController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: rayController,
      builder: (_, __) {
        return CustomPaint(
          size: Size(size.width, size.height),
          painter: _LightRaysPainter(rayController.value),
        );
      },
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  final double progress;
  _LightRaysPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = 0.03 + 0.03 * progress;
    final paint = Paint()..color = Colors.white.withOpacity(opacity);

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6);
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + size.width * cos(angle - 0.05),
        center.dy + size.width * sin(angle - 0.05),
      );
      path.lineTo(
        center.dx + size.width * cos(angle + 0.05),
        center.dy + size.width * sin(angle + 0.05),
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightRaysPainter old) => old.progress != progress;
}
