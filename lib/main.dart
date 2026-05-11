import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer/app/controller/model_controller.dart';
import 'package:model_viewer/app/screen/model_selection_screen.dart';
import 'package:model_viewer/app/screen/view_model_screen.dart';

void main() {
  Get.put(ModelController());
  runApp(const MotorcycleViewerApp());
}

class MotorcycleViewerApp extends StatelessWidget {
  const MotorcycleViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '3D Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const ModelSelectionScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/viewer',
          page: () => const ModelViewerScreen(),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
}
