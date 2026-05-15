import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'viewer_state.freezed.dart';

@freezed
abstract class ViewerState with _$ViewerState {
  const factory ViewerState({
    @Default(Colors.transparent) Color selectedColor,
    @Default(0.5) double metalness,
    @Default(0.5) double roughness,
    @Default(true) bool autoRotate,
    @Default(false) bool isModelLoaded,
    @Default(true) bool isLoading,
    @Default(0.0) double loadingProgress,
    @Default('') String uploadedTexturePath,
    @Default(false) bool hasCustomTexture,
    @Default('color') String activeTab,
    @Default(false) bool isPanelExpanded,
    @Default('assets/models/Motorcycle.glb') String selectedModelPath,
    @Default(true) bool isAssetModel,
    @Default(['assets/models/Motorcycle.glb']) List<String> assetModels,
    @Default(['All Materials']) List<String> modelMaterials,
    @Default('All Materials') String selectedMaterial,
    @Default([]) List<Map<String, dynamic>> modelTextures,
    @Default(true) bool shadowEnabled,
    @Default(1.0) double shadowIntensity,
    @Default(1.0) double shadowSoftness,
    @Default(1.0) double exposure,
    @Default('neutral') String environmentPreset,
    @Default('') String customEnvUrl,
    @Default('neutral') String toneMapper,
    @Default(45.0) double fieldOfView,
    @Default(0.0) double cameraOrbitTheta,
    @Default(75.0) double cameraOrbitPhi,
    @Default(105.0) double cameraOrbitRadius,
    @Default(50.0) double interpolationDecay,
    @Default(false) bool limitOrbit,
    @Default([]) List<String> modelAnimations,
    @Default('') String selectedAnimation,
    @Default(false) bool isAnimationPlaying,
    @Default([]) List<Map<String, dynamic>> hotspots,
  }) = _ViewerState;
}
