import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/local/image_file_service.dart';
import '../../data/sources/local/settings_service.dart';
import '../../data/cache/image_cache_manager.dart';

/// Isar database singleton provider (lazy / optional until Phase 3 schema).
final isarProvider = Provider<dynamic>((ref) => null);

/// Image file service — browses folders and lists images.
final imageFileServiceProvider = Provider<ImageFileService>((ref) {
  return ImageFileService();
});

/// App-wide image cache.
final imageCacheManagerProvider = Provider<ImageCacheManager>((ref) {
  return ImageCacheManager();
});

/// Settings service backed by SharedPreferences.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Bootstrap all providers that need async init.
Future<ProviderContainer> createProviderContainer() async {
  return ProviderContainer();
}
