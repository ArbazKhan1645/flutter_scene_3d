import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterscene_3d/src/core/theme/app_theme.dart';
import 'package:flutterscene_3d/src/features/editor/views/scene_editor_screen.dart';
import 'package:flutterscene_3d/src/features/selection/views/model_selection_screen.dart';
import 'package:flutterscene_3d/src/features/viewer/providers/viewer_provider.dart';
import 'package:flutterscene_3d/src/features/viewer/views/view_model_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The root widget of the application.
class FlutterSceneApp extends ConsumerStatefulWidget {
  const FlutterSceneApp({super.key});

  @override
  ConsumerState<FlutterSceneApp> createState() => _FlutterSceneAppState();
}

class _FlutterSceneAppState extends ConsumerState<FlutterSceneApp> {
  StreamSubscription? _intentSubscription;

  @override
  void initState() {
    super.initState();
    _initSharingIntent();
  }

  void _initSharingIntent() {
    // Listen to media sharing when app is running in background
    _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _handleSharedFiles(value);
    }, onError: (err) {
      debugPrint('[SharingIntentStream] error: $err');
    });

    // Get media sharing when app is launched from closed state
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _handleSharedFiles(value);
    }).catchError((err) {
      debugPrint('[SharingIntentInitial] error: $err');
    });
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    for (final file in files) {
      final path = file.path.toLowerCase();
      if (path.endsWith('.glb') || path.endsWith('.gltf')) {
        debugPrint('[IncomingIntent] loading file: ${file.path}');
        ref.read(viewerProvider.notifier).loadModelFromFile(file.path);
        navigatorKey.currentState?.pushNamed('/viewer');
        break;
      }
    }
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
