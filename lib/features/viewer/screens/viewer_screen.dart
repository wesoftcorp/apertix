import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/viewer_provider.dart';
import '../widgets/viewer_toolbar.dart';
import '../widgets/thumbnail_strip.dart';
import 'package:go_router/go_router.dart';
import '../../metadata/widgets/metadata_drawer.dart';

/// Full-screen image viewer with zoom, pan, and navigation.
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({
    super.key,
    required this.filePath,
    required this.fileList,
    required this.initialIndex,
  });

  final String filePath;
  final List<String> fileList;
  final int initialIndex;

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  bool _showUi = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewerProvider.notifier).init(
            filePaths: widget.fileList,
            initialIndex: widget.initialIndex,
          );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUi() => setState(() => _showUi = !_showUi);

  void _navigate(int delta) {
    final notifier = ref.read(viewerProvider.notifier);
    final newIndex = notifier.navigate(delta);
    if (newIndex != null) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ApertixColors.darkBackground,
        endDrawer: state.valueOrNull?.currentPath != null
            ? MetadataDrawer(filePath: state.valueOrNull!.currentPath!)
            : null,
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(err.toString(),
                style: const TextStyle(color: Colors.white)),
          ),
          data: (viewerState) => Stack(
            children: [
              // Main image gallery
              GestureDetector(
                onTap: _toggleUi,
                child: PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: viewerState.filePaths.length,
                  onPageChanged: (index) {
                    ref.read(viewerProvider.notifier).setIndex(index);
                  },
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          FileImage(File(viewerState.filePaths[index])),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * AppConstants.maxZoom,
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: viewerState.filePaths[index],
                      ),
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 72,
                            color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: ApertixColors.darkBackground,
                  ),
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(
                      value: event?.expectedTotalBytes != null
                          ? event!.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                          : null,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // Top toolbar (auto-hides)
              AnimatedSlide(
                offset: _showUi ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ViewerToolbar(
                  viewerState: viewerState,
                  onNavigatePrev: () => _navigate(-1),
                  onNavigateNext: () => _navigate(1),
                  onToggleFullscreen: _toggleFullscreen,
                  isFullscreen: _isFullscreen,
                  onOpenMetadata: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ),

              // Thumbnail strip at bottom (auto-hides)
              if (viewerState.filePaths.length > 1)
                AnimatedSlide(
                  offset: _showUi ? Offset.zero : const Offset(0, 1),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ThumbnailStrip(
                      paths: viewerState.filePaths,
                      currentIndex: viewerState.currentIndex,
                      onTap: (index) {
                        ref.read(viewerProvider.notifier).setIndex(index);
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),

              // Left/Right nav arrows
              if (_showUi) ...[
                _NavArrow(
                  alignment: Alignment.centerLeft,
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _navigate(-1),
                  enabled: viewerState.currentIndex > 0,
                ),
                _NavArrow(
                  alignment: Alignment.centerRight,
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _navigate(1),
                  enabled: viewerState.currentIndex < viewerState.filePaths.length - 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowUp:
        _navigate(-1);
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowDown:
        _navigate(1);
      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();
      case LogicalKeyboardKey.f11:
        _toggleFullscreen();
      case LogicalKeyboardKey.keyF:
        _toggleFullscreen();
      case LogicalKeyboardKey.keyI:
        _scaffoldKey.currentState?.openEndDrawer();
      case LogicalKeyboardKey.keyE:
        final current = ref.read(viewerProvider).valueOrNull?.currentPath;
        if (current != null) {
          context.push('/editor', extra: {'filePath': current});
        }
    }
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _isFullscreen = !_isFullscreen);
    // window_manager fullscreen handled by ViewerToolbar button
  }
}

/// Left/Right navigation arrow overlay.
class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.alignment,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final Alignment alignment;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.2,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(40),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
