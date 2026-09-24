# 🔮 Apertix

> **A fast, open-core, cross-platform image viewer & editor with built-in social publishing.**  
> Inspired by ImageGlass. Built with Flutter. Designed to be free, beautiful, and powerful.

[![License: MIT](https://img.shields.io/badge/License-MIT-violet.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-green.svg)](https://github.com/wesoftcorp/apertix)

---

## ✨ Features

### Free Core (MIT)
- **80+ image formats** — JPEG, PNG, WebP, AVIF, JXL, HEIC, SVG, PSD, RAW (CR2, NEF, ARW…) and more
- **Smooth viewer** — Hardware-accelerated rendering, zoom 10–3200%, smooth pan, fit modes
- **Folder gallery** — Thumbnail grid, folder browser, recent files
- **Essential editing** — Crop, Resize, Rotate, Flip, Brightness/Contrast/Saturation, Sharpen, Blur
- **Tools** — Color Picker, EXIF viewer, Histogram
- **Animation support** — GIF/WebP/APNG playback with frame controls
- **Slideshow** — Auto-advance with transitions
- **Themes** — Dark, Light, System + Material You on Android
- **Keyboard-first** — Every action has a shortcut

### 💎 Pro
- AI image upscaling (Real-ESRGAN, on-device)
- Background removal (on-device ONNX)
- Batch processing (resize, rename, convert, watermark)
- Advanced filters & annotations
- **Social Hub** — Publish directly to 8 platforms in-app:
  - 🔵 Facebook · 📸 Instagram · 🦋 Bluesky · 🐘 Mastodon
  - ✈️ Telegram · 📌 Pinterest · 💼 LinkedIn · 📝 Tumblr

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.44+
- Dart 3.12+
- Windows 10+  or  Android 8+

### Run
```bash
git clone https://github.com/wesoftcorp/apertix.git
cd apertix
flutter pub get
flutter run -d windows
```

---

## 🏗 Architecture

Clean Architecture with Flutter + Riverpod + Isar:

```
lib/
├── core/           # Constants, theme, router, DI
├── data/           # Models, repositories, services, cache
├── domain/         # Entities, use cases, repository interfaces
├── features/       # viewer, editor, gallery, slideshow, social_hub, settings
└── widgets/        # Shared reusable widgets
```

---

## 📅 Roadmap

| Phase | Status |
|---|---|
| Phase 1 — Core Viewer | 🚧 In Progress |
| Phase 2 — Essential Editing | ⏳ Planned |
| Phase 3 — Gallery & Animation | ⏳ Planned |
| Phase 4 — Platform Polish | ⏳ Planned |
| Phase 5 — Pro Features | ⏳ Planned |
| Phase 6 — Social Hub | ⏳ Planned |

---

## 📄 License

Core: [MIT License](LICENSE)  
Pro features: Commercial license (see [LICENSE-PRO](LICENSE-PRO))

---

*Made with ❤️ using Flutter*
