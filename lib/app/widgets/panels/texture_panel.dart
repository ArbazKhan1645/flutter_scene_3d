import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class TexturePanel extends StatelessWidget {
  final ModelController controller;

  const TexturePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Texture',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),

          // Upload area
          Obx(
            () => controller.hasCustomTexture.value
                ? _buildTexturePreview(controller)
                : _buildUploadArea(controller),
          ),

          const SizedBox(height: 24),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE53935).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFFE53935),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Technical Details',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _tipRow('Best results with 2048x2048 PNG'),
                _tipRow('Texture overrides solid paint color'),
                _tipRow('Supports standard model UV maps'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF636E72),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(ModelController ctrl) {
    return GestureDetector(
      onTap: ctrl.pickAndApplyTexture,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Texture',
              style: TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to browse gallery',
              style: TextStyle(color: Color(0xFF636E72), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTexturePreview(ModelController ctrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ctrl.uploadedTexturePath.value.isNotEmpty
                  ? Image.file(
                      File(ctrl.uploadedTexturePath.value),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 80, height: 80, color: Colors.grey[100]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Texture',
                  style: TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _actionBtn(
                      Icons.refresh_rounded,
                      ctrl.pickAndApplyTexture,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _actionBtn(
                      Icons.delete_outline_rounded,
                      ctrl.removeTexture,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
