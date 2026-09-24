import 'package:flutter/material.dart';

class ExportOptions {
  const ExportOptions({
    required this.quality,
    required this.overwrite,
    this.customWidth,
    this.customHeight,
  });

  final int quality;
  final bool overwrite;
  final int? customWidth;
  final int? customHeight;
}

/// Dialog for choosing export quality, dimensions, and overwrite option.
class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    required this.originalWidth,
    required this.originalHeight,
  });

  final int originalWidth;
  final int originalHeight;

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  int _quality = 90;
  bool _overwrite = false;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  bool _lockAspect = true;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: widget.originalWidth.toString());
    _heightController = TextEditingController(text: widget.originalHeight.toString());
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _onWidthChanged(String val) {
    if (!_lockAspect) return;
    final w = int.tryParse(val);
    if (w != null && widget.originalWidth > 0) {
      final h = (w * widget.originalHeight / widget.originalWidth).round();
      _heightController.text = h.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Image'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quality slider
            Text('Quality: $_quality%', style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _quality.toDouble(),
              min: 10,
              max: 100,
              divisions: 18,
              label: '$_quality%',
              onChanged: (v) => setState(() => _quality = v.round()),
            ),
            const SizedBox(height: 12),

            // Dimensions
            const Text('Dimensions (px)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onWidthChanged,
                  ),
                ),
                IconButton(
                  icon: Icon(_lockAspect ? Icons.lock_rounded : Icons.lock_open_rounded),
                  tooltip: _lockAspect ? 'Aspect Ratio Locked' : 'Aspect Ratio Unlocked',
                  onPressed: () => setState(() => _lockAspect = !_lockAspect),
                ),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Overwrite Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Overwrite original file'),
              subtitle: const Text('Save directly or create a copy'),
              value: _overwrite,
              onChanged: (v) => setState(() => _overwrite = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final w = int.tryParse(_widthController.text);
            final h = int.tryParse(_heightController.text);
            Navigator.of(context).pop(
              ExportOptions(
                quality: _quality,
                overwrite: _overwrite,
                customWidth: (w != widget.originalWidth) ? w : null,
                customHeight: (h != widget.originalHeight) ? h : null,
              ),
            );
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
