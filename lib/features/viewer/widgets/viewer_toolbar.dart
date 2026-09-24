import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';
import '../providers/viewer_provider.dart';

/// Top toolbar overlay for the viewer screen.
class ViewerToolbar extends StatelessWidget {
  const ViewerToolbar({
    super.key,
    required this.viewerState,
    required this.onNavigatePrev,
    required this.onNavigateNext,
    required this.onToggleFullscreen,
    required this.isFullscreen,
    this.onOpenMetadata,
  });

  final ViewerState viewerState;
  final VoidCallback onNavigatePrev;
  final VoidCallback onNavigateNext;
  final VoidCallback onToggleFullscreen;
  final bool isFullscreen;
  final VoidCallback? onOpenMetadata;

  @override
  Widget build(BuildContext context) {
    final fileName = viewerState.currentPath != null
        ? p.basename(viewerState.currentPath!)
        : '';
    final count = viewerState.filePaths.length;
    final index = viewerState.currentIndex + 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            _ToolbarButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back to Gallery',
              onTap: () => context.pop(),
            ),
            const SizedBox(width: 8),

            // File name + counter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (count > 0)
                    Text(
                      '$index of $count',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Navigation
            _ToolbarButton(
              icon: Icons.chevron_left_rounded,
              tooltip: 'Previous (←)',
              onTap: onNavigatePrev,
            ),
            _ToolbarButton(
              icon: Icons.chevron_right_rounded,
              tooltip: 'Next (→)',
              onTap: onNavigateNext,
            ),
            const SizedBox(width: 8),

            // Edit button
            _ToolbarButton(
              icon: Icons.tune_rounded,
              tooltip: 'Edit Image (E)',
              onTap: () {
                final current = viewerState.currentPath;
                if (current != null) {
                  context.push('/editor', extra: {'filePath': current});
                }
              },
            ),
            const SizedBox(width: 8),

            // Info / EXIF button
            if (onOpenMetadata != null) ...[
              _ToolbarButton(
                icon: Icons.info_outline_rounded,
                tooltip: 'Image Info & EXIF (I)',
                onTap: onOpenMetadata!,
              ),
              const SizedBox(width: 8),
            ],

            // Fullscreen toggle
            _ToolbarButton(
              icon: isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              tooltip: isFullscreen ? 'Exit Fullscreen (F11)' : 'Fullscreen (F11)',
              onTap: () async {
                onToggleFullscreen();
                final isFs = await windowManager.isFullScreen();
                await windowManager.setFullScreen(!isFs);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
