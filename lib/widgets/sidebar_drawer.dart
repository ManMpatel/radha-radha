import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../screens/settings/settings_screen.dart';
import 'package:radharadha/generated/app_localizations.dart';

class SidebarDrawer extends ConsumerWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isHindi = ref.watch(languageProvider).languageCode == 'hi';
    final l10n = AppLocalizations.of(context);
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Drawer(
      backgroundColor: Colors.transparent,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.drawerGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DrawerHeader(today: today, l10n: l10n),
              const SizedBox(height: 8),
              _divider(),
              const SizedBox(height: 8),
              _DrawerItem(
                icon: Icons.home_rounded,
                label: l10n.home,
                onTap: () => Navigator.pop(context),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: l10n.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2),
              const SizedBox(height: 8),
              _divider(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Preferences',
                  style: TextStyle(
                    color: AppColors.goldPrimary.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              _ToggleRow(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                label: isDark ? l10n.darkMode : l10n.lightMode,
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2),
              _ToggleRow(
                icon: Icons.language_rounded,
                label: isHindi ? 'हिंदी' : 'English',
                value: isHindi,
                onChanged: (_) => ref.read(languageProvider.notifier).toggle(),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
              const Spacer(),
              _divider(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'v${AppConstants.appVersion}  •  ${AppConstants.developerName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white.withOpacity(0.1),
      );
}

class _DrawerHeader extends StatelessWidget {
  final String today;
  final AppLocalizations l10n;

  const _DrawerHeader({required this.today, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.saffronPrimary.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('🪷', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            today,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldPrimary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white.withOpacity(0.05),
      splashColor: AppColors.saffronPrimary.withOpacity(0.1),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.goldPrimary,
            trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? AppColors.goldPrimary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
