import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_metadata.dart';
import '../services/metadata_service.dart';

/// FutureProvider family that loads and caches metadata for an image path.
final imageMetadataProvider =
    FutureProvider.autoDispose.family<ImageMetadata, String>((ref, path) async {
  return MetadataService.extractMetadata(path);
});
