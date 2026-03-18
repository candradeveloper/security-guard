import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class IntruderService {
  static Future<void> captureIntruder() async {
    try {
      final cameras = await availableCameras();
      
      // Cari kamera depan
      CameraDescription? frontCamera;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          frontCamera = cam;
          break;
        }
      }
      
      final camera = frontCamera ?? cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await controller.initialize();
      
      final dir = await getApplicationDocumentsDirectory();
      final intruderDir = Directory('${dir.path}/intruders');
      if (!await intruderDir.exists()) {
        await intruderDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${intruderDir.path}/intruder_$timestamp.jpg';
      
      final image = await controller.takePicture();
      await File(image.path).copy(path);
      await controller.dispose();
      
    } catch (e) {
      // Silently fail — user tidak perlu tahu foto diambil
      print('IntruderService error: $e');
    }
  }
}
