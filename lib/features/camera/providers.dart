import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

class CameraState {
  final CameraController? controller;
  final bool initialized;
  final Object? error;
  const CameraState({this.controller, this.initialized = false, this.error});
}

class CameraControllerNotifier extends StateNotifier<CameraState> {
  CameraControllerNotifier() : super(const CameraState());

  Future<void> init(CameraDescription description) async {
    final controller = CameraController(description, ResolutionPreset.medium, enableAudio: false);
    try {
      await controller.initialize();
      state = CameraState(controller: controller, initialized: true);
    } catch (e) {
      state = CameraState(controller: null, initialized: false, error: e);
    }
  }

  Future<XFile?> takePicture() async {
    final c = state.controller;
    if (c == null || !state.initialized) return null;
    if (c.value.isTakingPicture) return null;
    return await c.takePicture();
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

final cameraControllerProvider = StateNotifierProvider<CameraControllerNotifier, CameraState>((ref) {
  return CameraControllerNotifier();
});
