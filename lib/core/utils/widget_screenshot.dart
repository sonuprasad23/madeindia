import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captures whatever is currently rendered under [key] as PNG bytes.
///
/// Used by the Safe Viewer to let a user save a snapshot of a suspicious
/// page as evidence. Returns null (never throws) if capture isn't
/// possible in the current rendering mode — callers must handle that as
/// a normal, expected outcome, not an error to surface raw.
Future<Uint8List?> captureRepaintBoundary(GlobalKey key) async {
  try {
    final boundary = key.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
