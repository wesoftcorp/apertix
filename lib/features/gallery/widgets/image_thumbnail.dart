import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/sources/local/image_file_service.dart';

/// Single thumbnail tile in the gallery grid.
class ImageThumbnail extends StatelessWidget {
  const ImageThumbnail({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  final ImageFile imageFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline, width: 1),
          color: colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              cacheWidth: 320,
              cacheHeight: 320,
            ),
            // Hover overlay
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                hoverColor: colorScheme.primary.withValues(alpha: 0.08),
                splashColor: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            // File name label at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Text(
                  imageFile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
