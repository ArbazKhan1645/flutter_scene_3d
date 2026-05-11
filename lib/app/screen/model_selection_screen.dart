import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';

class ModelSelectionScreen extends StatelessWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ModelController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildElegantHeader(),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(child: _buildDevicePicker(ctrl)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PREINSTALLED MODELS',
                    style: TextStyle(
                      color: Color(0xFF2D3436),
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (ctrl.assetModels.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFE53935)),
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final path = ctrl.assetModels[index];
                  final name = path
                      .split('/')
                      .last
                      .replaceAll('.glb', '')
                      .replaceAll('_', ' ');
                  return _buildModelCard(path, name, ctrl);
                }, childCount: ctrl.assetModels.length),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildElegantHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Arbaz Khan',
                    style: TextStyle(
                      color: Color(0xFF2D3436),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const FlutterLogo(size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevicePicker(ModelController ctrl) {
    return GestureDetector(
      onTap: ctrl.pickModelFromDevice,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3436),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D3436).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.add_to_photos_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import Custom Model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick GLB/GLTF from storage',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(String path, String name, ModelController ctrl) {
    return GestureDetector(
      onTap: () {
        ctrl.selectModel(path, true);
        Get.toNamed('/viewer');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.view_in_ar_rounded,
                color: Color(0xFFE53935),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '3D ASSET',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
