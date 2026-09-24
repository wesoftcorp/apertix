import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import '../models/editor_state.dart';

/// Request parameters sent to the background isolate.
class ImageProcessingTask {
  const ImageProcessingTask({
    required this.inputPath,
    required this.outputPath,
    required this.params,
    this.targetWidth,
    this.targetHeight,
    this.quality = 90,
  });

  final String inputPath;
  final String outputPath;
  final EditorParameters params;
  final int? targetWidth;
  final int? targetHeight;
  final int quality;
}

/// Headless image processing engine using the `image` package in a background isolate.
class ImageProcessorService {
  /// Executes the full non-destructive edit pipeline on the original file
  /// and writes the output file without blocking the UI thread.
  static Future<String> processAndSave(ImageProcessingTask task) async {
    return compute(_executeTask, task);
  }

  static String _executeTask(ImageProcessingTask task) {
    final bytes = File(task.inputPath).readAsBytesSync();
    var image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image at ${task.inputPath}');
    }

    // 1. Orient according to EXIF if available
    image = img.bakeOrientation(image);

    // 2. Crop
    if (task.params.cropRect != null) {
      final rect = task.params.cropRect!;
      final x = (rect.left * image.width).round().clamp(0, image.width - 1);
      final y = (rect.top * image.height).round().clamp(0, image.height - 1);
      final w = (rect.width * image.width).round().clamp(1, image.width - x);
      final h = (rect.height * image.height).round().clamp(1, image.height - y);
      image = img.copyCrop(image, x: x, y: y, width: w, height: h);
    }

    // 3. Rotation (Quarter turns: 0, 90, 180, 270)
    final turns = task.params.rotationQuarterTurns % 4;
    if (turns != 0) {
      image = img.copyRotate(image, angle: turns * 90);
    }

    // 4. Flips
    if (task.params.flipHorizontal) {
      image = img.copyFlip(image, direction: img.FlipDirection.horizontal);
    }
    if (task.params.flipVertical) {
      image = img.copyFlip(image, direction: img.FlipDirection.vertical);
    }

    // 5. Resize (optional)
    if (task.targetWidth != null || task.targetHeight != null) {
      image = img.copyResize(
        image,
        width: task.targetWidth,
        height: task.targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // 6. Color Adjustments: Brightness & Contrast
    final totalBrightness = (task.params.brightness + task.params.exposure).clamp(-1.0, 1.0);
    if (totalBrightness != 0.0) {
      image = img.adjustColor(image, brightness: 1.0 + totalBrightness);
    }
    if (task.params.contrast != 0.0) {
      image = img.adjustColor(image, contrast: 1.0 + task.params.contrast);
    }
    if (task.params.saturation != 0.0) {
      image = img.adjustColor(image, saturation: 1.0 + task.params.saturation);
    }

    // 7. Filter Presets
    switch (task.params.preset) {
      case FilterPreset.bw:
        image = img.grayscale(image);
        break;
      case FilterPreset.vintage:
        image = img.sepia(image, amount: 0.7);
        break;
      case FilterPreset.vivid:
        image = img.adjustColor(image, saturation: 1.3, contrast: 1.1);
        break;
      case FilterPreset.cyberpunk:
        image = img.adjustColor(image, saturation: 1.4, contrast: 1.25);
        break;
      case FilterPreset.cinematic:
        image = img.adjustColor(image, saturation: 1.1, contrast: 1.15);
        break;
      case FilterPreset.none:
        break;
    }

    // 8. Encode & Save according to output extension
    final ext = p.extension(task.outputPath).toLowerCase().replaceFirst('.', '');
    List<int> encodedBytes;
    switch (ext) {
      case 'png':
        encodedBytes = img.encodePng(image);
        break;
      case 'webp':
        encodedBytes = img.encodePng(image); // Fallback standard format
        break;
      case 'bmp':
        encodedBytes = img.encodeBmp(image);
        break;
      case 'gif':
        encodedBytes = img.encodeGif(image);
        break;
      case 'jpg':
      case 'jpeg':
      default:
        encodedBytes = img.encodeJpg(image, quality: task.quality);
        break;
    }

    File(task.outputPath).writeAsBytesSync(encodedBytes);
    return task.outputPath;
  }
}
