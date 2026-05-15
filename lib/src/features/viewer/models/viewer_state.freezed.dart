// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'viewer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewerState {

 Color get selectedColor; double get metalness; double get roughness; bool get autoRotate; bool get isModelLoaded; bool get isLoading; double get loadingProgress; String get uploadedTexturePath; bool get hasCustomTexture; String get activeTab; bool get isPanelExpanded; String get selectedModelPath; bool get isAssetModel; List<String> get assetModels; List<String> get modelMaterials; String get selectedMaterial; List<Map<String, dynamic>> get modelTextures; bool get shadowEnabled; double get shadowIntensity; double get shadowSoftness; double get exposure; String get environmentPreset; String get customEnvUrl; String get toneMapper; double get fieldOfView; double get cameraOrbitTheta; double get cameraOrbitPhi; double get cameraOrbitRadius; double get interpolationDecay; bool get limitOrbit; List<String> get modelAnimations; String get selectedAnimation; bool get isAnimationPlaying; List<Map<String, dynamic>> get hotspots;
/// Create a copy of ViewerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewerStateCopyWith<ViewerState> get copyWith => _$ViewerStateCopyWithImpl<ViewerState>(this as ViewerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewerState&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.metalness, metalness) || other.metalness == metalness)&&(identical(other.roughness, roughness) || other.roughness == roughness)&&(identical(other.autoRotate, autoRotate) || other.autoRotate == autoRotate)&&(identical(other.isModelLoaded, isModelLoaded) || other.isModelLoaded == isModelLoaded)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadingProgress, loadingProgress) || other.loadingProgress == loadingProgress)&&(identical(other.uploadedTexturePath, uploadedTexturePath) || other.uploadedTexturePath == uploadedTexturePath)&&(identical(other.hasCustomTexture, hasCustomTexture) || other.hasCustomTexture == hasCustomTexture)&&(identical(other.activeTab, activeTab) || other.activeTab == activeTab)&&(identical(other.isPanelExpanded, isPanelExpanded) || other.isPanelExpanded == isPanelExpanded)&&(identical(other.selectedModelPath, selectedModelPath) || other.selectedModelPath == selectedModelPath)&&(identical(other.isAssetModel, isAssetModel) || other.isAssetModel == isAssetModel)&&const DeepCollectionEquality().equals(other.assetModels, assetModels)&&const DeepCollectionEquality().equals(other.modelMaterials, modelMaterials)&&(identical(other.selectedMaterial, selectedMaterial) || other.selectedMaterial == selectedMaterial)&&const DeepCollectionEquality().equals(other.modelTextures, modelTextures)&&(identical(other.shadowEnabled, shadowEnabled) || other.shadowEnabled == shadowEnabled)&&(identical(other.shadowIntensity, shadowIntensity) || other.shadowIntensity == shadowIntensity)&&(identical(other.shadowSoftness, shadowSoftness) || other.shadowSoftness == shadowSoftness)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.environmentPreset, environmentPreset) || other.environmentPreset == environmentPreset)&&(identical(other.customEnvUrl, customEnvUrl) || other.customEnvUrl == customEnvUrl)&&(identical(other.toneMapper, toneMapper) || other.toneMapper == toneMapper)&&(identical(other.fieldOfView, fieldOfView) || other.fieldOfView == fieldOfView)&&(identical(other.cameraOrbitTheta, cameraOrbitTheta) || other.cameraOrbitTheta == cameraOrbitTheta)&&(identical(other.cameraOrbitPhi, cameraOrbitPhi) || other.cameraOrbitPhi == cameraOrbitPhi)&&(identical(other.cameraOrbitRadius, cameraOrbitRadius) || other.cameraOrbitRadius == cameraOrbitRadius)&&(identical(other.interpolationDecay, interpolationDecay) || other.interpolationDecay == interpolationDecay)&&(identical(other.limitOrbit, limitOrbit) || other.limitOrbit == limitOrbit)&&const DeepCollectionEquality().equals(other.modelAnimations, modelAnimations)&&(identical(other.selectedAnimation, selectedAnimation) || other.selectedAnimation == selectedAnimation)&&(identical(other.isAnimationPlaying, isAnimationPlaying) || other.isAnimationPlaying == isAnimationPlaying)&&const DeepCollectionEquality().equals(other.hotspots, hotspots));
}


@override
int get hashCode => Object.hashAll([runtimeType,selectedColor,metalness,roughness,autoRotate,isModelLoaded,isLoading,loadingProgress,uploadedTexturePath,hasCustomTexture,activeTab,isPanelExpanded,selectedModelPath,isAssetModel,const DeepCollectionEquality().hash(assetModels),const DeepCollectionEquality().hash(modelMaterials),selectedMaterial,const DeepCollectionEquality().hash(modelTextures),shadowEnabled,shadowIntensity,shadowSoftness,exposure,environmentPreset,customEnvUrl,toneMapper,fieldOfView,cameraOrbitTheta,cameraOrbitPhi,cameraOrbitRadius,interpolationDecay,limitOrbit,const DeepCollectionEquality().hash(modelAnimations),selectedAnimation,isAnimationPlaying,const DeepCollectionEquality().hash(hotspots)]);

@override
String toString() {
  return 'ViewerState(selectedColor: $selectedColor, metalness: $metalness, roughness: $roughness, autoRotate: $autoRotate, isModelLoaded: $isModelLoaded, isLoading: $isLoading, loadingProgress: $loadingProgress, uploadedTexturePath: $uploadedTexturePath, hasCustomTexture: $hasCustomTexture, activeTab: $activeTab, isPanelExpanded: $isPanelExpanded, selectedModelPath: $selectedModelPath, isAssetModel: $isAssetModel, assetModels: $assetModels, modelMaterials: $modelMaterials, selectedMaterial: $selectedMaterial, modelTextures: $modelTextures, shadowEnabled: $shadowEnabled, shadowIntensity: $shadowIntensity, shadowSoftness: $shadowSoftness, exposure: $exposure, environmentPreset: $environmentPreset, customEnvUrl: $customEnvUrl, toneMapper: $toneMapper, fieldOfView: $fieldOfView, cameraOrbitTheta: $cameraOrbitTheta, cameraOrbitPhi: $cameraOrbitPhi, cameraOrbitRadius: $cameraOrbitRadius, interpolationDecay: $interpolationDecay, limitOrbit: $limitOrbit, modelAnimations: $modelAnimations, selectedAnimation: $selectedAnimation, isAnimationPlaying: $isAnimationPlaying, hotspots: $hotspots)';
}


}

/// @nodoc
abstract mixin class $ViewerStateCopyWith<$Res>  {
  factory $ViewerStateCopyWith(ViewerState value, $Res Function(ViewerState) _then) = _$ViewerStateCopyWithImpl;
@useResult
$Res call({
 Color selectedColor, double metalness, double roughness, bool autoRotate, bool isModelLoaded, bool isLoading, double loadingProgress, String uploadedTexturePath, bool hasCustomTexture, String activeTab, bool isPanelExpanded, String selectedModelPath, bool isAssetModel, List<String> assetModels, List<String> modelMaterials, String selectedMaterial, List<Map<String, dynamic>> modelTextures, bool shadowEnabled, double shadowIntensity, double shadowSoftness, double exposure, String environmentPreset, String customEnvUrl, String toneMapper, double fieldOfView, double cameraOrbitTheta, double cameraOrbitPhi, double cameraOrbitRadius, double interpolationDecay, bool limitOrbit, List<String> modelAnimations, String selectedAnimation, bool isAnimationPlaying, List<Map<String, dynamic>> hotspots
});




}
/// @nodoc
class _$ViewerStateCopyWithImpl<$Res>
    implements $ViewerStateCopyWith<$Res> {
  _$ViewerStateCopyWithImpl(this._self, this._then);

  final ViewerState _self;
  final $Res Function(ViewerState) _then;

/// Create a copy of ViewerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedColor = null,Object? metalness = null,Object? roughness = null,Object? autoRotate = null,Object? isModelLoaded = null,Object? isLoading = null,Object? loadingProgress = null,Object? uploadedTexturePath = null,Object? hasCustomTexture = null,Object? activeTab = null,Object? isPanelExpanded = null,Object? selectedModelPath = null,Object? isAssetModel = null,Object? assetModels = null,Object? modelMaterials = null,Object? selectedMaterial = null,Object? modelTextures = null,Object? shadowEnabled = null,Object? shadowIntensity = null,Object? shadowSoftness = null,Object? exposure = null,Object? environmentPreset = null,Object? customEnvUrl = null,Object? toneMapper = null,Object? fieldOfView = null,Object? cameraOrbitTheta = null,Object? cameraOrbitPhi = null,Object? cameraOrbitRadius = null,Object? interpolationDecay = null,Object? limitOrbit = null,Object? modelAnimations = null,Object? selectedAnimation = null,Object? isAnimationPlaying = null,Object? hotspots = null,}) {
  return _then(_self.copyWith(
selectedColor: null == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as Color,metalness: null == metalness ? _self.metalness : metalness // ignore: cast_nullable_to_non_nullable
as double,roughness: null == roughness ? _self.roughness : roughness // ignore: cast_nullable_to_non_nullable
as double,autoRotate: null == autoRotate ? _self.autoRotate : autoRotate // ignore: cast_nullable_to_non_nullable
as bool,isModelLoaded: null == isModelLoaded ? _self.isModelLoaded : isModelLoaded // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadingProgress: null == loadingProgress ? _self.loadingProgress : loadingProgress // ignore: cast_nullable_to_non_nullable
as double,uploadedTexturePath: null == uploadedTexturePath ? _self.uploadedTexturePath : uploadedTexturePath // ignore: cast_nullable_to_non_nullable
as String,hasCustomTexture: null == hasCustomTexture ? _self.hasCustomTexture : hasCustomTexture // ignore: cast_nullable_to_non_nullable
as bool,activeTab: null == activeTab ? _self.activeTab : activeTab // ignore: cast_nullable_to_non_nullable
as String,isPanelExpanded: null == isPanelExpanded ? _self.isPanelExpanded : isPanelExpanded // ignore: cast_nullable_to_non_nullable
as bool,selectedModelPath: null == selectedModelPath ? _self.selectedModelPath : selectedModelPath // ignore: cast_nullable_to_non_nullable
as String,isAssetModel: null == isAssetModel ? _self.isAssetModel : isAssetModel // ignore: cast_nullable_to_non_nullable
as bool,assetModels: null == assetModels ? _self.assetModels : assetModels // ignore: cast_nullable_to_non_nullable
as List<String>,modelMaterials: null == modelMaterials ? _self.modelMaterials : modelMaterials // ignore: cast_nullable_to_non_nullable
as List<String>,selectedMaterial: null == selectedMaterial ? _self.selectedMaterial : selectedMaterial // ignore: cast_nullable_to_non_nullable
as String,modelTextures: null == modelTextures ? _self.modelTextures : modelTextures // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,shadowEnabled: null == shadowEnabled ? _self.shadowEnabled : shadowEnabled // ignore: cast_nullable_to_non_nullable
as bool,shadowIntensity: null == shadowIntensity ? _self.shadowIntensity : shadowIntensity // ignore: cast_nullable_to_non_nullable
as double,shadowSoftness: null == shadowSoftness ? _self.shadowSoftness : shadowSoftness // ignore: cast_nullable_to_non_nullable
as double,exposure: null == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as double,environmentPreset: null == environmentPreset ? _self.environmentPreset : environmentPreset // ignore: cast_nullable_to_non_nullable
as String,customEnvUrl: null == customEnvUrl ? _self.customEnvUrl : customEnvUrl // ignore: cast_nullable_to_non_nullable
as String,toneMapper: null == toneMapper ? _self.toneMapper : toneMapper // ignore: cast_nullable_to_non_nullable
as String,fieldOfView: null == fieldOfView ? _self.fieldOfView : fieldOfView // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitTheta: null == cameraOrbitTheta ? _self.cameraOrbitTheta : cameraOrbitTheta // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitPhi: null == cameraOrbitPhi ? _self.cameraOrbitPhi : cameraOrbitPhi // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitRadius: null == cameraOrbitRadius ? _self.cameraOrbitRadius : cameraOrbitRadius // ignore: cast_nullable_to_non_nullable
as double,interpolationDecay: null == interpolationDecay ? _self.interpolationDecay : interpolationDecay // ignore: cast_nullable_to_non_nullable
as double,limitOrbit: null == limitOrbit ? _self.limitOrbit : limitOrbit // ignore: cast_nullable_to_non_nullable
as bool,modelAnimations: null == modelAnimations ? _self.modelAnimations : modelAnimations // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAnimation: null == selectedAnimation ? _self.selectedAnimation : selectedAnimation // ignore: cast_nullable_to_non_nullable
as String,isAnimationPlaying: null == isAnimationPlaying ? _self.isAnimationPlaying : isAnimationPlaying // ignore: cast_nullable_to_non_nullable
as bool,hotspots: null == hotspots ? _self.hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewerState].
extension ViewerStatePatterns on ViewerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewerState value)  $default,){
final _that = this;
switch (_that) {
case _ViewerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewerState value)?  $default,){
final _that = this;
switch (_that) {
case _ViewerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Color selectedColor,  double metalness,  double roughness,  bool autoRotate,  bool isModelLoaded,  bool isLoading,  double loadingProgress,  String uploadedTexturePath,  bool hasCustomTexture,  String activeTab,  bool isPanelExpanded,  String selectedModelPath,  bool isAssetModel,  List<String> assetModels,  List<String> modelMaterials,  String selectedMaterial,  List<Map<String, dynamic>> modelTextures,  bool shadowEnabled,  double shadowIntensity,  double shadowSoftness,  double exposure,  String environmentPreset,  String customEnvUrl,  String toneMapper,  double fieldOfView,  double cameraOrbitTheta,  double cameraOrbitPhi,  double cameraOrbitRadius,  double interpolationDecay,  bool limitOrbit,  List<String> modelAnimations,  String selectedAnimation,  bool isAnimationPlaying,  List<Map<String, dynamic>> hotspots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewerState() when $default != null:
return $default(_that.selectedColor,_that.metalness,_that.roughness,_that.autoRotate,_that.isModelLoaded,_that.isLoading,_that.loadingProgress,_that.uploadedTexturePath,_that.hasCustomTexture,_that.activeTab,_that.isPanelExpanded,_that.selectedModelPath,_that.isAssetModel,_that.assetModels,_that.modelMaterials,_that.selectedMaterial,_that.modelTextures,_that.shadowEnabled,_that.shadowIntensity,_that.shadowSoftness,_that.exposure,_that.environmentPreset,_that.customEnvUrl,_that.toneMapper,_that.fieldOfView,_that.cameraOrbitTheta,_that.cameraOrbitPhi,_that.cameraOrbitRadius,_that.interpolationDecay,_that.limitOrbit,_that.modelAnimations,_that.selectedAnimation,_that.isAnimationPlaying,_that.hotspots);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Color selectedColor,  double metalness,  double roughness,  bool autoRotate,  bool isModelLoaded,  bool isLoading,  double loadingProgress,  String uploadedTexturePath,  bool hasCustomTexture,  String activeTab,  bool isPanelExpanded,  String selectedModelPath,  bool isAssetModel,  List<String> assetModels,  List<String> modelMaterials,  String selectedMaterial,  List<Map<String, dynamic>> modelTextures,  bool shadowEnabled,  double shadowIntensity,  double shadowSoftness,  double exposure,  String environmentPreset,  String customEnvUrl,  String toneMapper,  double fieldOfView,  double cameraOrbitTheta,  double cameraOrbitPhi,  double cameraOrbitRadius,  double interpolationDecay,  bool limitOrbit,  List<String> modelAnimations,  String selectedAnimation,  bool isAnimationPlaying,  List<Map<String, dynamic>> hotspots)  $default,) {final _that = this;
switch (_that) {
case _ViewerState():
return $default(_that.selectedColor,_that.metalness,_that.roughness,_that.autoRotate,_that.isModelLoaded,_that.isLoading,_that.loadingProgress,_that.uploadedTexturePath,_that.hasCustomTexture,_that.activeTab,_that.isPanelExpanded,_that.selectedModelPath,_that.isAssetModel,_that.assetModels,_that.modelMaterials,_that.selectedMaterial,_that.modelTextures,_that.shadowEnabled,_that.shadowIntensity,_that.shadowSoftness,_that.exposure,_that.environmentPreset,_that.customEnvUrl,_that.toneMapper,_that.fieldOfView,_that.cameraOrbitTheta,_that.cameraOrbitPhi,_that.cameraOrbitRadius,_that.interpolationDecay,_that.limitOrbit,_that.modelAnimations,_that.selectedAnimation,_that.isAnimationPlaying,_that.hotspots);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Color selectedColor,  double metalness,  double roughness,  bool autoRotate,  bool isModelLoaded,  bool isLoading,  double loadingProgress,  String uploadedTexturePath,  bool hasCustomTexture,  String activeTab,  bool isPanelExpanded,  String selectedModelPath,  bool isAssetModel,  List<String> assetModels,  List<String> modelMaterials,  String selectedMaterial,  List<Map<String, dynamic>> modelTextures,  bool shadowEnabled,  double shadowIntensity,  double shadowSoftness,  double exposure,  String environmentPreset,  String customEnvUrl,  String toneMapper,  double fieldOfView,  double cameraOrbitTheta,  double cameraOrbitPhi,  double cameraOrbitRadius,  double interpolationDecay,  bool limitOrbit,  List<String> modelAnimations,  String selectedAnimation,  bool isAnimationPlaying,  List<Map<String, dynamic>> hotspots)?  $default,) {final _that = this;
switch (_that) {
case _ViewerState() when $default != null:
return $default(_that.selectedColor,_that.metalness,_that.roughness,_that.autoRotate,_that.isModelLoaded,_that.isLoading,_that.loadingProgress,_that.uploadedTexturePath,_that.hasCustomTexture,_that.activeTab,_that.isPanelExpanded,_that.selectedModelPath,_that.isAssetModel,_that.assetModels,_that.modelMaterials,_that.selectedMaterial,_that.modelTextures,_that.shadowEnabled,_that.shadowIntensity,_that.shadowSoftness,_that.exposure,_that.environmentPreset,_that.customEnvUrl,_that.toneMapper,_that.fieldOfView,_that.cameraOrbitTheta,_that.cameraOrbitPhi,_that.cameraOrbitRadius,_that.interpolationDecay,_that.limitOrbit,_that.modelAnimations,_that.selectedAnimation,_that.isAnimationPlaying,_that.hotspots);case _:
  return null;

}
}

}

/// @nodoc


class _ViewerState implements ViewerState {
  const _ViewerState({this.selectedColor = Colors.transparent, this.metalness = 0.5, this.roughness = 0.5, this.autoRotate = true, this.isModelLoaded = false, this.isLoading = true, this.loadingProgress = 0.0, this.uploadedTexturePath = '', this.hasCustomTexture = false, this.activeTab = 'color', this.isPanelExpanded = false, this.selectedModelPath = 'assets/models/Motorcycle.glb', this.isAssetModel = true, final  List<String> assetModels = const ['assets/models/Motorcycle.glb'], final  List<String> modelMaterials = const ['All Materials'], this.selectedMaterial = 'All Materials', final  List<Map<String, dynamic>> modelTextures = const [], this.shadowEnabled = true, this.shadowIntensity = 1.0, this.shadowSoftness = 1.0, this.exposure = 1.0, this.environmentPreset = 'neutral', this.customEnvUrl = '', this.toneMapper = 'neutral', this.fieldOfView = 45.0, this.cameraOrbitTheta = 0.0, this.cameraOrbitPhi = 75.0, this.cameraOrbitRadius = 105.0, this.interpolationDecay = 50.0, this.limitOrbit = false, final  List<String> modelAnimations = const [], this.selectedAnimation = '', this.isAnimationPlaying = false, final  List<Map<String, dynamic>> hotspots = const []}): _assetModels = assetModels,_modelMaterials = modelMaterials,_modelTextures = modelTextures,_modelAnimations = modelAnimations,_hotspots = hotspots;
  

@override@JsonKey() final  Color selectedColor;
@override@JsonKey() final  double metalness;
@override@JsonKey() final  double roughness;
@override@JsonKey() final  bool autoRotate;
@override@JsonKey() final  bool isModelLoaded;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  double loadingProgress;
@override@JsonKey() final  String uploadedTexturePath;
@override@JsonKey() final  bool hasCustomTexture;
@override@JsonKey() final  String activeTab;
@override@JsonKey() final  bool isPanelExpanded;
@override@JsonKey() final  String selectedModelPath;
@override@JsonKey() final  bool isAssetModel;
 final  List<String> _assetModels;
@override@JsonKey() List<String> get assetModels {
  if (_assetModels is EqualUnmodifiableListView) return _assetModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetModels);
}

 final  List<String> _modelMaterials;
@override@JsonKey() List<String> get modelMaterials {
  if (_modelMaterials is EqualUnmodifiableListView) return _modelMaterials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelMaterials);
}

@override@JsonKey() final  String selectedMaterial;
 final  List<Map<String, dynamic>> _modelTextures;
@override@JsonKey() List<Map<String, dynamic>> get modelTextures {
  if (_modelTextures is EqualUnmodifiableListView) return _modelTextures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelTextures);
}

@override@JsonKey() final  bool shadowEnabled;
@override@JsonKey() final  double shadowIntensity;
@override@JsonKey() final  double shadowSoftness;
@override@JsonKey() final  double exposure;
@override@JsonKey() final  String environmentPreset;
@override@JsonKey() final  String customEnvUrl;
@override@JsonKey() final  String toneMapper;
@override@JsonKey() final  double fieldOfView;
@override@JsonKey() final  double cameraOrbitTheta;
@override@JsonKey() final  double cameraOrbitPhi;
@override@JsonKey() final  double cameraOrbitRadius;
@override@JsonKey() final  double interpolationDecay;
@override@JsonKey() final  bool limitOrbit;
 final  List<String> _modelAnimations;
@override@JsonKey() List<String> get modelAnimations {
  if (_modelAnimations is EqualUnmodifiableListView) return _modelAnimations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelAnimations);
}

@override@JsonKey() final  String selectedAnimation;
@override@JsonKey() final  bool isAnimationPlaying;
 final  List<Map<String, dynamic>> _hotspots;
@override@JsonKey() List<Map<String, dynamic>> get hotspots {
  if (_hotspots is EqualUnmodifiableListView) return _hotspots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotspots);
}


/// Create a copy of ViewerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewerStateCopyWith<_ViewerState> get copyWith => __$ViewerStateCopyWithImpl<_ViewerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewerState&&(identical(other.selectedColor, selectedColor) || other.selectedColor == selectedColor)&&(identical(other.metalness, metalness) || other.metalness == metalness)&&(identical(other.roughness, roughness) || other.roughness == roughness)&&(identical(other.autoRotate, autoRotate) || other.autoRotate == autoRotate)&&(identical(other.isModelLoaded, isModelLoaded) || other.isModelLoaded == isModelLoaded)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadingProgress, loadingProgress) || other.loadingProgress == loadingProgress)&&(identical(other.uploadedTexturePath, uploadedTexturePath) || other.uploadedTexturePath == uploadedTexturePath)&&(identical(other.hasCustomTexture, hasCustomTexture) || other.hasCustomTexture == hasCustomTexture)&&(identical(other.activeTab, activeTab) || other.activeTab == activeTab)&&(identical(other.isPanelExpanded, isPanelExpanded) || other.isPanelExpanded == isPanelExpanded)&&(identical(other.selectedModelPath, selectedModelPath) || other.selectedModelPath == selectedModelPath)&&(identical(other.isAssetModel, isAssetModel) || other.isAssetModel == isAssetModel)&&const DeepCollectionEquality().equals(other._assetModels, _assetModels)&&const DeepCollectionEquality().equals(other._modelMaterials, _modelMaterials)&&(identical(other.selectedMaterial, selectedMaterial) || other.selectedMaterial == selectedMaterial)&&const DeepCollectionEquality().equals(other._modelTextures, _modelTextures)&&(identical(other.shadowEnabled, shadowEnabled) || other.shadowEnabled == shadowEnabled)&&(identical(other.shadowIntensity, shadowIntensity) || other.shadowIntensity == shadowIntensity)&&(identical(other.shadowSoftness, shadowSoftness) || other.shadowSoftness == shadowSoftness)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.environmentPreset, environmentPreset) || other.environmentPreset == environmentPreset)&&(identical(other.customEnvUrl, customEnvUrl) || other.customEnvUrl == customEnvUrl)&&(identical(other.toneMapper, toneMapper) || other.toneMapper == toneMapper)&&(identical(other.fieldOfView, fieldOfView) || other.fieldOfView == fieldOfView)&&(identical(other.cameraOrbitTheta, cameraOrbitTheta) || other.cameraOrbitTheta == cameraOrbitTheta)&&(identical(other.cameraOrbitPhi, cameraOrbitPhi) || other.cameraOrbitPhi == cameraOrbitPhi)&&(identical(other.cameraOrbitRadius, cameraOrbitRadius) || other.cameraOrbitRadius == cameraOrbitRadius)&&(identical(other.interpolationDecay, interpolationDecay) || other.interpolationDecay == interpolationDecay)&&(identical(other.limitOrbit, limitOrbit) || other.limitOrbit == limitOrbit)&&const DeepCollectionEquality().equals(other._modelAnimations, _modelAnimations)&&(identical(other.selectedAnimation, selectedAnimation) || other.selectedAnimation == selectedAnimation)&&(identical(other.isAnimationPlaying, isAnimationPlaying) || other.isAnimationPlaying == isAnimationPlaying)&&const DeepCollectionEquality().equals(other._hotspots, _hotspots));
}


@override
int get hashCode => Object.hashAll([runtimeType,selectedColor,metalness,roughness,autoRotate,isModelLoaded,isLoading,loadingProgress,uploadedTexturePath,hasCustomTexture,activeTab,isPanelExpanded,selectedModelPath,isAssetModel,const DeepCollectionEquality().hash(_assetModels),const DeepCollectionEquality().hash(_modelMaterials),selectedMaterial,const DeepCollectionEquality().hash(_modelTextures),shadowEnabled,shadowIntensity,shadowSoftness,exposure,environmentPreset,customEnvUrl,toneMapper,fieldOfView,cameraOrbitTheta,cameraOrbitPhi,cameraOrbitRadius,interpolationDecay,limitOrbit,const DeepCollectionEquality().hash(_modelAnimations),selectedAnimation,isAnimationPlaying,const DeepCollectionEquality().hash(_hotspots)]);

@override
String toString() {
  return 'ViewerState(selectedColor: $selectedColor, metalness: $metalness, roughness: $roughness, autoRotate: $autoRotate, isModelLoaded: $isModelLoaded, isLoading: $isLoading, loadingProgress: $loadingProgress, uploadedTexturePath: $uploadedTexturePath, hasCustomTexture: $hasCustomTexture, activeTab: $activeTab, isPanelExpanded: $isPanelExpanded, selectedModelPath: $selectedModelPath, isAssetModel: $isAssetModel, assetModels: $assetModels, modelMaterials: $modelMaterials, selectedMaterial: $selectedMaterial, modelTextures: $modelTextures, shadowEnabled: $shadowEnabled, shadowIntensity: $shadowIntensity, shadowSoftness: $shadowSoftness, exposure: $exposure, environmentPreset: $environmentPreset, customEnvUrl: $customEnvUrl, toneMapper: $toneMapper, fieldOfView: $fieldOfView, cameraOrbitTheta: $cameraOrbitTheta, cameraOrbitPhi: $cameraOrbitPhi, cameraOrbitRadius: $cameraOrbitRadius, interpolationDecay: $interpolationDecay, limitOrbit: $limitOrbit, modelAnimations: $modelAnimations, selectedAnimation: $selectedAnimation, isAnimationPlaying: $isAnimationPlaying, hotspots: $hotspots)';
}


}

/// @nodoc
abstract mixin class _$ViewerStateCopyWith<$Res> implements $ViewerStateCopyWith<$Res> {
  factory _$ViewerStateCopyWith(_ViewerState value, $Res Function(_ViewerState) _then) = __$ViewerStateCopyWithImpl;
@override @useResult
$Res call({
 Color selectedColor, double metalness, double roughness, bool autoRotate, bool isModelLoaded, bool isLoading, double loadingProgress, String uploadedTexturePath, bool hasCustomTexture, String activeTab, bool isPanelExpanded, String selectedModelPath, bool isAssetModel, List<String> assetModels, List<String> modelMaterials, String selectedMaterial, List<Map<String, dynamic>> modelTextures, bool shadowEnabled, double shadowIntensity, double shadowSoftness, double exposure, String environmentPreset, String customEnvUrl, String toneMapper, double fieldOfView, double cameraOrbitTheta, double cameraOrbitPhi, double cameraOrbitRadius, double interpolationDecay, bool limitOrbit, List<String> modelAnimations, String selectedAnimation, bool isAnimationPlaying, List<Map<String, dynamic>> hotspots
});




}
/// @nodoc
class __$ViewerStateCopyWithImpl<$Res>
    implements _$ViewerStateCopyWith<$Res> {
  __$ViewerStateCopyWithImpl(this._self, this._then);

  final _ViewerState _self;
  final $Res Function(_ViewerState) _then;

/// Create a copy of ViewerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedColor = null,Object? metalness = null,Object? roughness = null,Object? autoRotate = null,Object? isModelLoaded = null,Object? isLoading = null,Object? loadingProgress = null,Object? uploadedTexturePath = null,Object? hasCustomTexture = null,Object? activeTab = null,Object? isPanelExpanded = null,Object? selectedModelPath = null,Object? isAssetModel = null,Object? assetModels = null,Object? modelMaterials = null,Object? selectedMaterial = null,Object? modelTextures = null,Object? shadowEnabled = null,Object? shadowIntensity = null,Object? shadowSoftness = null,Object? exposure = null,Object? environmentPreset = null,Object? customEnvUrl = null,Object? toneMapper = null,Object? fieldOfView = null,Object? cameraOrbitTheta = null,Object? cameraOrbitPhi = null,Object? cameraOrbitRadius = null,Object? interpolationDecay = null,Object? limitOrbit = null,Object? modelAnimations = null,Object? selectedAnimation = null,Object? isAnimationPlaying = null,Object? hotspots = null,}) {
  return _then(_ViewerState(
selectedColor: null == selectedColor ? _self.selectedColor : selectedColor // ignore: cast_nullable_to_non_nullable
as Color,metalness: null == metalness ? _self.metalness : metalness // ignore: cast_nullable_to_non_nullable
as double,roughness: null == roughness ? _self.roughness : roughness // ignore: cast_nullable_to_non_nullable
as double,autoRotate: null == autoRotate ? _self.autoRotate : autoRotate // ignore: cast_nullable_to_non_nullable
as bool,isModelLoaded: null == isModelLoaded ? _self.isModelLoaded : isModelLoaded // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadingProgress: null == loadingProgress ? _self.loadingProgress : loadingProgress // ignore: cast_nullable_to_non_nullable
as double,uploadedTexturePath: null == uploadedTexturePath ? _self.uploadedTexturePath : uploadedTexturePath // ignore: cast_nullable_to_non_nullable
as String,hasCustomTexture: null == hasCustomTexture ? _self.hasCustomTexture : hasCustomTexture // ignore: cast_nullable_to_non_nullable
as bool,activeTab: null == activeTab ? _self.activeTab : activeTab // ignore: cast_nullable_to_non_nullable
as String,isPanelExpanded: null == isPanelExpanded ? _self.isPanelExpanded : isPanelExpanded // ignore: cast_nullable_to_non_nullable
as bool,selectedModelPath: null == selectedModelPath ? _self.selectedModelPath : selectedModelPath // ignore: cast_nullable_to_non_nullable
as String,isAssetModel: null == isAssetModel ? _self.isAssetModel : isAssetModel // ignore: cast_nullable_to_non_nullable
as bool,assetModels: null == assetModels ? _self._assetModels : assetModels // ignore: cast_nullable_to_non_nullable
as List<String>,modelMaterials: null == modelMaterials ? _self._modelMaterials : modelMaterials // ignore: cast_nullable_to_non_nullable
as List<String>,selectedMaterial: null == selectedMaterial ? _self.selectedMaterial : selectedMaterial // ignore: cast_nullable_to_non_nullable
as String,modelTextures: null == modelTextures ? _self._modelTextures : modelTextures // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,shadowEnabled: null == shadowEnabled ? _self.shadowEnabled : shadowEnabled // ignore: cast_nullable_to_non_nullable
as bool,shadowIntensity: null == shadowIntensity ? _self.shadowIntensity : shadowIntensity // ignore: cast_nullable_to_non_nullable
as double,shadowSoftness: null == shadowSoftness ? _self.shadowSoftness : shadowSoftness // ignore: cast_nullable_to_non_nullable
as double,exposure: null == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as double,environmentPreset: null == environmentPreset ? _self.environmentPreset : environmentPreset // ignore: cast_nullable_to_non_nullable
as String,customEnvUrl: null == customEnvUrl ? _self.customEnvUrl : customEnvUrl // ignore: cast_nullable_to_non_nullable
as String,toneMapper: null == toneMapper ? _self.toneMapper : toneMapper // ignore: cast_nullable_to_non_nullable
as String,fieldOfView: null == fieldOfView ? _self.fieldOfView : fieldOfView // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitTheta: null == cameraOrbitTheta ? _self.cameraOrbitTheta : cameraOrbitTheta // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitPhi: null == cameraOrbitPhi ? _self.cameraOrbitPhi : cameraOrbitPhi // ignore: cast_nullable_to_non_nullable
as double,cameraOrbitRadius: null == cameraOrbitRadius ? _self.cameraOrbitRadius : cameraOrbitRadius // ignore: cast_nullable_to_non_nullable
as double,interpolationDecay: null == interpolationDecay ? _self.interpolationDecay : interpolationDecay // ignore: cast_nullable_to_non_nullable
as double,limitOrbit: null == limitOrbit ? _self.limitOrbit : limitOrbit // ignore: cast_nullable_to_non_nullable
as bool,modelAnimations: null == modelAnimations ? _self._modelAnimations : modelAnimations // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAnimation: null == selectedAnimation ? _self.selectedAnimation : selectedAnimation // ignore: cast_nullable_to_non_nullable
as String,isAnimationPlaying: null == isAnimationPlaying ? _self.isAnimationPlaying : isAnimationPlaying // ignore: cast_nullable_to_non_nullable
as bool,hotspots: null == hotspots ? _self._hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
