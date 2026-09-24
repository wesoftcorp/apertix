import 'package:flutter/material.dart';
import '../models/editor_state.dart';

/// Draggable and resizable crop bounding box overlay with aspect ratio constraints.
class CropOverlay extends StatefulWidget {
  const CropOverlay({
    super.key,
    required this.imageSize,
    required this.selectedRatio,
    required this.onCropChanged,
    this.initialCrop,
  });

  final Size imageSize;
  final CropAspectRatio selectedRatio;
  final ValueChanged<Rect?> onCropChanged;
  final Rect? initialCrop;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  late Rect _crop; // in normalized coords [0, 0, 1, 1]

  @override
  void initState() {
    super.initState();
    _crop = widget.initialCrop ?? const Rect.fromLTWH(0.05, 0.05, 0.9, 0.9);
  }

  @override
  void didUpdateWidget(covariant CropOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRatio != widget.selectedRatio) {
      _applyAspectRatio(widget.selectedRatio);
    }
  }

  void _applyAspectRatio(CropAspectRatio ratio) {
    if (ratio.ratio == null) return;
    final targetRatio = ratio.ratio!;
    final imageAspect = widget.imageSize.width / widget.imageSize.height;

    double newW = _crop.width;
    double newH = newW / targetRatio * imageAspect;

    if (newH > 1.0) {
      newH = 1.0;
      newW = newH * targetRatio / imageAspect;
    }

    final newL = ((1.0 - newW) / 2).clamp(0.0, 1.0 - newW);
    final newT = ((1.0 - newH) / 2).clamp(0.0, 1.0 - newH);

    setState(() {
      _crop = Rect.fromLTWH(newL, newT, newW, newH);
    });
    widget.onCropChanged(_crop);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final pixelRect = Rect.fromLTWH(
          _crop.left * w,
          _crop.top * h,
          _crop.width * w,
          _crop.height * h,
        );

        return Stack(
          children: [
            // Darkened scrim outside crop
            CustomPaint(
              size: Size(w, h),
              painter: _ScrimPainter(cropRect: pixelRect),
            ),

            // Draggable box
            Positioned(
              left: pixelRect.left,
              top: pixelRect.top,
              width: pixelRect.width,
              height: pixelRect.height,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final dx = details.delta.dx / w;
                  final dy = details.delta.dy / h;
                  setState(() {
                    final nextL = (_crop.left + dx).clamp(0.0, 1.0 - _crop.width);
                    final nextT = (_crop.top + dy).clamp(0.0, 1.0 - _crop.height);
                    _crop = Rect.fromLTWH(nextL, nextT, _crop.width, _crop.height);
                  });
                  widget.onCropChanged(_crop);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      // Rule-of-thirds grid lines
                      CustomPaint(
                        size: Size(pixelRect.width, pixelRect.height),
                        painter: _ThirdsGridPainter(),
                      ),
                      // Corner handles
                      _buildCornerHandle(Alignment.topLeft),
                      _buildCornerHandle(Alignment.topRight),
                      _buildCornerHandle(Alignment.bottomLeft),
                      _buildCornerHandle(Alignment.bottomRight),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerHandle(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black45, width: 1.5),
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({required this.cropRect});
  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScrimPainter oldDelegate) => oldDelegate.cropRect != cropRect;
}

class _ThirdsGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    final wThird = size.width / 3;
    final hThird = size.height / 3;

    canvas.drawLine(Offset(wThird, 0), Offset(wThird, size.height), paint);
    canvas.drawLine(Offset(wThird * 2, 0), Offset(wThird * 2, size.height), paint);
    canvas.drawLine(Offset(0, hThird), Offset(size.width, hThird), paint);
    canvas.drawLine(Offset(0, hThird * 2), Offset(size.width, hThird * 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
