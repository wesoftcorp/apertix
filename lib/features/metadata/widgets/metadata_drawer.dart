import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/image_metadata.dart';
import '../providers/metadata_provider.dart';
import '../services/metadata_service.dart';

/// Slide-over metadata inspector drawer displaying EXIF, camera, GPS, and raw tags.
class MetadataDrawer extends ConsumerWidget {
  const MetadataDrawer({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataAsync = ref.watch(imageMetadataProvider(filePath));

    return Drawer(
      width: 360,
      backgroundColor: const Color(0xFF1E1E2C),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Image Info & EXIF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Content
            Expanded(
              child: metadataAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to read EXIF: $err', style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
                data: (meta) => _buildMetadataList(context, ref, meta),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataList(BuildContext context, WidgetRef ref, ImageMetadata meta) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // File Overview
        _buildSectionHeader('File Properties'),
        _buildMetaTile('Name', p.basename(meta.filePath)),
        _buildMetaTile('Size', meta.formattedFileSize),
        if (meta.dimensions != null) _buildMetaTile('Dimensions', meta.dimensions!),
        _buildMetaTile('Modified', meta.lastModified.toString().split('.')[0]),
        const SizedBox(height: 16),

        // Camera Details
        if (meta.hasCameraInfo) ...[
          _buildSectionHeader('Camera & Equipment'),
          if (meta.cameraMake != null) _buildMetaTile('Make', meta.cameraMake!),
          if (meta.cameraModel != null) _buildMetaTile('Model', meta.cameraModel!),
          if (meta.lensModel != null) _buildMetaTile('Lens', meta.lensModel!),
          if (meta.software != null) _buildMetaTile('Software', meta.software!),
          const SizedBox(height: 16),
        ],

        // Exposure Details
        if (meta.hasExposureInfo) ...[
          _buildSectionHeader('Exposure Settings'),
          if (meta.aperture != null) _buildMetaTile('Aperture', 'f/${meta.aperture}'),
          if (meta.shutterSpeed != null) _buildMetaTile('Shutter Speed', '${meta.shutterSpeed}s'),
          if (meta.iso != null) _buildMetaTile('ISO', meta.iso!),
          if (meta.focalLength != null) _buildMetaTile('Focal Length', '${meta.focalLength} mm'),
          if (meta.dateTaken != null) _buildMetaTile('Date Taken', meta.dateTaken!),
          const SizedBox(height: 16),
        ],

        // Location / GPS
        if (meta.hasGps) ...[
          _buildSectionHeader('GPS Location'),
          _buildMetaTile('Coordinates', '${meta.gpsLatitude!.toStringAsFixed(6)}, ${meta.gpsLongitude!.toStringAsFixed(6)}'),
          if (meta.gpsAltitude != null) _buildMetaTile('Altitude', '${meta.gpsAltitude!.toStringAsFixed(1)} m'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.shield_outlined, size: 16),
            label: const Text('Strip GPS & Privacy Tags'),
            onPressed: () => _stripMetadata(context, ref),
          ),
          const SizedBox(height: 16),
        ],

        // Raw EXIF Tags
        if (meta.rawTags.isNotEmpty) ...[
          _buildSectionHeader('All EXIF Tags (${meta.rawTags.length})'),
          ...meta.rawTags.entries.take(30).map((e) => _buildMetaTile(e.key, e.value)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6C5CE7),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMetaTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _stripMetadata(BuildContext context, WidgetRef ref) async {
    try {
      await MetadataService.stripExif(filePath);
      ref.invalidate(imageMetadataProvider(filePath));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EXIF & GPS metadata stripped successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to strip metadata: $e')),
      );
    }
  }
}
