/* ================================================================
   FlutterScene 3D — Three.js Scene Editor (r128)
   Fully offline: served from Flutter assets via loadFlutterAsset.

   Flutter → JS:  controller.runJavaScript('Editor.methodName(args)')
   JS → Flutter:  FlutterBridge.postMessage(JSON.stringify({type, data}))
================================================================ */

(function () {
  'use strict';

  // ── Private state ──────────────────────────────────────────────
  const _state = {
    objects   : {},   // id → { mesh, meta }
    lights    : {},   // id → { light, helper?, meta }
    selectedId: null,
    transformMode: 'translate',
    cameraType: 'perspective',
    isReady   : false,
    snapEnabled: false,
  };

  // ── Three.js core ──────────────────────────────────────────────
  let scene, renderer;
  let perspCamera, orthoCamera, activeCamera;
  let orbitControls, transformControls;
  let raycaster, mouse;
  let gridHelper, axesHelper, boxHelper;
  let animFrameId;
  let _idCounter = 0;

  // ── ID generator ───────────────────────────────────────────────
  function _genId(prefix) {
    return (prefix || 'obj') + '_' + Date.now() + '_' + (++_idCounter);
  }

  // ── Flutter bridge ─────────────────────────────────────────────
  function _post(type, data) {
    var payload = JSON.stringify({ type: type, data: data || {} });
    if (window.FlutterBridge) {
      FlutterBridge.postMessage(payload);
    } else {
      console.log('[Editor→Flutter]', type, data);
    }
  }

  // ── Initialise ─────────────────────────────────────────────────
  function _init() {
    // Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x16162a);

    // Renderer
    renderer = new THREE.WebGLRenderer({
      antialias: true,
      preserveDrawingBuffer: true,
      powerPreference: 'high-performance',
    });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.physicallyCorrectLights = true;
    renderer.outputEncoding = THREE.sRGBEncoding;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.2;
    document.getElementById('viewport').appendChild(renderer.domElement);

    // Perspective camera
    var aspect = window.innerWidth / window.innerHeight;
    perspCamera = new THREE.PerspectiveCamera(55, aspect, 0.01, 5000);
    perspCamera.position.set(6, 5, 10);
    perspCamera.lookAt(0, 0, 0);
    activeCamera = perspCamera;

    // Orthographic camera
    var s = 10;
    orthoCamera = new THREE.OrthographicCamera(-s * aspect, s * aspect, s, -s, 0.01, 5000);
    orthoCamera.position.set(6, 5, 10);
    orthoCamera.lookAt(0, 0, 0);

    // OrbitControls
    orbitControls = new THREE.OrbitControls(activeCamera, renderer.domElement);
    orbitControls.enableDamping = true;
    orbitControls.dampingFactor = 0.06;
    orbitControls.minDistance = 0.5;
    orbitControls.maxDistance = 2000;
    orbitControls.screenSpacePanning = true;

    // TransformControls
    transformControls = new THREE.TransformControls(activeCamera, renderer.domElement);
    transformControls.setMode('translate');
    transformControls.addEventListener('dragging-changed', function (e) {
      orbitControls.enabled = !e.value;
    });
    transformControls.addEventListener('objectChange', function () {
      if (_state.selectedId) {
        _updateBoxHelper();
        _post('objectTransformChanged', {
          id: _state.selectedId,
          transform: _getTransform(_state.objects[_state.selectedId].mesh),
        });
      }
    });
    scene.add(transformControls);

    // Raycaster
    raycaster = new THREE.Raycaster();
    mouse = new THREE.Vector2();

    // Grid
    gridHelper = new THREE.GridHelper(40, 40, 0x3a3a5c, 0x252540);
    scene.add(gridHelper);

    // Axes helper (XYZ)
    axesHelper = new THREE.AxesHelper(4);
    scene.add(axesHelper);

    // Selection box helper
    boxHelper = new THREE.BoxHelper(new THREE.Object3D(), 0x4ade80);
    boxHelper.visible = false;
    scene.add(boxHelper);

    // Default ambient light
    var ambient = new THREE.AmbientLight(0xffffff, 0.35);
    scene.add(ambient);
    var aid = _genId('light');
    _state.lights[aid] = {
      light: ambient,
      meta: { id: aid, type: 'ambient', name: 'Ambient Light', intensity: 0.35, color: '#ffffff' },
    };

    // Default directional light
    var dir = new THREE.DirectionalLight(0xffffff, 0.9);
    dir.position.set(8, 15, 10);
    dir.castShadow = true;
    dir.shadow.mapSize.width  = 2048;
    dir.shadow.mapSize.height = 2048;
    dir.shadow.camera.near = 0.5;
    dir.shadow.camera.far  = 200;
    dir.shadow.camera.left = dir.shadow.camera.bottom = -20;
    dir.shadow.camera.right = dir.shadow.camera.top   =  20;
    dir.shadow.radius = 3;
    scene.add(dir);
    var did = _genId('light');
    _state.lights[did] = {
      light: dir,
      meta: { id: did, type: 'directional', name: 'Directional Light', intensity: 0.9, color: '#ffffff' },
    };

    // Events
    renderer.domElement.addEventListener('click',      _onCanvasClick);
    renderer.domElement.addEventListener('touchend',   _onTouchEnd, { passive: false });
    window.addEventListener('resize', _onResize);
    document.addEventListener('keydown', _onKeyDown);

    _onResize();
    _animateLoop();

    _state.isReady = true;
    _post('editorReady', {});
  }

  // ── Render loop ────────────────────────────────────────────────
  function _animateLoop() {
    animFrameId = requestAnimationFrame(_animateLoop);
    orbitControls.update();
    if (boxHelper.visible) boxHelper.update();
    renderer.render(scene, activeCamera);
  }

  // ── Resize ─────────────────────────────────────────────────────
  function _onResize() {
    var w = window.innerWidth, h = window.innerHeight;
    renderer.setSize(w, h);

    perspCamera.aspect = w / h;
    perspCamera.updateProjectionMatrix();

    var s = 10, aspect = w / h;
    orthoCamera.left   = -s * aspect;
    orthoCamera.right  =  s * aspect;
    orthoCamera.top    =  s;
    orthoCamera.bottom = -s;
    orthoCamera.updateProjectionMatrix();
  }

  // ── Input handlers ─────────────────────────────────────────────
  function _onCanvasClick(event) {
    if (transformControls.dragging) return;
    var rect = renderer.domElement.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width)  *  2 - 1;
    mouse.y = ((event.clientY - rect.top)  / rect.height) * -2 + 1;
    _raycastSelect();
  }

  function _onTouchEnd(event) {
    if (event.changedTouches.length !== 1) return;
    if (transformControls.dragging) return;
    var touch = event.changedTouches[0];
    var rect = renderer.domElement.getBoundingClientRect();
    mouse.x = ((touch.clientX - rect.left) / rect.width)  *  2 - 1;
    mouse.y = ((touch.clientY - rect.top)  / rect.height) * -2 + 1;
    _raycastSelect();
  }

  function _raycastSelect() {
    raycaster.setFromCamera(mouse, activeCamera);
    var meshes = [];
    Object.values(_state.objects).forEach(function (o) {
      o.mesh.traverse(function (c) { if (c.isMesh) meshes.push(c); });
    });
    var hits = raycaster.intersectObjects(meshes, false);
    if (hits.length > 0) {
      var hit = hits[0].object;
      // Walk up until we find an editorId
      var target = hit;
      while (target && !target.userData.editorId && target.parent !== scene) {
        target = target.parent;
      }
      var id = target && target.userData.editorId;
      if (id && _state.objects[id]) { selectObject(id); return; }
    }
    deselectObject();
  }

  function _onKeyDown(event) {
    if (event.ctrlKey || event.metaKey) return;
    switch (event.key) {
      case 'Delete': case 'Backspace':
        if (_state.selectedId) deleteObject(_state.selectedId);
        break;
      case 'g': case 'G': setTransformMode('translate'); break;
      case 'r': case 'R': setTransformMode('rotate'); break;
      case 's': case 'S': setTransformMode('scale'); break;
      case 'f': case 'F': if (_state.selectedId) focusObject(_state.selectedId); break;
      case 'Escape': deselectObject(); break;
    }
  }

  // ── Primitive factory ──────────────────────────────────────────
  function _makeMaterial(params) {
    var color = (params && params.color) ? new THREE.Color(params.color) : new THREE.Color(0x6c63ff);
    return new THREE.MeshStandardMaterial({
      color     : color,
      metalness : (params && params.metalness != null) ? params.metalness : 0.0,
      roughness : (params && params.roughness != null) ? params.roughness : 0.65,
      side      : THREE.FrontSide,
    });
  }

  function _registerObject(mesh, name, type, params) {
    var id = _genId('obj');
    mesh.userData.editorId = id;
    mesh.castShadow    = true;
    mesh.receiveShadow = true;
    if (mesh.isGroup) {
      mesh.traverse(function (c) {
        c.userData.editorId = id;
        if (c.isMesh) { c.castShadow = true; c.receiveShadow = true; }
      });
    }
    scene.add(mesh);

    var colorHex = (params && params.color)
      ? '#' + new THREE.Color(params.color).getHexString()
      : '#6c63ff';

    _state.objects[id] = {
      mesh: mesh,
      meta: {
        id       : id,
        name     : name || type,
        type     : type,
        visible  : true,
        color    : colorHex,
        metalness: (params && params.metalness != null) ? params.metalness : 0.0,
        roughness: (params && params.roughness != null) ? params.roughness : 0.65,
        opacity  : 1.0,
        wireframe: false,
      },
    };
    _notifySceneUpdate();
    selectObject(id);
    return id;
  }

  // ── Primitive creators (public) ────────────────────────────────
  function createCube(params) {
    params = params || {};
    var geo  = new THREE.BoxGeometry(params.w || 1, params.h || 1, params.d || 1);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.position.set(params.x || 0, (params.y != null ? params.y : 0.5), params.z || 0);
    return _registerObject(mesh, params.name || 'Cube', 'cube', params);
  }

  function createSphere(params) {
    params = params || {};
    var r    = params.r  || 0.5;
    var geo  = new THREE.SphereGeometry(r, params.ws || 32, params.hs || 16);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.position.set(params.x || 0, (params.y != null ? params.y : r), params.z || 0);
    return _registerObject(mesh, params.name || 'Sphere', 'sphere', params);
  }

  function createPlane(params) {
    params = params || {};
    var geo  = new THREE.PlaneGeometry(params.w || 4, params.h || 4, params.ws || 1, params.hs || 1);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.rotation.x = -Math.PI / 2;
    mesh.position.set(params.x || 0, params.y || 0, params.z || 0);
    mesh.receiveShadow = true;
    return _registerObject(mesh, params.name || 'Plane', 'plane', params);
  }

  function createCylinder(params) {
    params = params || {};
    var h    = params.h  || 1;
    var geo  = new THREE.CylinderGeometry(params.rt || 0.5, params.rb || 0.5, h, params.rs || 32);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.position.set(params.x || 0, (params.y != null ? params.y : h / 2), params.z || 0);
    return _registerObject(mesh, params.name || 'Cylinder', 'cylinder', params);
  }

  function createCone(params) {
    params = params || {};
    var h    = params.h  || 1;
    var geo  = new THREE.ConeGeometry(params.r || 0.5, h, params.rs || 32);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.position.set(params.x || 0, (params.y != null ? params.y : h / 2), params.z || 0);
    return _registerObject(mesh, params.name || 'Cone', 'cone', params);
  }

  function createTorus(params) {
    params = params || {};
    var r    = params.r    || 0.45;
    var tube = params.tube || 0.15;
    var geo  = new THREE.TorusGeometry(r, tube, params.ts || 16, params.rs || 64);
    var mesh = new THREE.Mesh(geo, _makeMaterial(params));
    mesh.position.set(params.x || 0, (params.y != null ? params.y : (r + tube)), params.z || 0);
    return _registerObject(mesh, params.name || 'Torus', 'torus', params);
  }

  // Capsule = cylinder body + two hemi-sphere caps (r128 has no CapsuleGeometry)
  function createCapsule(params) {
    params = params || {};
    var r   = params.r || 0.3;
    var h   = params.h || 0.8;
    var mat = _makeMaterial(params);
    var group = new THREE.Group();

    var body = new THREE.Mesh(new THREE.CylinderGeometry(r, r, h, 32, 1), mat);
    group.add(body);

    var topCap = new THREE.Mesh(
      new THREE.SphereGeometry(r, 32, 16, 0, Math.PI * 2, 0, Math.PI / 2),
      mat
    );
    topCap.position.y = h / 2;
    group.add(topCap);

    var botCap = new THREE.Mesh(
      new THREE.SphereGeometry(r, 32, 16, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2),
      mat
    );
    botCap.position.y = -(h / 2);
    group.add(botCap);

    group.position.set(params.x || 0, (params.y != null ? params.y : (h / 2 + r)), params.z || 0);
    return _registerObject(group, params.name || 'Capsule', 'capsule', params);
  }

  // ── Selection ──────────────────────────────────────────────────
  function selectObject(id) {
    _clearSelection(false);
    var entry = _state.objects[id];
    if (!entry) return;

    _state.selectedId = id;
    transformControls.attach(entry.mesh);
    _updateBoxHelper();

    _post('objectSelected', {
      meta     : entry.meta,
      transform: _getTransform(entry.mesh),
    });
  }

  function deselectObject() {
    _clearSelection(true);
  }

  function _clearSelection(notify) {
    if (_state.selectedId) {
      transformControls.detach();
      boxHelper.visible = false;
      _state.selectedId = null;
      if (notify) _post('objectDeselected', {});
    }
  }

  function _updateBoxHelper() {
    if (!_state.selectedId) return;
    var mesh = _state.objects[_state.selectedId].mesh;
    boxHelper.setFromObject(mesh);
    boxHelper.visible = true;
  }

  // ── Object management ──────────────────────────────────────────
  function deleteObject(id) {
    var entry = _state.objects[id];
    if (!entry) return;
    if (_state.selectedId === id) _clearSelection(false);
    scene.remove(entry.mesh);
    entry.mesh.traverse(function (c) {
      if (c.geometry) c.geometry.dispose();
      if (c.material) {
        if (Array.isArray(c.material)) c.material.forEach(function (m) { m.dispose(); });
        else c.material.dispose();
      }
    });
    delete _state.objects[id];
    _notifySceneUpdate();
    _post('objectDeleted', { id: id });
  }

  function duplicateObject(id) {
    var entry = _state.objects[id];
    if (!entry) return null;

    var clone = entry.mesh.clone();
    clone.position.x += 1.2;

    var newId = _genId('obj');
    clone.userData.editorId = newId;
    clone.traverse(function (c) { if (c !== clone) c.userData.editorId = newId; });

    scene.add(clone);
    _state.objects[newId] = {
      mesh: clone,
      meta: Object.assign({}, entry.meta, { id: newId, name: entry.meta.name + ' Copy' }),
    };
    _notifySceneUpdate();
    selectObject(newId);
    return newId;
  }

  function renameObject(id, name) {
    if (!_state.objects[id]) return;
    _state.objects[id].meta.name = name;
    _notifySceneUpdate();
  }

  function setObjectVisible(id, visible) {
    var entry = _state.objects[id];
    if (!entry) return;
    entry.mesh.visible = visible;
    entry.meta.visible = visible;
    _notifySceneUpdate();
  }

  function focusObject(id) {
    var entry = _state.objects[id];
    if (!entry) return;
    var box    = new THREE.Box3().setFromObject(entry.mesh);
    var center = box.getCenter(new THREE.Vector3());
    var size   = box.getSize(new THREE.Vector3()).length();
    orbitControls.target.copy(center);
    var dir = perspCamera.position.clone().sub(center).normalize();
    perspCamera.position.copy(center.clone().add(dir.multiplyScalar(size * 1.8)));
    orbitControls.update();
  }

  // ── Transform ─────────────────────────────────────────────────
  function setTransformMode(mode) {
    _state.transformMode = mode;
    transformControls.setMode(mode);
    _post('transformModeChanged', { mode: mode });
  }

  function _getTransform(mesh) {
    return {
      position: { x: _r(mesh.position.x), y: _r(mesh.position.y), z: _r(mesh.position.z) },
      rotation: {
        x: _r(THREE.MathUtils.radToDeg(mesh.rotation.x)),
        y: _r(THREE.MathUtils.radToDeg(mesh.rotation.y)),
        z: _r(THREE.MathUtils.radToDeg(mesh.rotation.z)),
      },
      scale: { x: _r(mesh.scale.x), y: _r(mesh.scale.y), z: _r(mesh.scale.z) },
    };
  }

  function _r(n) { return Math.round(n * 10000) / 10000; }

  function setObjectTransform(id, pos, rot, scl) {
    var entry = _state.objects[id];
    if (!entry) return;
    var m = entry.mesh;
    if (pos) m.position.set(pos.x || 0, pos.y || 0, pos.z || 0);
    if (rot) m.rotation.set(
      THREE.MathUtils.degToRad(rot.x || 0),
      THREE.MathUtils.degToRad(rot.y || 0),
      THREE.MathUtils.degToRad(rot.z || 0)
    );
    if (scl) m.scale.set(scl.x || 1, scl.y || 1, scl.z || 1);
    _updateBoxHelper();
  }

  // ── Material ───────────────────────────────────────────────────
  function setObjectColor(id, r255, g255, b255) {
    var entry = _state.objects[id];
    if (!entry) return;
    var color = new THREE.Color(r255 / 255, g255 / 255, b255 / 255);
    entry.mesh.traverse(function (c) {
      if (c.isMesh && c.material) {
        if (Array.isArray(c.material)) {
          c.material = c.material.map(function(m) {
            var nm = m.clone();
            nm.color.copy(color);
            return nm;
          });
        } else {
          c.material = c.material.clone();
          c.material.color.copy(color);
        }
      }
    });
    entry.meta.color = '#' + color.getHexString();
    _notifySceneUpdate();
  }

  function setObjectColorHex(id, hex) {
    var rgb = _hexToRgb(hex);
    if (rgb) setObjectColor(id, rgb.r, rgb.g, rgb.b);
  }

  function setObjectMetalness(id, v) {
    var entry = _state.objects[id];
    if (!entry) return;
    entry.mesh.traverse(function (c) { if (c.isMesh && c.material) c.material.metalness = v; });
    entry.meta.metalness = v;
  }

  function setObjectRoughness(id, v) {
    var entry = _state.objects[id];
    if (!entry) return;
    entry.mesh.traverse(function (c) { if (c.isMesh && c.material) c.material.roughness = v; });
    entry.meta.roughness = v;
  }

  function setObjectOpacity(id, v) {
    var entry = _state.objects[id];
    if (!entry) return;
    entry.mesh.traverse(function (c) {
      if (c.isMesh && c.material) {
        c.material.opacity     = v;
        c.material.transparent = v < 1.0;
        c.material.needsUpdate = true;
      }
    });
    entry.meta.opacity = v;
  }

  function setObjectWireframe(id, enabled) {
    var entry = _state.objects[id];
    if (!entry) return;
    entry.mesh.traverse(function (c) {
      if (c.isMesh && c.material) c.material.wireframe = enabled;
    });
    entry.meta.wireframe = enabled;
  }

  // ── Lights ─────────────────────────────────────────────────────
  function _addLight(type, params) {
    params = params || {};
    var color     = params.color     ? new THREE.Color(params.color) : new THREE.Color(0xffffff);
    var intensity = params.intensity != null ? params.intensity : 1.0;
    var light;

    switch (type) {
      case 'ambient':
        light = new THREE.AmbientLight(color, intensity);
        break;
      case 'directional':
        light = new THREE.DirectionalLight(color, intensity);
        light.position.set(params.x || 5, params.y || 10, params.z || 5);
        light.castShadow = true;
        light.shadow.mapSize.width  = 1024;
        light.shadow.mapSize.height = 1024;
        break;
      case 'point':
        light = new THREE.PointLight(color, intensity, params.distance || 50, params.decay || 2);
        light.position.set(params.x || 0, params.y || 3, params.z || 0);
        light.castShadow = true;
        break;
      case 'spot':
        light = new THREE.SpotLight(color, intensity);
        light.position.set(params.x || 0, params.y || 6, params.z || 0);
        light.angle    = params.angle || Math.PI / 6;
        light.penumbra = params.penumbra || 0.2;
        light.castShadow = true;
        break;
      case 'hemisphere':
        var groundColor = params.groundColor ? new THREE.Color(params.groundColor) : new THREE.Color(0x443333);
        light = new THREE.HemisphereLight(color, groundColor, intensity);
        break;
      default:
        return null;
    }

    scene.add(light);
    var id = _genId('light');
    var name = (params.name || (type.charAt(0).toUpperCase() + type.slice(1) + ' Light'));
    _state.lights[id] = {
      light: light,
      meta : { id: id, type: type, name: name, intensity: intensity, color: '#' + color.getHexString() },
    };
    _notifySceneUpdate();
    return id;
  }

  function deleteLight(id) {
    var entry = _state.lights[id];
    if (!entry) return;
    scene.remove(entry.light);
    if (entry.light.dispose) entry.light.dispose();
    delete _state.lights[id];
    _notifySceneUpdate();
  }

  function setLightIntensity(id, v) {
    var entry = _state.lights[id];
    if (!entry) return;
    entry.light.intensity = v;
    entry.meta.intensity  = v;
  }

  function setLightColor(id, hex) {
    var entry = _state.lights[id];
    if (!entry) return;
    entry.light.color.set(hex);
    entry.meta.color = hex;
  }

  // ── Camera ─────────────────────────────────────────────────────
  function resetCamera() {
    perspCamera.position.set(6, 5, 10);
    perspCamera.lookAt(0, 0, 0);
    orbitControls.target.set(0, 0, 0);
    orbitControls.update();
  }

  function fitScene() {
    var ids = Object.keys(_state.objects);
    if (ids.length === 0) { resetCamera(); return; }
    var box = new THREE.Box3();
    ids.forEach(function (id) { box.expandByObject(_state.objects[id].mesh); });
    var center = box.getCenter(new THREE.Vector3());
    var size   = box.getSize(new THREE.Vector3()).length();
    orbitControls.target.copy(center);
    var dist = size * 1.6;
    perspCamera.position.copy(center.clone().add(new THREE.Vector3(dist * 0.5, dist * 0.5, dist)));
    perspCamera.lookAt(center);
    orbitControls.update();
  }

  function setCameraType(type) {
    _state.cameraType = type;
    if (type === 'orthographic') {
      orthoCamera.position.copy(perspCamera.position);
      orthoCamera.quaternion.copy(perspCamera.quaternion);
      activeCamera = orthoCamera;
    } else {
      perspCamera.position.copy(orthoCamera.position);
      perspCamera.quaternion.copy(orthoCamera.quaternion);
      activeCamera = perspCamera;
    }
    orbitControls.object  = activeCamera;
    transformControls.camera = activeCamera;
    orbitControls.update();
    _post('cameraTypeChanged', { type: type });
  }

  // ── Snap ───────────────────────────────────────────────────────
  function setSnap(enabled) {
    _state.snapEnabled = enabled;
    if (enabled) {
      transformControls.translationSnap = 0.5;
      transformControls.rotationSnap    = Math.PI / 12; // 15°
      transformControls.scaleSnap       = 0.25;
    } else {
      transformControls.translationSnap = null;
      transformControls.rotationSnap    = null;
      transformControls.scaleSnap       = null;
    }
  }

  // ── Grid & helpers ─────────────────────────────────────────────
  function setGridVisible(v) { gridHelper.visible = v; }
  function setAxesVisible(v) { axesHelper.visible = v; }

  // ── Scene data ─────────────────────────────────────────────────
  function _buildSceneData() {
    return {
      objects: Object.values(_state.objects).map(function (o) {
        return Object.assign({}, o.meta, { transform: _getTransform(o.mesh) });
      }),
      lights: Object.values(_state.lights).map(function (l) {
        return Object.assign({}, l.meta);
      }),
    };
  }

  function _notifySceneUpdate() {
    _post('sceneUpdated', _buildSceneData());
  }

  // ── Save / Load ────────────────────────────────────────────────
  function saveScene() {
    var cam = perspCamera;
    var payload = {
      objects: Object.values(_state.objects).map(function (o) {
        return Object.assign({}, o.meta, { transform: _getTransform(o.mesh) });
      }),
      lights: Object.values(_state.lights).map(function (l) {
        return Object.assign({}, l.meta);
      }),
      camera: {
        position: { x: _r(cam.position.x), y: _r(cam.position.y), z: _r(cam.position.z) },
        target  : { x: _r(orbitControls.target.x), y: _r(orbitControls.target.y), z: _r(orbitControls.target.z) },
        type    : _state.cameraType,
      },
    };
    var json = JSON.stringify(payload, null, 2);
    _post('sceneSaved', { json: json });
    return json;
  }

  function loadScene(jsonStr) {
    // Clear existing objects
    Object.keys(_state.objects).forEach(function (id) { deleteObject(id); });

    var data;
    try { data = JSON.parse(jsonStr); }
    catch (e) { _post('error', { message: 'Invalid scene JSON: ' + e.message }); return; }

    (data.objects || []).forEach(function (obj) {
      var p = Object.assign({}, obj);
      var id;
      switch (obj.type) {
        case 'cube'    : id = createCube(p);     break;
        case 'sphere'  : id = createSphere(p);   break;
        case 'plane'   : id = createPlane(p);    break;
        case 'cylinder': id = createCylinder(p); break;
        case 'cone'    : id = createCone(p);     break;
        case 'torus'   : id = createTorus(p);    break;
        case 'capsule' : id = createCapsule(p);  break;
        default: return;
      }
      if (id && obj.transform) {
        setObjectTransform(id, obj.transform.position, obj.transform.rotation, obj.transform.scale);
        _state.objects[id].meta.name    = obj.name;
        _state.objects[id].meta.visible = obj.visible;
        _state.objects[id].mesh.visible = obj.visible;
        if (obj.color)    setObjectColorHex(id, obj.color);
        if (obj.metalness != null) setObjectMetalness(id, obj.metalness);
        if (obj.roughness != null) setObjectRoughness(id, obj.roughness);
        if (obj.opacity   != null) setObjectOpacity(id, obj.opacity);
        if (obj.wireframe) setObjectWireframe(id, obj.wireframe);
      }
    });

    if (data.camera) {
      var c = data.camera;
      perspCamera.position.set(c.position.x, c.position.y, c.position.z);
      orbitControls.target.set(c.target.x, c.target.y, c.target.z);
      orbitControls.update();
    }

    deselectObject();
    _post('sceneLoaded', {});
  }

  // ── Export GLB ─────────────────────────────────────────────────
  function exportGLB() {
    var exporter    = new THREE.GLTFExporter();
    var exportScene = new THREE.Scene();
    Object.values(_state.objects).forEach(function (o) {
      exportScene.add(o.mesh.clone());
    });
    exporter.parse(
      exportScene,
      function (result) {
        var bytes  = new Uint8Array(result);
        var binary = '';
        for (var i = 0; i < bytes.byteLength; i++) {
          binary += String.fromCharCode(bytes[i]);
        }
        var b64 = btoa(binary);
        _post('exportComplete', { format: 'glb', base64: b64 });
      },
      { binary: true }
    );
  }

  // ── Load GLB model from base64 ─────────────────────────────────
  function loadModelFromBase64(base64, name, params) {
    params = params || {};
    try {
      var cleanB64 = base64.replace(/[\s\r\n]/g, '').replace(/-/g, '+').replace(/_/g, '/');
      var binary  = atob(cleanB64);
      var bytes   = new Uint8Array(binary.length);
      for (var i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);

      var loader = new THREE.GLTFLoader();
      loader.parse(
        bytes.buffer,
        '',
        function (gltf) {
          var model = gltf.scene;
          model.traverse(function (c) {
            if (c.isMesh) {
              c.castShadow    = true;
              c.receiveShadow = true;
              if (c.material) {
                c.material.metalness = params.metalness != null ? params.metalness : c.material.metalness;
                c.material.roughness = params.roughness != null ? params.roughness : c.material.roughness;
              }
            }
          });

          // Auto-scale large or tiny models
          var box  = new THREE.Box3().setFromObject(model);
          var size = box.getSize(new THREE.Vector3()).length();
          if (size > 15 || size < 0.1) {
            var targetScale = 6 / (size || 1);
            model.scale.setScalar(targetScale);
          }

          // Center on Y=0
          var box2   = new THREE.Box3().setFromObject(model);
          var center = box2.getCenter(new THREE.Vector3());
          var minY   = box2.min.y;
          model.position.sub(new THREE.Vector3(center.x, minY, center.z));

          var id = _genId('model');
          model.userData.editorId = id;
          model.traverse(function (c) { if (c !== model) c.userData.editorId = id; });

          scene.add(model);
          _state.objects[id] = {
            mesh: model,
            meta: {
              id       : id,
              name     : name || 'Model',
              type     : 'gltf',
              visible  : true,
              color    : '#ffffff',
              metalness: 0,
              roughness: 0.5,
              opacity  : 1.0,
              wireframe: false,
            },
          };
          _notifySceneUpdate();
          selectObject(id);
          fitScene();
          _post('loadProgress', { progress: 100, name: name });
        },
        function (err) {
          _post('error', { message: 'GLTFLoader error: ' + (err.message || err) });
        }
      );
    } catch (e) {
      _post('error', { message: 'Base64 decode error: ' + e.message });
    }
  }

  // ── Chunked Base64 Streaming Loader ─────────────────────────────
  var _modelChunks = [];
  function clearModelChunks() {
    _modelChunks = [];
  }
  function appendModelChunk(chunk) {
    _modelChunks.push(chunk);
  }
  function finishChunkedModel(name, params) {
    var fullB64 = _modelChunks.join('');
    _modelChunks = [];
    loadModelFromBase64(fullB64, name, params);
  }

  // ── Load model from URL (Android WebViewAssetLoader / Web) ──────
  function loadModelFromURL(url, name, params) {
    params = params || {};
    var loader = new THREE.GLTFLoader();
    _post('loadProgress', { progress: 0, name: name });
    loader.load(
      url,
      function (gltf) {
        var model = gltf.scene;
        model.traverse(function (c) {
          if (c.isMesh) {
            c.castShadow    = true;
            c.receiveShadow = true;
            if (c.material) {
              if (params.metalness != null) c.material.metalness = params.metalness;
              if (params.roughness != null) c.material.roughness = params.roughness;
            }
          }
        });
        // Auto-scale
        var box  = new THREE.Box3().setFromObject(model);
        var size = box.getSize(new THREE.Vector3()).length();
        if (size > 10) model.scale.setScalar(8 / size);
        // Ground-center
        var center = box.getCenter(new THREE.Vector3());
        var minY   = box.min.y;
        model.position.sub(new THREE.Vector3(center.x, minY, center.z));
        var id = _genId('model');
        model.userData.editorId = id;
        model.traverse(function (c) { if (c !== model) c.userData.editorId = id; });
        scene.add(model);
        _state.objects[id] = {
          mesh: model,
          meta: {
            id: id, name: name || 'Model', type: 'gltf',
            visible: true, color: '#ffffff',
            metalness: 0, roughness: 0.5, opacity: 1.0, wireframe: false,
          },
        };
        _notifySceneUpdate();
        selectObject(id);
        _post('loadProgress', { progress: 100, name: name });
      },
      function (xhr) {
        if (xhr.total > 0) {
          var pct = Math.round(xhr.loaded / xhr.total * 100);
          _post('loadProgress', { progress: pct, name: name });
        }
      },
      function (err) {
        _post('error', { message: 'URL load failed: ' + (err.message || err) });
      }
    );
  }

  // ── MESH MODIFIERS & DEFORMATIONS ──────────────────────────────

  // Bend geometry along specified axis ('x', 'y', 'z')
  function bendObject(id, axis, angleDeg) {
    var entry = _state.objects[id];
    if (!entry) return;
    var rad = THREE.MathUtils.degToRad(angleDeg || 0);
    if (Math.abs(rad) < 0.001) return;

    entry.mesh.traverse(function(c) {
      if (c.isMesh && c.geometry) {
        c.geometry = c.geometry.clone();
        var pos = c.geometry.attributes.position;
        for (var i = 0; i < pos.count; i++) {
          var x = pos.getX(i), y = pos.getY(i), z = pos.getZ(i);
          if (axis === 'x') {
            var cAngle = y * rad * 0.2;
            pos.setY(i, y * Math.cos(cAngle) - z * Math.sin(cAngle));
            pos.setZ(i, y * Math.sin(cAngle) + z * Math.cos(cAngle));
          } else if (axis === 'z') {
            var cAngle = x * rad * 0.2;
            pos.setX(i, x * Math.cos(cAngle) - y * Math.sin(cAngle));
            pos.setY(i, x * Math.sin(cAngle) + y * Math.cos(cAngle));
          } else { // default 'y'
            var cAngle = y * rad * 0.2;
            pos.setX(i, x * Math.cos(cAngle) - z * Math.sin(cAngle));
            pos.setZ(i, x * Math.sin(cAngle) + z * Math.cos(cAngle));
          }
        }
        pos.needsUpdate = true;
        c.geometry.computeVertexNormals();
      }
    });
    _updateBoxHelper();
    _notifySceneUpdate();
  }

  // Twist geometry around Y axis
  function twistObject(id, angleDeg) {
    var entry = _state.objects[id];
    if (!entry) return;
    var rad = THREE.MathUtils.degToRad(angleDeg || 0);
    entry.mesh.traverse(function(c) {
      if (c.isMesh && c.geometry) {
        c.geometry = c.geometry.clone();
        var pos = c.geometry.attributes.position;
        for (var i = 0; i < pos.count; i++) {
          var y = pos.getY(i);
          var twistFactor = y * rad * 0.3;
          var x = pos.getX(i), z = pos.getZ(i);
          pos.setX(i, x * Math.cos(twistFactor) - z * Math.sin(twistFactor));
          pos.setZ(i, x * Math.sin(twistFactor) + z * Math.cos(twistFactor));
        }
        pos.needsUpdate = true;
        c.geometry.computeVertexNormals();
      }
    });
    _updateBoxHelper();
    _notifySceneUpdate();
  }

  // Taper geometry along Y axis (scale top/bottom)
  function taperObject(id, topFactor) {
    var entry = _state.objects[id];
    if (!entry) return;
    var factor = (topFactor != null) ? topFactor : 0.5;
    entry.mesh.traverse(function(c) {
      if (c.isMesh && c.geometry) {
        c.geometry = c.geometry.clone();
        var pos = c.geometry.attributes.position;
        var box = new THREE.Box3().setFromBufferAttribute(pos);
        var minY = box.min.y, height = box.max.y - box.min.y || 1;

        for (var i = 0; i < pos.count; i++) {
          var y = pos.getY(i);
          var normY = (y - minY) / height;
          var s = 1.0 + (factor - 1.0) * normY;
          pos.setX(i, pos.getX(i) * s);
          pos.setZ(i, pos.getZ(i) * s);
        }
        pos.needsUpdate = true;
        c.geometry.computeVertexNormals();
      }
    });
    _updateBoxHelper();
    _notifySceneUpdate();
  }

  // Mirror / Flip across axis ('x', 'y', 'z')
  function mirrorObject(id, axis) {
    var entry = _state.objects[id];
    if (!entry) return;
    var m = entry.mesh;
    if (axis === 'x') m.scale.x *= -1;
    else if (axis === 'y') m.scale.y *= -1;
    else if (axis === 'z') m.scale.z *= -1;
    _updateBoxHelper();
    _notifySceneUpdate();
  }

  // Align object to ground (Y = 0)
  function alignToGround(id) {
    var entry = _state.objects[id];
    if (!entry) return;
    var box = new THREE.Box3().setFromObject(entry.mesh);
    var minY = box.min.y;
    entry.mesh.position.y -= minY;
    _updateBoxHelper();
    _notifySceneUpdate();
  }

  // ── MATERIAL PRESETS ───────────────────────────────────────────
  function setMaterialPreset(id, preset) {
    var entry = _state.objects[id];
    if (!entry) return;

    entry.mesh.traverse(function(c) {
      if (!c.isMesh) return;
      var mat;
      switch (preset) {
        case 'car_paint':
          mat = new THREE.MeshStandardMaterial({
            color: c.material.color || new THREE.Color(0xd62828),
            metalness: 0.8,
            roughness: 0.15,
          });
          break;
        case 'glass':
          mat = new THREE.MeshPhysicalMaterial({
            color: new THREE.Color(0xffffff),
            metalness: 0.0,
            roughness: 0.05,
            transmission: 0.9,
            transparent: true,
            opacity: 0.4,
            ior: 1.5,
          });
          break;
        case 'chrome':
          mat = new THREE.MeshStandardMaterial({
            color: new THREE.Color(0xe0e0e0),
            metalness: 1.0,
            roughness: 0.05,
          });
          break;
        case 'neon':
          mat = new THREE.MeshStandardMaterial({
            color: c.material.color || new THREE.Color(0x00f0ff),
            emissive: c.material.color || new THREE.Color(0x00f0ff),
            emissiveIntensity: 2.5,
            roughness: 0.2,
          });
          break;
        case 'gold':
          mat = new THREE.MeshStandardMaterial({
            color: new THREE.Color(0xffd700),
            metalness: 0.9,
            roughness: 0.2,
          });
          break;
        case 'matte':
          mat = new THREE.MeshStandardMaterial({
            color: c.material.color || new THREE.Color(0x6c63ff),
            metalness: 0.0,
            roughness: 0.95,
          });
          break;
        case 'wood':
          mat = new THREE.MeshStandardMaterial({
            color: new THREE.Color(0x8b5a2b),
            metalness: 0.0,
            roughness: 0.75,
          });
          break;
        default:
          return;
      }
      c.material = mat;
    });
    _notifySceneUpdate();
  }

  // ── ENVIRONMENT LIGHTING PRESETS ───────────────────────────────
  function setEnvironmentPreset(preset) {
    switch (preset) {
      case 'studio':
        scene.background = new THREE.Color(0x1a1a24);
        renderer.toneMappingExposure = 1.3;
        break;
      case 'sunset':
        scene.background = new THREE.Color(0x2d1b33);
        renderer.toneMappingExposure = 1.1;
        break;
      case 'cyberpunk':
        scene.background = new THREE.Color(0x0a0518);
        renderer.toneMappingExposure = 1.6;
        break;
      case 'daylight':
        scene.background = new THREE.Color(0x87ceeb);
        renderer.toneMappingExposure = 1.0;
        break;
      case 'dark':
      default:
        scene.background = new THREE.Color(0x16162a);
        renderer.toneMappingExposure = 1.2;
        break;
    }
    _post('environmentChanged', { preset: preset });
  }

  // ── GROUPING & COMBINING ───────────────────────────────────────
  function groupObjects(idList) {
    if (!idList || idList.length < 2) return null;
    var group = new THREE.Group();
    var groupId = _genId('group');
    group.userData.editorId = groupId;

    idList.forEach(function(id) {
      var entry = _state.objects[id];
      if (entry) {
        scene.remove(entry.mesh);
        group.add(entry.mesh);
        delete _state.objects[id];
      }
    });

    scene.add(group);
    _state.objects[groupId] = {
      mesh: group,
      meta: { id: groupId, name: 'Combined Group', type: 'group', visible: true, color: '#ffffff', metalness: 0, roughness: 0.5, opacity: 1, wireframe: false }
    };
    _notifySceneUpdate();
    selectObject(groupId);
    return groupId;
  }

  function ungroupObject(groupId) {
    var entry = _state.objects[groupId];
    if (!entry || !entry.mesh.isGroup) return;

    var children = [].concat(entry.mesh.children);
    children.forEach(function(child) {
      entry.mesh.remove(child);
      scene.add(child);
      var childId = _genId('obj');
      child.userData.editorId = childId;
      _state.objects[childId] = {
        mesh: child,
        meta: { id: childId, name: child.name || 'Object', type: 'cube', visible: true, color: '#6c63ff', metalness: 0, roughness: 0.5, opacity: 1, wireframe: false }
      };
    });

    scene.remove(entry.mesh);
    delete _state.objects[groupId];
    _notifySceneUpdate();
    deselectObject();
  }

  // ── CSG BOOLEAN OPERATIONS (CUT / JOIN) ────────────────────────
  function booleanSubtract(targetId, cutterId) {
    var tEntry = _state.objects[targetId];
    var cEntry = _state.objects[cutterId];
    if (!tEntry || !cEntry) return;

    // Use Box / Sphere boundary geometry subtraction simulation
    var tMesh = tEntry.mesh;
    var cMesh = cEntry.mesh;

    // Shift cutter scale/geometry boundary
    tMesh.traverse(function(c) {
      if (c.isMesh && c.geometry) {
        var boxC = new THREE.Box3().setFromObject(cMesh);
        c.geometry = c.geometry.clone();
        var pos = c.geometry.attributes.position;
        var worldV = new THREE.Vector3();

        for (var i = 0; i < pos.count; i++) {
          worldV.set(pos.getX(i), pos.getY(i), pos.getZ(i)).applyMatrix4(c.matrixWorld);
          if (boxC.containsPoint(worldV)) {
            // Flatten cut vertices inside cutter volume
            pos.setY(i, pos.getY(i) - (boxC.max.y - boxC.min.y) * 0.5);
          }
        }
        pos.needsUpdate = true;
        c.geometry.computeVertexNormals();
      }
    });

    deleteObject(cutterId);
    _updateBoxHelper();
    _notifySceneUpdate();
    selectObject(targetId);
  }

  // ── Background color ────────────────────────────────────────────
  function setBackground(hex) {
    scene.background = new THREE.Color(hex);
  }

  // ── Screenshot ─────────────────────────────────────────────────
  function takeScreenshot() {
    renderer.render(scene, activeCamera);
    var dataURL = renderer.domElement.toDataURL('image/png');
    var b64 = dataURL.split(',')[1];
    _post('screenshotReady', { base64: b64 });
  }

  // ── Shadow toggle ───────────────────────────────────────────────
  function setShadowsEnabled(enabled) {
    renderer.shadowMap.enabled = enabled;
    renderer.shadowMap.needsUpdate = true;
    Object.values(_state.objects).forEach(function (o) {
      o.mesh.traverse(function (c) {
        if (c.isMesh) { c.castShadow = enabled; c.receiveShadow = enabled; }
      });
    });
  }

  // ── Duplicate selected ──────────────────────────────────────────
  function duplicateSelected() {
    if (_state.selectedId) return duplicateObject(_state.selectedId);
    return null;
  }

  // ── Clear scene ────────────────────────────────────────────────
  function clearScene() {
    Object.keys(_state.objects).forEach(function (id) { deleteObject(id); });
    _post('sceneCleared', {});
  }

  // ── Helper utilities ───────────────────────────────────────────
  function _hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? { r: parseInt(result[1], 16), g: parseInt(result[2], 16), b: parseInt(result[3], 16) }
      : null;
  }

  // ── Public API (callable from Flutter) ─────────────────────────
  window.Editor = {
    // Primitives
    createCube    : function (p) { return createCube    (_safeParse(p)); },
    createSphere  : function (p) { return createSphere  (_safeParse(p)); },
    createPlane   : function (p) { return createPlane   (_safeParse(p)); },
    createCylinder: function (p) { return createCylinder(_safeParse(p)); },
    createCone    : function (p) { return createCone    (_safeParse(p)); },
    createTorus   : function (p) { return createTorus   (_safeParse(p)); },
    createCapsule : function (p) { return createCapsule (_safeParse(p)); },

    // Selection
    selectObject  : selectObject,
    deselectObject: deselectObject,

    // Object management
    deleteObject   : deleteObject,
    duplicateObject: duplicateObject,
    renameObject   : renameObject,
    setObjectVisible: setObjectVisible,
    focusObject    : focusObject,
    clearScene     : clearScene,

    // Transform
    setTransformMode  : setTransformMode,
    setObjectTransform: function (id, posJson, rotJson, sclJson) {
      setObjectTransform(id, _safeParse(posJson), _safeParse(rotJson), _safeParse(sclJson));
    },
    setSnap: setSnap,

    // Material
    setObjectColorHex : setObjectColorHex,
    setObjectColor    : setObjectColor,
    setObjectMetalness: setObjectMetalness,
    setObjectRoughness: setObjectRoughness,
    setObjectOpacity  : setObjectOpacity,
    setObjectWireframe: setObjectWireframe,

    // Lights
    addAmbientLight    : function (p) { return _addLight('ambient',    _safeParse(p)); },
    addDirectionalLight: function (p) { return _addLight('directional',_safeParse(p)); },
    addPointLight      : function (p) { return _addLight('point',      _safeParse(p)); },
    addSpotLight       : function (p) { return _addLight('spot',       _safeParse(p)); },
    addHemisphereLight : function (p) { return _addLight('hemisphere', _safeParse(p)); },
    deleteLight        : deleteLight,
    setLightIntensity  : setLightIntensity,
    setLightColor      : setLightColor,

    // Camera
    resetCamera : resetCamera,
    fitScene    : fitScene,
    setCameraType: setCameraType,
    focusSelected: function () { if (_state.selectedId) focusObject(_state.selectedId); },

    // Grid
    setGridVisible: setGridVisible,
    setAxesVisible: setAxesVisible,

    // Scene persistence
    saveScene  : saveScene,
    loadScene  : function (json) { loadScene(json); },
    exportGLB  : exportGLB,

    // Model import
    loadModelFromBase64: function (b64, name, p) {
      loadModelFromBase64(b64, name, _safeParse(p));
    },
    loadModelFromURL: function (url, name, p) {
      loadModelFromURL(url, name, _safeParse(p));
    },
    clearModelChunks: clearModelChunks,
    appendModelChunk: appendModelChunk,
    finishChunkedModel: function (name, p) {
      finishChunkedModel(name, _safeParse(p));
    },

    // Mesh Modifiers & Deformations
    bendObject   : bendObject,
    twistObject  : twistObject,
    taperObject  : taperObject,
    mirrorObject : mirrorObject,
    alignToGround: alignToGround,

    // Material & Environment Presets
    setMaterialPreset   : setMaterialPreset,
    setEnvironmentPreset: setEnvironmentPreset,

    // Grouping & Booleans
    groupObjects    : groupObjects,
    ungroupObject   : ungroupObject,
    booleanSubtract : booleanSubtract,

    // Scene utils
    setBackground    : setBackground,
    takeScreenshot   : takeScreenshot,
    setShadowsEnabled: setShadowsEnabled,
    duplicateSelected: duplicateSelected,

    // Query
    getScene: function () { _post('sceneData', _buildSceneData()); },
    getSelected: function () {
      if (!_state.selectedId) return;
      var e = _state.objects[_state.selectedId];
      if (e) _post('objectSelected', { meta: e.meta, transform: _getTransform(e.mesh) });
    },
  };

  function _safeParse(v) {
    if (!v || v === 'null' || v === 'undefined') return {};
    if (typeof v === 'object') return v;
    try { return JSON.parse(v); } catch (e) { return {}; }
  }

  // ── Boot ───────────────────────────────────────────────────────
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', _init);
  } else {
    _init();
  }

}());
