import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../data/sources/local/image_file_service.dart';

/// Currently open folder path.
final currentFolderProvider = StateProvider<String?>((ref) => null);

/// Gallery state — async list of images in the current folder.
final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, List<ImageFile>>(GalleryNotifier.new);

class GalleryNotifier extends AsyncNotifier<List<ImageFile>> {
  @override
  Future<List<ImageFile>> build() async => [];

  /// Load all supported images from [folderPath].
  Future<void> loadFolder(String folderPath) async {
    state = const AsyncLoading();
    ref.read(currentFolderProvider.notifier).state = folderPath;
    // Save as last-used folder
    await ref.read(settingsServiceProvider).setLastFolder(folderPath);
    state = await AsyncValue.guard(
      () => ref.read(imageFileServiceProvider).listImages(folderPath),
    );
  }

  /// Refresh current folder (after file changes).
  Future<void> refresh() async {
    final folder = ref.read(currentFolderProvider);
    if (folder != null) await loadFolder(folder);
  }
}
