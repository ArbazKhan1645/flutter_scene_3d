/// Lightweight immutable data models for scene objects and lights.
/// These are plain Dart classes (no code-gen required).
library;

import 'dart:convert';

// ── SceneTransform ────────────────────────────────────────────────────────────

/// Holds position, rotation (degrees), and scale for a scene object.
class SceneTransform {
  const SceneTransform({
    this.px = 0, this.py = 0, this.pz = 0,
    this.rx = 0, this.ry = 0, this.rz = 0,
    this.sx = 1, this.sy = 1, this.sz = 1,
  });

  final double px, py, pz; // position
  final double rx, ry, rz; // rotation (degrees)
  final double sx, sy, sz; // scale

  factory SceneTransform.fromMap(Map<String, dynamic> m) {
    final pos = (m['position'] as Map?)?.cast<String, dynamic>() ?? {};
    final rot = (m['rotation'] as Map?)?.cast<String, dynamic>() ?? {};
    final scl = (m['scale']    as Map?)?.cast<String, dynamic>() ?? {};
    return SceneTransform(
      px: (pos['x'] as num?)?.toDouble() ?? 0,
      py: (pos['y'] as num?)?.toDouble() ?? 0,
      pz: (pos['z'] as num?)?.toDouble() ?? 0,
      rx: (rot['x'] as num?)?.toDouble() ?? 0,
      ry: (rot['y'] as num?)?.toDouble() ?? 0,
      rz: (rot['z'] as num?)?.toDouble() ?? 0,
      sx: (scl['x'] as num?)?.toDouble() ?? 1,
      sy: (scl['y'] as num?)?.toDouble() ?? 1,
      sz: (scl['z'] as num?)?.toDouble() ?? 1,
    );
  }

  SceneTransform copyWith({
    double? px, double? py, double? pz,
    double? rx, double? ry, double? rz,
    double? sx, double? sy, double? sz,
  }) => SceneTransform(
    px: px ?? this.px, py: py ?? this.py, pz: pz ?? this.pz,
    rx: rx ?? this.rx, ry: ry ?? this.ry, rz: rz ?? this.rz,
    sx: sx ?? this.sx, sy: sy ?? this.sy, sz: sz ?? this.sz,
  );

  Map<String, dynamic> toMap() => {
    'position': {'x': px, 'y': py, 'z': pz},
    'rotation': {'x': rx, 'y': ry, 'z': rz},
    'scale'   : {'x': sx, 'y': sy, 'z': sz},
  };
}

// ── SceneObjectMeta ───────────────────────────────────────────────────────────

/// Metadata for a single object in the 3-D scene (primitive or GLTF model).
class SceneObjectMeta {
  const SceneObjectMeta({
    required this.id,
    required this.name,
    required this.type,
    this.visible   = true,
    this.color     = '#6c63ff',
    this.metalness = 0.0,
    this.roughness = 0.65,
    this.opacity   = 1.0,
    this.wireframe = false,
    this.transform = const SceneTransform(),
  });

  final String id;
  final String name;
  final String type;      // cube / sphere / plane / cylinder / cone / torus / capsule / gltf
  final bool   visible;
  final String color;     // hex string e.g. '#6c63ff'
  final double metalness;
  final double roughness;
  final double opacity;
  final bool   wireframe;
  final SceneTransform transform;

  factory SceneObjectMeta.fromMap(Map<String, dynamic> m) => SceneObjectMeta(
    id       : m['id']        as String? ?? '',
    name     : m['name']      as String? ?? 'Object',
    type     : m['type']      as String? ?? 'cube',
    visible  : m['visible']   as bool?   ?? true,
    color    : m['color']     as String? ?? '#6c63ff',
    metalness: (m['metalness'] as num?)?.toDouble() ?? 0.0,
    roughness: (m['roughness'] as num?)?.toDouble() ?? 0.65,
    opacity  : (m['opacity']   as num?)?.toDouble() ?? 1.0,
    wireframe: m['wireframe'] as bool?   ?? false,
    transform: m['transform'] is Map
        ? SceneTransform.fromMap((m['transform'] as Map).cast<String, dynamic>())
        : const SceneTransform(),
  );

  SceneObjectMeta copyWith({
    String? id, String? name, String? type,
    bool?   visible, String? color,
    double? metalness, double? roughness, double? opacity, bool? wireframe,
    SceneTransform? transform,
  }) => SceneObjectMeta(
    id       : id        ?? this.id,
    name     : name      ?? this.name,
    type     : type      ?? this.type,
    visible  : visible   ?? this.visible,
    color    : color     ?? this.color,
    metalness: metalness ?? this.metalness,
    roughness: roughness ?? this.roughness,
    opacity  : opacity   ?? this.opacity,
    wireframe: wireframe ?? this.wireframe,
    transform: transform ?? this.transform,
  );
}

// ── SceneLightMeta ────────────────────────────────────────────────────────────

/// Metadata for a light in the scene.
class SceneLightMeta {
  const SceneLightMeta({
    required this.id,
    required this.name,
    required this.type,
    this.intensity = 1.0,
    this.color     = '#ffffff',
  });

  final String id;
  final String name;
  final String type;       // ambient / directional / point / spot / hemisphere
  final double intensity;
  final String color;

  factory SceneLightMeta.fromMap(Map<String, dynamic> m) => SceneLightMeta(
    id       : m['id']        as String? ?? '',
    name     : m['name']      as String? ?? 'Light',
    type     : m['type']      as String? ?? 'ambient',
    intensity: (m['intensity'] as num?)?.toDouble() ?? 1.0,
    color    : m['color']     as String? ?? '#ffffff',
  );

  SceneLightMeta copyWith({
    String? id, String? name, String? type, double? intensity, String? color,
  }) => SceneLightMeta(
    id       : id        ?? this.id,
    name     : name      ?? this.name,
    type     : type      ?? this.type,
    intensity: intensity ?? this.intensity,
    color    : color     ?? this.color,
  );
}

// ── SceneData ─────────────────────────────────────────────────────────────────

/// Full scene snapshot as received from the Three.js bridge.
class SceneData {
  const SceneData({this.objects = const [], this.lights = const []});

  final List<SceneObjectMeta> objects;
  final List<SceneLightMeta>  lights;

  factory SceneData.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return SceneData.fromMap(map);
  }

  factory SceneData.fromMap(Map<String, dynamic> m) => SceneData(
    objects: ((m['objects'] as List?) ?? [])
        .map((e) => SceneObjectMeta.fromMap((e as Map).cast<String, dynamic>()))
        .toList(),
    lights: ((m['lights'] as List?) ?? [])
        .map((e) => SceneLightMeta.fromMap((e as Map).cast<String, dynamic>()))
        .toList(),
  );
}
