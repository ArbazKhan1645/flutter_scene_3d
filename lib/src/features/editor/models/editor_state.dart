/// Immutable state class for the 3-D Scene Editor.
/// Written without Freezed to avoid code-generation dependencies.
library;

import 'scene_object.dart';

// ── EditorState ───────────────────────────────────────────────────────────────

class EditorState {
  const EditorState({
    this.sceneObjects     = const [],
    this.sceneLights      = const [],
    this.selectedObjectId,
    this.selectedObject,
    this.transformMode    = 'translate',
    this.cameraType       = 'perspective',
    this.isGridVisible    = true,
    this.isAxesVisible    = true,
    this.isSnapEnabled    = false,
    this.isEditorReady    = false,
    this.isLoading        = false,
    this.isImporting      = false,
    this.activePanel      = 'hierarchy',
    this.savedSceneJson,
    this.statusMessage,
    this.assetModels      = const [],
    this.bgColor          = '#16162a',
    this.shadowsEnabled   = true,
    this.loadProgress     = 0,
  });

  /// All objects currently in the Three.js scene.
  final List<SceneObjectMeta> sceneObjects;

  /// All lights in the scene.
  final List<SceneLightMeta>  sceneLights;

  /// The id of the currently selected object (null if nothing selected).
  final String?               selectedObjectId;

  /// Full metadata of the selected object (cached for panels).
  final SceneObjectMeta?      selectedObject;

  /// Current TransformControls mode: 'translate' | 'rotate' | 'scale'
  final String                transformMode;

  /// Active camera type: 'perspective' | 'orthographic'
  final String                cameraType;

  final bool isGridVisible;
  final bool isAxesVisible;
  final bool isSnapEnabled;

  /// True once the WebView editor.js has finished initialising.
  final bool isEditorReady;

  /// Generic loading/busy indicator.
  final bool isLoading;

  /// True while a file-picker import is in progress.
  final bool isImporting;

  /// Which side-panel to show in the Flutter UI: 'hierarchy' | 'properties' | 'assets' | 'lights'
  final String activePanel;

  /// Last saved scene JSON (kept so the user can re-save without re-exporting).
  final String? savedSceneJson;

  /// Short status text shown in the toolbar (e.g. "Scene saved ✓").
  final String? statusMessage;

  /// GLB model paths discovered in assets/models/.
  final List<String> assetModels;

  /// Scene background hex color.
  final String bgColor;

  /// Whether shadow-casting is enabled.
  final bool shadowsEnabled;

  /// URL-load progress 0–100 (shown in asset browser).
  final int loadProgress;

  // ── copyWith ─────────────────────────────────────────────────────────────────
  EditorState copyWith({
    List<SceneObjectMeta>? sceneObjects,
    List<SceneLightMeta>?  sceneLights,
    String?                selectedObjectId,
    SceneObjectMeta?       selectedObject,
    bool                   clearSelected = false,
    String?                transformMode,
    String?                cameraType,
    bool?                  isGridVisible,
    bool?                  isAxesVisible,
    bool?                  isSnapEnabled,
    bool?                  isEditorReady,
    bool?                  isLoading,
    bool?                  isImporting,
    String?                activePanel,
    String?                savedSceneJson,
    String?                statusMessage,
    bool                   clearStatus = false,
    List<String>?          assetModels,
    String?                bgColor,
    bool?                  shadowsEnabled,
    int?                   loadProgress,
  }) {
    return EditorState(
      sceneObjects    : sceneObjects     ?? this.sceneObjects,
      sceneLights     : sceneLights      ?? this.sceneLights,
      selectedObjectId: clearSelected ? null : (selectedObjectId ?? this.selectedObjectId),
      selectedObject  : clearSelected ? null : (selectedObject   ?? this.selectedObject),
      transformMode   : transformMode    ?? this.transformMode,
      cameraType      : cameraType       ?? this.cameraType,
      isGridVisible   : isGridVisible    ?? this.isGridVisible,
      isAxesVisible   : isAxesVisible    ?? this.isAxesVisible,
      isSnapEnabled   : isSnapEnabled    ?? this.isSnapEnabled,
      isEditorReady   : isEditorReady    ?? this.isEditorReady,
      isLoading       : isLoading        ?? this.isLoading,
      isImporting     : isImporting      ?? this.isImporting,
      activePanel     : activePanel      ?? this.activePanel,
      savedSceneJson  : savedSceneJson   ?? this.savedSceneJson,
      statusMessage   : clearStatus ? null : (statusMessage ?? this.statusMessage),
      assetModels     : assetModels      ?? this.assetModels,
      bgColor         : bgColor          ?? this.bgColor,
      shadowsEnabled  : shadowsEnabled   ?? this.shadowsEnabled,
      loadProgress    : loadProgress     ?? this.loadProgress,
    );
  }
}
