import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers.dart';
import '../widgets/camera_overlay.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with WidgetsBindingObserver {
  bool _permissionGranted = false;
  CameraDescription? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final granted = await _ensurePermission();
    if (!mounted) return;
    setState(() => _permissionGranted = granted);
    if (granted) {
      final cameras = await ref.read(availableCamerasProvider.future);
      if (cameras.isNotEmpty) {
        _selected = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        await ref.read(cameraControllerProvider.notifier).init(_selected!);
      }
    }
  }

  Future<bool> _ensurePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(cameraControllerProvider).controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _selected != null) {
      ref.read(cameraControllerProvider.notifier).init(_selected!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final camState = ref.watch(cameraControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      backgroundColor: Colors.black,
      body: _permissionGranted
          ? (camState.initialized && camState.controller != null)
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(camState.controller!),
                    const CameraOverlay(),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              final file = await ref.read(cameraControllerProvider.notifier).takePicture();
                              if (file != null && mounted) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved: ${file.path}')),
                                );
                              }
                            },
                            child: const Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: camState.error != null
                      ? Text('Camera error: ${camState.error}', style: const TextStyle(color: Colors.white))
                      : const CircularProgressIndicator(),
                )
          : _PermissionRationale(onGrant: _init),
    );
  }
}

class _PermissionRationale extends StatelessWidget {
  final Future<void> Function() onGrant;
  const _PermissionRationale({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            const Text(
              'Camera access is required to capture photos.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onGrant,
              child: const Text('Grant Permission'),
            )
          ],
        ),
      ),
    );
  }
}
