import 'dart:io';
import 'package:flutter/material.dart';

/// Horizontal filmstrip at the bottom of the viewer for quick navigation.
class ThumbnailStrip extends StatefulWidget {
  const ThumbnailStrip({
    super.key,
    required this.paths,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> paths;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<ThumbnailStrip> createState() => _ThumbnailStripState();
}

class _ThumbnailStripState extends State<ThumbnailStrip> {
  late final ScrollController _scroll;
  static const _thumbSize = 72.0;
  static const _borderRadius = 6.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
  }

  @override
  void didUpdateWidget(ThumbnailStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToCurrentIndex();
    }
  }

  void _scrollToCurrentIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        final offset = (widget.currentIndex * (_thumbSize + 6)) -
            (_scroll.position.viewportDimension / 2 - _thumbSize / 2);
        _scroll.animateTo(
          offset.clamp(0.0, _scroll.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: _thumbSize + 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: widget.paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final isSelected = index == widget.currentIndex;
          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(widget.paths[index]),
                fit: BoxFit.cover,
                cacheWidth: 144,
                cacheHeight: 144,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white30,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
