import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers.dart';
import '../widgets/camera_overlay.dart';
import '../../utils/image_processing.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/prefs_helper.dart';
import '../../../../core/ui/app_snackbars.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with WidgetsBindingObserver {
  bool _permissionGranted = false;
  CameraDescription? _selected;
  Rect? _overlayRect; // cache from layout for processing
  Size? _previewSize;
  double? _presetLeft, _presetTop, _presetWidth, _presetHeight;

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
      // Load overlay preset (applied during first layout)
      final preset = await PrefsHelper.getOverlayPreset();
      _presetLeft = preset.left;
      _presetTop = preset.top;
      _presetWidth = preset.width;
      _presetHeight = preset.height;
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = Size(constraints.maxWidth, constraints.maxHeight);
                        // Mirror default from overlay widget
                        _overlayRect ??= () {
                          if (_presetLeft != null && _presetTop != null && _presetWidth != null && _presetHeight != null) {
                            // Clamp to bounds to avoid offscreen
                            final double left = _presetLeft!
                                .clamp(0.0, (size.width - _presetWidth!))
                                .toDouble();
                            final double top = _presetTop!
                                .clamp(0.0, (size.height - _presetHeight!))
                                .toDouble();
                            final double width = _presetWidth!
                                .clamp(50.0, size.width)
                                .toDouble();
                            final double height = _presetHeight!
                                .clamp(40.0, size.height)
                                .toDouble();
                            return Rect.fromLTWH(left, top, width, height);
                          }
                          final w = size.width * 0.8;
                          final h = size.height * 0.25;
                          final left = (size.width - w) / 2;
                          final top = (size.height - h) / 2;
                          return Rect.fromLTWH(left, top, w, h);
                        }();
                        _previewSize = size;
                        return Stack(children: [
                          CameraOverlay(focusRect: _overlayRect),
                          // Draggable/Resizable overlay hit area
                          Positioned(
                            left: _overlayRect!.left,
                            top: _overlayRect!.top,
                            width: _overlayRect!.width,
                            height: _overlayRect!.height,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (d) {
                                setState(() {
                                  final double newLeft = (_overlayRect!.left + d.delta.dx)
                                      .clamp(0.0, size.width - _overlayRect!.width)
                                      .toDouble();
                                  final double newTop = (_overlayRect!.top + d.delta.dy)
                                      .clamp(0.0, size.height - _overlayRect!.height)
                                      .toDouble();
                                  _overlayRect = _overlayRect!
                                      .shift(Offset(newLeft - _overlayRect!.left, newTop - _overlayRect!.top));
                                });
                              },
                              onPanEnd: (_) async {
                                await _saveOverlayPreset();
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          // Simple resize handle (bottom-right corner)
                          Positioned(
                            left: _overlayRect!.right - 24,
                            top: _overlayRect!.bottom - 24,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (d) {
                                setState(() {
                                  final double newW = (_overlayRect!.width + d.delta.dx)
                                      .clamp(50.0, (size.width - _overlayRect!.left))
                                      .toDouble();
                                  final double newH = (_overlayRect!.height + d.delta.dy)
                                      .clamp(40.0, (size.height - _overlayRect!.top))
                                      .toDouble();
                                  _overlayRect = Rect.fromLTWH(_overlayRect!.left, _overlayRect!.top, newW, newH);
                                });
                              },
                              onPanEnd: (_) async {
                                await _saveOverlayPreset();
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.drag_handle, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CaptureButton(onCapture: _captureWithProcessing),
                          const SizedBox(width: 16),
                          _UploadButton(onUpload: _uploadWithProcessing),
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

  Future<void> _saveOverlayPreset() async {
    if (_overlayRect == null) return;
    await PrefsHelper.saveOverlayPreset(
      left: _overlayRect!.left,
      top: _overlayRect!.top,
      width: _overlayRect!.width,
      height: _overlayRect!.height,
    );
  }

  Future<void> _captureWithProcessing() async {
  // Using AppSnackbars for consistent notifications
  final size = _previewSize ?? MediaQuery.of(context).size;
    final rect = _overlayRect ?? _defaultRectForSize(size);
    final xfile = await ref.read(cameraControllerProvider.notifier).takePicture();
    if (xfile == null) {
      if (!mounted) return;
  AppSnackbars.error(context, 'Failed to capture image');
      return;
    }
    try {
      final result = await ImageProcessing.cropWithRedStroke(
        input: File(xfile.path),
        rectInPreview: rect,
        previewWidth: size.width,
        previewHeight: size.height,
      );
      final successMsg = 'Approved image saved: ${result.file.path}';
      if (!mounted) return;
  AppSnackbars.success(context, successMsg);
    } catch (e) {
      final errMsg = 'Processing failed: $e';
      if (!mounted) return;
  AppSnackbars.error(context, errMsg);
    }
  }

  Future<void> _uploadWithProcessing() async {
  // Using AppSnackbars for consistent notifications
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 4000, imageQuality: 95);
    if (picked == null) return;
    final file = File(picked.path);
    final ok = await ImageProcessing.hasRedBorder(file);
    final okMsg = 'Approved upload (red stroke detected)';
    final badMsg = 'Rejected: file must include red stroke focus border';
    if (!mounted) return;
    if (ok) {
  AppSnackbars.success(context, okMsg);
    } else {
  AppSnackbars.warn(context, badMsg);
    }
  }

  Rect _defaultRectForSize(Size size) {
    final w = size.width * 0.8;
    final h = size.height * 0.25;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;
    return Rect.fromLTWH(left, top, w, h);
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onCapture});
  final Future<void> Function() onCapture;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: onCapture,
      child: const Icon(Icons.camera_alt, color: Colors.black),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onUpload});
  final Future<void> Function() onUpload;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'upload_btn',
      backgroundColor: Colors.white,
      onPressed: onUpload,
      child: const Icon(Icons.upload_file, color: Colors.black),
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
