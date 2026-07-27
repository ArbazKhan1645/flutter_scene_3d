/// Scene hierarchy panel — shows all objects and lights in the scene.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scene_object.dart';
import '../../providers/editor_provider.dart';

class SceneHierarchyPanel extends ConsumerWidget {
  const SceneHierarchyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return Container(
      color: const Color(0xFF13131f),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded, color: Color(0xFF6c63ff), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'SCENE',
                  style: TextStyle(
                    color: Color(0xFFaaaacc),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.sceneObjects.length} obj',
                  style: const TextStyle(color: Color(0xFF555566), fontSize: 11),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1f1f35), height: 1),

          // ── Objects list ─────────────────────────────────────────
          Expanded(
            child: state.sceneObjects.isEmpty && state.sceneLights.isEmpty
                ? const _EmptyHint()
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Objects
                      ...state.sceneObjects.map((obj) => _ObjectTile(
                            obj     : obj,
                            selected: obj.id == state.selectedObjectId,
                            notifier: notifier,
                          )),

                      // Lights section
                      if (state.sceneLights.isNotEmpty) ...[
                        const _SectionLabel(label: 'LIGHTS', icon: Icons.wb_sunny_rounded),
                        ...state.sceneLights.map((l) => _LightTile(light: l, notifier: notifier)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Object tile ───────────────────────────────────────────────────────────────

class _ObjectTile extends ConsumerStatefulWidget {
  const _ObjectTile({
    required this.obj,
    required this.selected,
    required this.notifier,
  });
  final SceneObjectMeta obj;
  final bool selected;
  final EditorNotifier notifier;

  @override
  ConsumerState<_ObjectTile> createState() => _ObjectTileState();
}

class _ObjectTileState extends ConsumerState<_ObjectTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? const Color(0xFF6c63ff)
        : (_hovered ? const Color(0xFF1c1c2e) : Colors.transparent);

    return GestureDetector(
      onTap: () => widget.notifier.selectObject(widget.obj.id),
      child: MouseRegion(
        onEnter : (_) => setState(() => _hovered = true),
        onExit  : (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                _typeIcon(widget.obj.type),
                size: 14,
                color: widget.selected ? Colors.white : const Color(0xFF6c63ff),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.obj.name,
                  style: TextStyle(
                    color: widget.selected ? Colors.white : const Color(0xFFccccdd),
                    fontSize: 12,
                    fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Visibility toggle
              _IconAction(
                icon : widget.obj.visible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: widget.obj.visible
                    ? const Color(0xFF555577)
                    : const Color(0xFF333344),
                onTap: () => widget.notifier.toggleObjectVisibility(
                    widget.obj.id, !widget.obj.visible),
              ),

              // More menu
              _MoreMenu(obj: widget.obj, notifier: widget.notifier),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'sphere'  : return Icons.circle_outlined;
    case 'plane'   : return Icons.crop_landscape_rounded;
    case 'cylinder': return Icons.panorama_vertical_rounded;
    case 'cone'    : return Icons.change_history_rounded;
    case 'torus'   : return Icons.donut_large_rounded;
    case 'capsule' : return Icons.inbox_rounded;
    case 'gltf'    : return Icons.view_in_ar_rounded;
    default        : return Icons.crop_square_rounded; // cube
  }
}

// ── More menu ─────────────────────────────────────────────────────────────────

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.obj, required this.notifier});
  final SceneObjectMeta obj;
  final EditorNotifier  notifier;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    iconSize: 16,
    iconColor: const Color(0xFF444455),
    color: const Color(0xFF1c1c2e),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    itemBuilder: (_) => [
      _menuItem('focus',     Icons.center_focus_strong_rounded, 'Focus'),
      _menuItem('duplicate', Icons.copy_rounded,                 'Duplicate'),
      _menuItem('rename',    Icons.edit_rounded,                 'Rename'),
      _menuItem('delete',    Icons.delete_outline_rounded,       'Delete',
          color: const Color(0xFFff6584)),
    ],
    onSelected: (v) async {
      switch (v) {
        case 'focus'    : unawaited(notifier.focusObject(obj.id)); break;
        case 'duplicate': unawaited(notifier.duplicateObject(obj.id)); break;
        case 'delete'   : unawaited(notifier.deleteObject(obj.id)); break;
        case 'rename'   :
          final name = await _showRenameDialog(context, obj.name);
          if (name != null && name.isNotEmpty) unawaited(notifier.renameObject(obj.id, name));
          break;
      }
    },
  );

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
      {Color color = const Color(0xFFccccdd)}) =>
      PopupMenuItem(
        value: value,
        height: 36,
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
      );

  Future<String?> _showRenameDialog(BuildContext context, String current) =>
      showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController(text: current);
          return AlertDialog(
            backgroundColor: const Color(0xFF1c1c2e),
            title: const Text('Rename Object',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder : OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2a2a40))),
                focusedBorder : OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6c63ff))),
                filled   : true,
                fillColor: Color(0xFF13131f),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF555566))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text),
                child: const Text('Rename', style: TextStyle(color: Color(0xFF6c63ff))),
              ),
            ],
          );
        },
      );
}

// ── Light tile ────────────────────────────────────────────────────────────────

class _LightTile extends StatelessWidget {
  const _LightTile({required this.light, required this.notifier});
  final SceneLightMeta light;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        const Icon(Icons.wb_incandescent_rounded, size: 14, color: Color(0xFFffd700)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            light.name,
            style: const TextStyle(color: Color(0xFFccccdd), fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _IconAction(
          icon : Icons.delete_outline_rounded,
          color: const Color(0xFF333344),
          onTap: () => notifier.deleteLight(light.id),
        ),
      ],
    ),
  );
}

// ── Misc helpers ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
    child: Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF555566)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF555566), fontSize: 10, letterSpacing: 1.2)),
      ],
    ),
  );
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(icon, size: 14, color: color),
    ),
  );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.layers_outlined, color: Color(0xFF2a2a40), size: 36),
        const SizedBox(height: 12),
        const Text('No objects yet',
            style: TextStyle(color: Color(0xFF444455), fontSize: 12)),
        const SizedBox(height: 4),
        const Text('Add primitives or load a model',
            style: TextStyle(color: Color(0xFF333344), fontSize: 11)),
      ],
    ),
  );
}
