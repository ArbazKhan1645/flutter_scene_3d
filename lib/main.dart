import 'package:flutterscene_3d/src/app/app.dart';
import 'package:flutterscene_3d/src/core/common/bootstrap.dart';

/// The entry point of the application.
///
/// This file is responsible for initializing the app through the bootstrap
/// layer and launching the root [FlutterSceneApp] widget.
void main() async {
  // Launch the app using the centralized bootstrap configuration.
  // This handles provider initialization, global error handling, and more.
  await bootstrap(() => const FlutterSceneApp());
}
