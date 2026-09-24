import 'package:flutter/foundation.dart';

/// Structured EXIF & Image Metadata representation.
@immutable
class ImageMetadata {
  const ImageMetadata({
    required this.filePath,
    required this.fileSizeBytes,
    required this.lastModified,
    this.dimensions,
    this.cameraMake,
    this.cameraModel,
    this.lensModel,
    this.focalLength,
    this.aperture,
    this.shutterSpeed,
    this.iso,
    this.dateTaken,
    this.gpsLatitude,
    this.gpsLongitude,
    this.gpsAltitude,
    this.software,
    this.colorSpace,
    this.rawTags = const {},
  });

  final String filePath;
  final int fileSizeBytes;
  final DateTime lastModified;
  final String? dimensions;
  final String? cameraMake;
  final String? cameraModel;
  final String? lensModel;
  final String? focalLength;
  final String? aperture;
  final String? shutterSpeed;
  final String? iso;
  final String? dateTaken;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final double? gpsAltitude;
  final String? software;
  final String? colorSpace;
  final Map<String, String> rawTags;

  bool get hasGps => gpsLatitude != null && gpsLongitude != null;
  bool get hasCameraInfo => cameraMake != null || cameraModel != null || lensModel != null;
  bool get hasExposureInfo => aperture != null || shutterSpeed != null || iso != null;

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
