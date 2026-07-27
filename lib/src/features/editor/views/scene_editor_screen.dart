/// Full-screen offline 3-D Scene Editor.
///
/// Layout (phone portrait):
///   ┌──────────────────────────────┐
///   │        EditorToolbar         │  ← always visible
///   ├──────────────────────────────┤
///   │                              │
///   │   Three.js WebView (fills)   │  ← touchable 3-D viewport
///   │                              │
///   │  [T][R][S]  (floating left)  │  ← TransformToolbar
///   │                              │
///   ├──────────────────────────────┤
///   │  Side drawer: hierarchy /    │
///   │  properties / assets         │
///   │  (slides up from bottom)     │
///   └──────────────────────────────┘
///   │        PrimitivesBar         │  ← always visible at bottom
///   └──────────────────────────────┘
///
/// Wider screens (tablet / web) show the hierarchy and properties
/// panels inline as left/right columns.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/editor_provider.dart';
import 'widgets/asset_browser_panel.dart';
import 'widgets/editor_toolbar.dart';
import 'widgets/modeling_tools_panel.dart';
import 'widgets/properties_panel.dart';
import 'widgets/scene_hierarchy_panel.dart';
import 'widgets/transform_toolbar.dart';

class SceneEditorScreen extends ConsumerStatefulWidget {
  const SceneEditorScreen({super.key});

  @override
  ConsumerState<SceneEditorScreen> createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends ConsumerState<SceneEditorScreen>
    with SingleTickerProviderStateMixin {
  late WebViewController _webController;

  // Bottom-drawer height fractions
  static const double _drawerCollapsed = 0.0;
  static const double _drawerExpanded  = 0.45;
  double _drawerFraction = _drawerCollapsed;

  late AnimationController _drawerAnim;
  late Animation<double>   _drawerCurve;

  @override
  void initState() {
    super.initState();
    _drawerAnim = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 350),
    );
    _drawerCurve = CurvedAnimation(parent: _drawerAnim, curve: Curves.easeInOutCubic);

    // Build the WebViewController via the notifier (keeps it in the provider)
    _webController = ref.read(editorProvider.notifier).buildEditorController();
  }

  @override
  void dispose() {
    _drawerAnim.dispose();
    super.dispose();
  }

  // ── Drawer helpers ─────────────────────────────────────────────

  void _toggleDrawer(String panel) {
    final state    = ref.read(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final same     = state.activePanel == panel && _drawerFraction > 0;
    notifier.setActivePanel(panel);
    if (same) {
      _drawerAnim.reverse();
      setState(() => _drawerFraction = _drawerCollapsed);
    } else {
      _drawerAnim.forward();
      setState(() => _drawerFraction = _drawerExpanded);
    }
  }

  void _closeDrawer() {
    _drawerAnim.reverse();
    setState(() => _drawerFraction = _drawerCollapsed);
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size      = MediaQuery.sizeOf(context);
    final isWide    = size.width >= 720;
    final state     = ref.watch(editorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: SafeArea(
        child: Column(
          children: [
            // ── Toolbar ─────────────────────────────────────────
            EditorToolbar(onBack: () => Navigator.of(context).pop()),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: isWide
                  ? _buildWideLayout(state)
                  : _buildMobileLayout(state),
            ),

            // ── Primitives bar (always at bottom) ────────────────
            const PrimitivesBar(),
          ],
        ),
      ),
    );
  }

  // ── Wide layout (tablet / web) ─────────────────────────────────

  Widget _buildWideLayout(dynamic state) => Row(
    children: [
      // Left: hierarchy
      SizedBox(
        width: 220,
        child: _buildPanelTabs(
          panels   : ['hierarchy', 'tools', 'assets'],
          labels   : ['Tree', 'Tools', 'Assets'],
          icons    : [Icons.account_tree_rounded, Icons.build_circle_rounded, Icons.folder_open_rounded],
          state    : state,
          panelBuilder: _buildPanel,
        ),
      ),
      // Centre: viewport
      Expanded(child: _buildViewport()),
      // Right: properties
      const SizedBox(
        width: 260,
        child: PropertiesPanel(),
      ),
    ],
  );

  // ── Mobile layout ──────────────────────────────────────────────

  Widget _buildMobileLayout(dynamic state) => Stack(
    children: [
      // Viewport fills all
      Positioned.fill(child: _buildViewport()),

      // Transform toolbar floating left
      const Positioned(
        left : 12,
        top  : 20,
        child: TransformToolbar(),
      ),

      // Panel tabs floating right
      Positioned(
        right: 12,
        top  : 20,
        child: _buildFloatingTabs(state),
      ),

      // Bottom drawer
      if (_drawerFraction > 0)
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: AnimatedBuilder(
            animation: _drawerCurve,
            builder: (context, child) {
              final frac = _drawerCurve.value * _drawerExpanded;
              final h    = MediaQuery.sizeOf(context).height * frac;
              return SizedBox(
                height: h,
                child: Column(
                  children: [
                    // Drag handle + close
                    GestureDetector(
                      onTap: _closeDrawer,
                      child: Container(
                        width: double.infinity,
                        height: 32,
                        color: const Color(0xFF13131f),
                        child: Center(
                          child: Container(
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a2a40),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _buildPanel(state.activePanel)),
                  ],
                ),
              );
            },
          ),
        ),
    ],
  );

  // ── Floating panel tab buttons (mobile) ────────────────────────

  Widget _buildFloatingTabs(dynamic state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131f),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1f1f35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FloatTab(
            icon   : Icons.account_tree_rounded,
            label  : 'Hierarchy',
            active : state.activePanel == 'hierarchy' && _drawerFraction > 0,
            onTap  : () => _toggleDrawer('hierarchy'),
          ),
          Container(height: 1, color: const Color(0xFF1f1f35)),
          _FloatTab(
            icon   : Icons.tune_rounded,
            label  : 'Properties',
            active : state.activePanel == 'properties' && _drawerFraction > 0,
            onTap  : () => _toggleDrawer('properties'),
          ),
          Container(height: 1, color: const Color(0xFF1f1f35)),
          _FloatTab(
            icon   : Icons.build_circle_rounded,
            label  : 'Tools',
            active : state.activePanel == 'tools' && _drawerFraction > 0,
            onTap  : () => _toggleDrawer('tools'),
          ),
          Container(height: 1, color: const Color(0xFF1f1f35)),
          _FloatTab(
            icon   : Icons.folder_open_rounded,
            label  : 'Assets',
            active : state.activePanel == 'assets' && _drawerFraction > 0,
            onTap  : () => _toggleDrawer('assets'),
          ),
        ],
      ),
    );
  }

  // ── Panel tab widget helper (wide layout) ───────────────────────

  Widget _buildPanelTabs({
    required List<String>   panels,
    required List<String>   labels,
    required List<IconData> icons,
    required dynamic        state,
    required Widget Function(String) panelBuilder,
  }) {
    return Column(
      children: [
        // Tab row
        Container(
          color: const Color(0xFF0d0d1a),
          child: Row(
            children: List.generate(panels.length, (i) {
              final active = state.activePanel == panels[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(editorProvider.notifier).setActivePanel(panels[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF13131f) : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: active ? const Color(0xFF6c63ff) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icons[i], size: 14,
                            color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566)),
                        const SizedBox(height: 2),
                        Text(labels[i],
                            style: TextStyle(
                              fontSize: 9,
                              color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566),
                              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(child: panelBuilder(state.activePanel)),
      ],
    );
  }

  // ── Panel content router ───────────────────────────────────────

  Widget _buildPanel(String panel) {
    switch (panel) {
      case 'hierarchy': return const SceneHierarchyPanel();
      case 'tools'    : return const ModelingToolsPanel();
      case 'assets'   : return const AssetBrowserPanel();
      case 'properties':
      default         : return const PropertiesPanel();
    }
  }

  // ── Three.js WebView viewport ──────────────────────────────────

  Widget _buildViewport() {
    return Stack(
      children: [
        WebViewWidget(controller: _webController),
        // Loading overlay while editor.js initialises
        Consumer(
          builder: (ctx, ref, _) {
            final ready = ref.watch(editorProvider.select((s) => s.isEditorReady));
            if (ready) return const SizedBox.shrink();
            return Container(
              color: const Color(0xFF0d0d1a),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6c63ff), strokeWidth: 2),
                    SizedBox(height: 20),
                    Text(
                      'Initialising 3D Editor…',
                      style: TextStyle(color: Color(0xFF888899), fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Floating tab button ────────────────────────────────────────────────────────

class _FloatTab extends StatelessWidget {
  const _FloatTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6c63ff).withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? const Color(0xFF6c63ff) : const Color(0xFF555566),
      ),
    ),
  );
}
