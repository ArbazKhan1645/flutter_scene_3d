import 'package:flutter/material.dart';
import '../../providers/viewer_provider.dart';

class TexturePanel extends StatelessWidget {
  final dynamic state;
  final ViewerNotifier notifier;

  const TexturePanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Custom Textures',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (state.hasCustomTexture)
          ListTile(
            leading: const Icon(Icons.image, color: Color(0xFFE53935)),
            title: const Text('Custom Texture Applied'),
            subtitle: Text(state.uploadedTexturePath.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: notifier.removeTexture,
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: notifier.pickAndApplyTexture,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Custom Texture'),
          ),
        const Divider(height: 40),
        const Text(
          'Model Textures',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (state.modelTextures.isEmpty)
          const Text('No embedded textures found', style: TextStyle(color: Colors.grey))
        else
          ...state.modelTextures.map<Widget>((tex) {
            return ListTile(
              dense: true,
              title: Text(tex['name'] ?? 'Unnamed Texture'),
              subtitle: Text(tex['material'] ?? 'Unknown Material'),
              leading: const Icon(Icons.texture),
            );
          }).toList(),
      ],
    );
  }
}
