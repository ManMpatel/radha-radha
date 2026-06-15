import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/recording_model.dart';
import '../../providers/recordings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import 'widgets/interval_picker_widget.dart';
import 'widgets/record_tab.dart';
import 'widgets/upload_tab.dart';
import 'package:radharadha/generated/app_localizations.dart';

class AddRecordingScreen extends ConsumerStatefulWidget {
  const AddRecordingScreen({super.key});

  @override
  ConsumerState<AddRecordingScreen> createState() => _AddRecordingScreenState();
}

class _AddRecordingScreenState extends ConsumerState<AddRecordingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  int _intervalSeconds = AppConstants.defaultIntervalSeconds;
  String? _audioPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _intervalSeconds = StorageService.getDefaultInterval();
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
      final recording = RecordingModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        filePath: _audioPath!,
        fileName: fileName,
        intervalSeconds: _intervalSeconds,
        isActive: false,
        createdAt: DateTime.now(),
      );
      await ref.read(recordingsProvider.notifier).addRecording(recording);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.goldDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                ),
              ],
            ),
          ),
          _BottomSection(
            nameController: _nameController,
            intervalSeconds: _intervalSeconds,
            onIntervalChanged: (v) => setState(() => _intervalSeconds = v),
            canSave: _canSave,
            isSaving: _isSaving,
            onSave: () => _save(context),
            l10n: l10n,
            isDark: isDark,
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
                l10n.addRecording,
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
          Tab(
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            text: l10n.uploadFile,
          ),
          Tab(
            icon: const Icon(Icons.mic_rounded, size: 20),
            text: l10n.recordNow,
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final TextEditingController nameController;
  final int intervalSeconds;
  final ValueChanged<int> onIntervalChanged;
  final bool canSave;
  final bool isSaving;
  final VoidCallback onSave;
  final AppLocalizations l10n;
  final bool isDark;

  const _BottomSection({
    required this.nameController,
    required this.intervalSeconds,
    required this.onIntervalChanged,
    required this.canSave,
    required this.isSaving,
    required this.onSave,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 0,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.recordingName,
              prefixIcon: const Icon(Icons.label_rounded, color: AppColors.goldPrimary),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          IntervalPickerWidget(
            initialSeconds: intervalSeconds,
            onChanged: onIntervalChanged,
          ),
          const SizedBox(height: 20),
          isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.saffronPrimary))
              : GradientButton(
                  label: l10n.save,
                  icon: Icons.save_rounded,
                  onPressed: canSave ? onSave : null,
                ),
        ],
      ),
    );
  }
}
