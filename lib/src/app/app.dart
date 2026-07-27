import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterscene_3d/src/core/theme/app_theme.dart';
import 'package:flutterscene_3d/src/features/editor/views/scene_editor_screen.dart';
import 'package:flutterscene_3d/src/features/selection/views/model_selection_screen.dart';
import 'package:flutterscene_3d/src/features/viewer/views/view_model_screen.dart';

/// The root widget of the application.
/// Separated from main.dart to follow professional clean architecture standards.
class FlutterSceneApp extends ConsumerWidget {
  const FlutterSceneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FlutterScene 3D',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const ModelSelectionScreen(),
            );
          case '/viewer':
            return MaterialPageRoute(
              builder: (_) => const ModelViewerScreen(),
            );
          case '/editor':
            return MaterialPageRoute(
              builder: (_) => const SceneEditorScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const ModelSelectionScreen(),
            );
        }
      },
    );
  }
}
