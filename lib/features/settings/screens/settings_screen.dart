import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Settings screen — theme, behaviour, cache, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          const _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            leading: const Icon(Icons.palette_outlined),
            title: 'Theme',
            subtitle: switch (themeMode) {
              ThemeMode.dark => 'Dark',
              ThemeMode.light => 'Light',
              ThemeMode.system => 'System',
            },
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined, size: 16),
                    label: Text('Dark')),
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined, size: 16),
                    label: Text('Light')),
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.auto_mode_outlined, size: 16),
                    label: Text('System')),
              ],
              selected: {themeMode},
              onSelectionChanged: (modes) {
                ref.read(themeModeProvider.notifier).setMode(modes.first);
              },
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About section
          const _SectionHeader(title: 'About'),
          const _SettingsTile(
            leading: Icon(Icons.info_outline_rounded),
            title: AppConstants.appName,
            subtitle:
                'Version ${AppConstants.appVersion} • Open-core image viewer & editor',
          ),
          _SettingsTile(
            leading: const Icon(Icons.code_rounded),
            title: 'Source Code',
            subtitle: 'github.com/wesoftcorp/apertix',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        leading: leading,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        trailing: trailing,
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
