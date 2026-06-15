import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/recording_model.dart';
import '../../providers/recordings_provider.dart';
import '../../widgets/sidebar_drawer.dart';
import '../add_recording/add_recording_screen.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/global_controls_bar.dart';
import 'widgets/recording_list_item.dart';
import 'package:radharadha/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(recordingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          // Gradient app bar background
          Container(
            height: MediaQuery.of(context).padding.top + 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.saffronGoldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _AppBar(l10n: l10n),
                const GlobalControlsBar(),
                Expanded(
                  child: recordings.isEmpty
                      ? EmptyStateWidget(
                          onAddTap: () => _openAddRecording(context),
                        )
                      : _RecordingsList(recordings: recordings),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: recordings.isNotEmpty ? _FAB(onTap: () => _openAddRecording(context)) : null,
    );
  }

  void _openAddRecording(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const AddRecordingScreen(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final AppLocalizations l10n;
  const _AppBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(ctx).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 4),
          const Text('🪷', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingsList extends StatelessWidget {
  final List<RecordingModel> recordings;
  const _RecordingsList({required this.recordings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: recordings.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RecordingListItem(
          recording: recordings[index],
          index: index,
        ),
      ),
    );
  }
}

class _FAB extends StatefulWidget {
  final VoidCallback onTap;
  const _FAB({required this.onTap});

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.saffronPrimary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Add Recording',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          delay: 200.ms,
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}
