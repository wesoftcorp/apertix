import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/app_constants.dart';

/// LRU image cache — keeps up to [AppConstants.cacheMaxImages] decoded images.
class ImageCacheManager {
  final _cache = <String, Uint8List>{};
  final int maxSize;

  ImageCacheManager({this.maxSize = AppConstants.cacheMaxImages});

  /// Returns cached bytes for [path], or null if not cached.
  Uint8List? get(String path) {
    final value = _cache[path];
    if (value != null) {
      // Move to end (most recently used)
      _cache.remove(path);
      _cache[path] = value;
    }
    return value;
  }

  /// Stores [bytes] for [path], evicting LRU entry if at capacity.
  void put(String path, Uint8List bytes) {
    if (_cache.containsKey(path)) {
      _cache.remove(path);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[path] = bytes;
  }

  /// Reads file bytes, using cache if available.
  Future<Uint8List?> loadBytes(String path) async {
    final cached = get(path);
    if (cached != null) return cached;
    try {
      final bytes = await File(path).readAsBytes();
      put(path, bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Preloads a list of [paths] into the cache in the background.
  void preload(List<String> paths) {
    for (final path in paths) {
      if (!_cache.containsKey(path)) {
        loadBytes(path); // fire-and-forget
      }
    }
  }

  void clear() => _cache.clear();
  int get size => _cache.length;
}
