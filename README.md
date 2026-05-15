# 🏎️ FlutterScene 3D - Professional Model Viewer

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=riverpod&logoColor=white)](https://riverpod.dev)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)

`flutter` `3d-model-viewer` `riverpod` `glb` `gltf` `ar` `augmented-reality` `flutter-3d` `model-viewer` `clean-architecture` `dart` `3d-customizer` `open-source`

**FlutterScene 3D** is a professional-grade 3D model viewer and customizer built with Flutter and Riverpod.

---

## ✨ Key Features

- 🛠️ **Real-time Customization**: Modify materials, colors, metalness, and roughness on the fly.
- 💡 **Advanced Lighting**: Toggle between different environment presets and adjust exposure.
- 🌑 **Shadow Control**: Fine-tune ground shadows for better realism.
- 🎥 **Animation Support**: Play, pause, and switch between model animations.
- 📸 **Studio Tools**: Capture high-quality screenshots and export customized models.
- 📂 **Flexible Loading**: Load pre-installed models or pick custom ones from your device.
- 📱 **Cross-Platform**: Designed for a smooth experience across Mobile, Web, and Desktop.

## 🏗️ Architecture & Stack

This project follows **Clean Architecture** principles with a feature-first modular structure:

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev) with Code Generation
- **3D Engine**: Google's [Model-Viewer](https://modelviewer.dev) via `model_viewer_plus`
- **UI Design**: Modern Neumorphic and Glassmorphic elements
- **Persistence**: File storage for custom models and screenshots

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ArbazKhan1645/flutter_scene_3d.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Launch the app:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── main.dart
└── src/
    ├── core/               # Shared logic, theme, and common widgets
    └── features/
        ├── selection/      # Model selection feature
        └── viewer/         # 3D viewing & editing feature
            ├── models/     # Freezed state models
            ├── providers/  # Riverpod providers
            └── views/      # Screens and panels
```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

## 👤 Author

**Arbaz Mashwani**
- GitHub: [@ArbazKhan1645](https://github.com/ArbazKhan1645)

---
*If you like this project, please give it a ⭐ to show your support!*
