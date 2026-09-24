import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight settings service backed by SharedPreferences.
class SettingsService {
  static const _kLastFolder = 'last_folder';
  static const _kShowThumbnailStrip = 'show_thumbnail_strip';
  static const _kSlideshowInterval = 'slideshow_interval_sec';
  static const _kZoomMode = 'zoom_mode';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getLastFolder() async =>
      (await _prefs).getString(_kLastFolder);

  Future<void> setLastFolder(String path) async =>
      (await _prefs).setString(_kLastFolder, path);

  Future<bool> getShowThumbnailStrip() async =>
      (await _prefs).getBool(_kShowThumbnailStrip) ?? true;

  Future<void> setShowThumbnailStrip(bool value) async =>
      (await _prefs).setBool(_kShowThumbnailStrip, value);

  Future<int> getSlideshowInterval() async =>
      (await _prefs).getInt(_kSlideshowInterval) ?? 3;

  Future<void> setSlideshowInterval(int seconds) async =>
      (await _prefs).setInt(_kSlideshowInterval, seconds);

  Future<String> getZoomMode() async =>
      (await _prefs).getString(_kZoomMode) ?? 'fit';

  Future<void> setZoomMode(String mode) async =>
      (await _prefs).setString(_kZoomMode, mode);
}
