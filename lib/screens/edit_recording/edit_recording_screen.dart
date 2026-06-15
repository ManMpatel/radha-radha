import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/recording_model.dart';
import '../../providers/recordings_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../add_recording/widgets/interval_picker_widget.dart';
import '../add_recording/widgets/record_tab.dart';
import '../add_recording/widgets/upload_tab.dart';
import 'package:radharadha/generated/app_localizations.dart';

class EditRecordingScreen extends ConsumerStatefulWidget {
  final RecordingModel recording;

  const EditRecordingScreen({super.key, required this.recording});

  @override
  ConsumerState<EditRecordingScreen> createState() => _EditRecordingScreenState();
}

class _EditRecordingScreenState extends ConsumerState<EditRecordingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late int _intervalSeconds;
  late String? _audioPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.recording.name);
    _intervalSeconds = widget.recording.intervalSeconds;
    _audioPath = widget.recording.filePath;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _audioPath != null &&
      _nameController.text.trim().isNotEmpty &&
      _intervalSeconds >= AppConstants.minIntervalSeconds;

  Future<void> _save(BuildContext context) async {
    if (!_canSave) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final fileName = _audioPath!.split('/').last;
      final updated = widget.recording.copyWith(
        name: _nameController.text.trim(),
        filePath: _audioPath,
        fileName: fileName,
        intervalSeconds: _intervalSeconds,
      );
      await ref.read(recordingsProvider.notifier).updateRecording(updated);
      if (context.mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true && context.mounted) {
      await ref.read(recordingsProvider.notifier).deleteRecording(widget.recording.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          _Header(l10n: l10n),
          _TabBar(controller: _tabController, l10n: l10n),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UploadTab(
                  onFileSelected: (path) => setState(() => _audioPath = path),
                  selectedPath: _audioPath,
                ),
                RecordTab(
                  onRecordingComplete: (path) => setState(() => _audioPath = path),
                  existingPath: _audioPath,
                ),
              ],
            ),
          ),
          GlassCard(
            borderRadius: 0,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.recordingName,
                    prefixIcon: const Icon(Icons.label_rounded, color: AppColors.goldPrimary),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                IntervalPickerWidget(
                  initialSeconds: _intervalSeconds,
                  onChanged: (v) => setState(() => _intervalSeconds = v),
                ),
                const SizedBox(height: 20),
                _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.saffronPrimary))
                    : GradientButton(
                        label: l10n.save,
                        icon: Icons.save_rounded,
                        onPressed: _canSave ? () => _save(context) : null,
                      ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.stoppedRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  const _Header({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.saffronGoldGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
              Text(
                l10n.editRecording,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  final AppLocalizations l10n;
  const _TabBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFF6B35),
      child: TabBar(
        controller: controller,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        tabs: [
          Tab(icon: const Icon(Icons.upload_file_rounded, size: 20), text: l10n.replaceAudio),
          Tab(icon: const Icon(Icons.mic_rounded, size: 20), text: l10n.reRecordAudio),
        ],
      ),
    );
  }
}
