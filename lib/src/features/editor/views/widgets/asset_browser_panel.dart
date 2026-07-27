/// Asset browser panel — lists GLB/GLTF models from assets/models/
/// and custom storage import button.
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, color: Color(0xFF6c63ff), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'ASSETS & MODELS',
                  style: TextStyle(
                    color: Color(0xFFaaaacc),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${models.length} bundled',
                  style: const TextStyle(color: Color(0xFF555566), fontSize: 11),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1f1f35), height: 1),

          // ── Import Custom File Banner ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: state.isImporting ? null : notifier.importCustomModelFromDevice,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6c63ff).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6c63ff).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_to_photos_rounded, color: Color(0xFF6c63ff), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Import Custom Model',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Pick .glb or .gltf from phone storage',
                            style: TextStyle(color: Color(0xFF888899), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    if (state.isImporting)
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6c63ff)),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF6c63ff), size: 18),
                  ],
                ),
              ),
            ),
          ),

          // ── Pre-packaged Models Grid ─────────────────────────────
          if (models.isEmpty)
            const Expanded(child: _EmptyAssets())
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount     : 3,
                  crossAxisSpacing   : 8,
                  mainAxisSpacing    : 8,
                  childAspectRatio   : 0.85,
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
                  final isLoadingThis = state.isLoading && state.statusMessage?.contains(name) == true;

                  return _ModelCard(
                    name        : name,
                    onTap       : () => notifier.loadAssetModelIntoScene(path),
                    loading     : isLoadingThis,
                    progress    : isLoadingThis ? state.loadProgress : 0,
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
  const _ModelCard({
    required this.name,
    required this.onTap,
    this.loading = false,
    this.progress = 0,
  });

  final String name;
  final VoidCallback onTap;
  final bool loading;
  final int progress;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      decoration: BoxDecoration(
        color : const Color(0xFF1c1c2e),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: loading ? const Color(0xFF6c63ff) : const Color(0xFF2a2a40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                value: progress > 0 ? progress / 100.0 : null,
                strokeWidth: 2.5,
                color: const Color(0xFF6c63ff),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              progress > 0 ? '$progress%' : 'Loading',
              style: const TextStyle(color: Color(0xFF6c63ff), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            const Icon(Icons.view_in_ar_rounded, color: Color(0xFF6c63ff), size: 26),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color     : Color(0xFFccccdd),
                  fontSize  : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text('GLB Asset', style: TextStyle(color: Color(0xFF555566), fontSize: 8)),
          ],
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
        Text('No preloaded models found',
            style: TextStyle(color: Color(0xFF444455), fontSize: 12)),
        SizedBox(height: 4),
        Text('Use Import Custom Model above to load .glb files',
            style: TextStyle(color: Color(0xFF333344), fontSize: 11)),
      ],
    ),
  );
}
