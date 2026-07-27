/// Asset browser panel — lists GLB/GLTF models from assets/models/
/// and lets the user insert them into the Three.js scene.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/editor_provider.dart';

class AssetBrowserPanel extends ConsumerWidget {
  const AssetBrowserPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final models   = state.assetModels;

    return Container(
      color: const Color(0xFF13131f),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, color: Color(0xFF6c63ff), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'ASSETS',
                  style: TextStyle(
                    color: Color(0xFFaaaacc),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${models.length} models',
                  style: const TextStyle(color: Color(0xFF555566), fontSize: 11),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1f1f35), height: 1),

          // ── Grid of model cards ──────────────────────────────────
          if (models.isEmpty)
            const Expanded(child: _EmptyAssets())
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount     : 3,
                  crossAxisSpacing   : 10,
                  mainAxisSpacing    : 10,
                  childAspectRatio   : 0.9,
                ),
                itemCount: models.length,
                itemBuilder: (_, i) {
                  final path = models[i];
                  final name = path
                      .split('/')
                      .last
                      .replaceAll('.glb', '')
                      .replaceAll('.gltf', '')
                      .replaceAll('_', ' ');
                  return _ModelCard(
                    name   : name,
                    onTap  : () => notifier.loadAssetModelIntoScene(path),
                    loading: state.isLoading && state.statusMessage?.contains(name) == true,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.name, required this.onTap, this.loading = false});
  final String name;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      decoration: BoxDecoration(
        color : const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2a2a40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading
              ? const SizedBox(
                  width: 26, height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF6c63ff)),
                )
              : const Icon(Icons.view_in_ar_rounded, color: Color(0xFF6c63ff), size: 28),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color     : Color(0xFFccccdd),
                fontSize  : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('GLB', style: TextStyle(color: Color(0xFF444455), fontSize: 9, letterSpacing: 0.8)),
        ],
      ),
    ),
  );
}

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inventory_2_outlined, color: Color(0xFF2a2a40), size: 36),
        SizedBox(height: 12),
        Text('No models found',
            style: TextStyle(color: Color(0xFF444455), fontSize: 12)),
        SizedBox(height: 4),
        Text('Add .glb files to assets/models/',
            style: TextStyle(color: Color(0xFF333344), fontSize: 11)),
      ],
    ),
  );
}
