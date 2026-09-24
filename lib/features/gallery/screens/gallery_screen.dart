import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../data/sources/local/image_file_service.dart';
import '../providers/gallery_provider.dart';
import '../widgets/image_thumbnail.dart';

/// Gallery screen — folder browser + thumbnail grid.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(galleryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, colorScheme, textTheme),
      body: galleryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(message: err.toString()),
        data: (images) => images.isEmpty
            ? _EmptyState(onPickFolder: _pickFolder)
            : _ThumbnailGrid(images: images),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final folderPath = ref.watch(currentFolderProvider);

    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppConstants.appName, style: textTheme.titleLarge),
          if (folderPath != null)
            Text(
              folderPath,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        // Open folder
        IconButton(
          icon: const Icon(Icons.folder_open_outlined),
          tooltip: 'Open Folder',
          onPressed: _pickFolder,
        ),
        // Open single file
        IconButton(
          icon: const Icon(Icons.image_outlined),
          tooltip: 'Open Image',
          onPressed: _pickFile,
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _pickFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Image Folder',
    );
    if (folder != null && mounted) {
      ref.read(galleryProvider.notifier).loadFolder(folder);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: SupportedFormats.pickerExtensions,
      dialogTitle: 'Open Image',
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      final path = result.files.first.path!;
      final folder = ref.read(imageFileServiceProvider).folderOf(path);
      // Load the folder so we can navigate prev/next
      final images = await ref.read(imageFileServiceProvider).listImages(folder);
      final index = images.indexWhere((f) => f.path == path);
      if (!mounted) return;
      context.push('/viewer', extra: {
        'filePath': path,
        'fileList': images.map((f) => f.path).toList(),
        'index': index < 0 ? 0 : index,
      });
    }
  }
}

class _ThumbnailGrid extends ConsumerWidget {
  const _ThumbnailGrid({required this.images});
  final List<ImageFile> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppConstants.thumbnailSize + 16,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final img = images[index];
        return ImageThumbnail(
          imageFile: img,
          onTap: () => context.push('/viewer', extra: {
            'filePath': img.path,
            'fileList': images.map((f) => f.path).toList(),
            'index': index,
          }),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPickFolder});
  final VoidCallback onPickFolder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          Text('No images yet', style: textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            'Open a folder to browse your images',
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onPickFolder,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Open Folder'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Error loading images',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
