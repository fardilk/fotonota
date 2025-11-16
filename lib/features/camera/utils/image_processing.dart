import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect; // for Rect type
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ProcessedImageResult {
  final File file;
  final bool hasRedStroke;
  ProcessedImageResult({required this.file, required this.hasRedStroke});
}

class ImageProcessing {
  // Crop an area and draw a red rounded rectangle stroke to mark approval
  static Future<ProcessedImageResult> cropWithRedStroke({
    required File input,
    required Rect rectInPreview,
    required double previewWidth,
    required double previewHeight,
    double borderWidth = 6,
    double radius = 24,
  }) async {
    final bytes = await input.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) {
      throw Exception('Invalid image');
    }
    // Map preview-space rect to image pixel-space rect, maintaining aspect
    final scaleX = src.width / previewWidth;
    final scaleY = src.height / previewHeight;
    final x = (rectInPreview.left * scaleX).round().clamp(0, src.width - 1);
    final y = (rectInPreview.top * scaleY).round().clamp(0, src.height - 1);
    final w = (rectInPreview.width * scaleX).round().clamp(1, src.width - x);
    final h = (rectInPreview.height * scaleY).round().clamp(1, src.height - y);

    var cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
    // Draw a red rounded rectangle stroke overlay near edges
  final red = img.ColorRgba8(255, 0, 0, 255);
    final bw = borderWidth.round();
    // outer rect
    final ox = 0 + bw ~/ 2;
    final oy = 0 + bw ~/ 2;
    final ow = cropped.width - bw;
    final oh = cropped.height - bw;
    // Draw multiple strokes to emulate thickness
    for (var i = 0; i < bw; i++) {
      img.drawRect(
        cropped,
        x1: ox + i,
        y1: oy + i,
        x2: ox + ow - i,
        y2: oy + oh - i,
        color: red,
      );
    }

    final outBytes = img.encodeJpg(cropped, quality: 90);
    final dir = await getTemporaryDirectory();
    final outFile = File('${dir.path}/fn_processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await outFile.writeAsBytes(Uint8List.fromList(outBytes));
    return ProcessedImageResult(file: outFile, hasRedStroke: true);
  }

  // Basic heuristic to detect presence of red stroke on borders
  static Future<bool> hasRedBorder(File input) async {
    final bytes = await input.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) return false;
    int redPixels = 0, sampled = 0;
    // Sample along the border perimeter at intervals
    for (int x = 0; x < src.width; x += (src.width ~/ 50).clamp(1, 20)) {
      sampled += 2;
      final topPx = src.getPixel(x, 0);
      final botPx = src.getPixel(x, src.height - 1);
      if (_isRedPixel(topPx)) redPixels++;
      if (_isRedPixel(botPx)) redPixels++;
    }
    for (int y = 0; y < src.height; y += (src.height ~/ 50).clamp(1, 20)) {
      sampled += 2;
      final leftPx = src.getPixel(0, y);
      final rightPx = src.getPixel(src.width - 1, y);
      if (_isRedPixel(leftPx)) redPixels++;
      if (_isRedPixel(rightPx)) redPixels++;
    }
    if (sampled == 0) return false;
    final ratio = redPixels / sampled;
    return ratio > 0.2; // 20% of sampled border pixels are red
  }

  static bool _isRedPixel(img.Pixel pixel) {
    final r = pixel.r;
    final g = pixel.g;
    final b = pixel.b;
    return r > 200 && g < 60 && b < 60;
  }
}
