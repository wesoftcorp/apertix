import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/sources/local/image_file_service.dart';
import '../../data/sources/local/settings_service.dart';
import '../../data/cache/image_cache_manager.dart';

/// Isar database singleton provider.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Override with opened Isar instance at startup.');
});

/// Image file service — browses folders and lists images.
final imageFileServiceProvider = Provider<ImageFileService>((ref) {
  return ImageFileService();
});

/// App-wide image cache.
final imageCacheManagerProvider = Provider<ImageCacheManager>((ref) {
  return ImageCacheManager();
});

/// Settings service backed by Isar.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Bootstrap all providers that need async init (Isar, etc.).
Future<ProviderContainer> createProviderContainer() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [], // schemas added incrementally per phase
    directory: dir.path,
    name: 'apertix',
  );

  return ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
    ],
  );
}
