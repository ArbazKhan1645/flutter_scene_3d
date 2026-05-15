# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-05-15

### Added
- Initial professional release.
- Riverpod state management implementation (Generator + Notifier).
- Feature-first modular architecture (`lib/src/features`).
- 3D Model viewing with material customization (Color, Metalness, Roughness).
- Augmented Reality (AR) support on compatible devices.
- Screenshot and model export capabilities.
- Custom texture upload support with background isolate processing.
- Professional UI theme using Google Fonts (Outfit).
- MIT License and GitHub repository standards (Issue/PR templates).
- Security policy and contributing guidelines.
- Automated app icon management with `flutter_launcher_icons`.
- Premium 3D-styled application icon.
- Native splash screen integration using `flutter_native_splash`.
- Predictive back and native platform-aware page transitions.

### Changed
- Migrated from GetX to Riverpod for better scalability and testability.
- Refactored codebase to clean architecture standards.
- Renamed project from `model_viewer` to **FlutterScene 3D**.
- Updated bundle ID to `com.arbaz.flutterscene` across all platforms.
- Moved root application logic from `main.dart` to `src/app/app.dart`.
- Optimized Android build configuration (minSdk 24) for AR compatibility.
- Enhanced iOS metadata with required permission descriptions.
- Upgraded project to Flutter 3.27 standards (using `.withValues()` and `.r/g/b`).
- Optimized app startup with font pre-caching and bootstrap initialization.

### Fixed
- All lint issues (30+) resolved for "No issues found" status.
- Deprecated `share_plus` API migrated to `SharePlus.instance.share`.
- Deprecated `Color` and `Theme` properties updated to latest SDK standards.

### Optimized
- **Android**: Enabled R8/ProGuard shrinking, obfuscation, and log-stripping for security.
- **Android**: Configured ABI splits (ARM/x86) for significantly reduced APK sizes.
- **Rendering**: Implemented `RepaintBoundary` for efficient grid rendering.
- **Build**: Parallel execution and caching enabled in Gradle.
