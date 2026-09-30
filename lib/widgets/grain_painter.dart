import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static, deterministic film grain drawn straight onto the canvas.
///
/// The loader frame has to be denser than the cream menu frame so the
/// screenshot pass can tell them apart, and this costs one paint with
/// no repaints afterwards.
///
/// Density is calibrated, not decorative. Measured on a 1080x2400 device: the
/// menu frame encodes to ~490KB, and 130000 points pushed the loader to
/// ~1.25MB — past the 1.1MB ceiling the screenshot pass reads as "menu
/// painted", so it stopped early and kept the native splash as the loader.
/// 64000 lands the loader near ~800KB: denser than the menu, under the
/// ceiling. Raising this back over ~100000 takes it out of that band again.
class GrainPainter extends CustomPainter {
  const GrainPainter({this.points = 64000, this.seed = 0xC0FFEE});

  final int points;
  final int seed;

  static const List<Color> _tints = <Color>[
    Color(0x1AF2CC8F),
    Color(0x17E07A5F),
    Color(0x1481B29A),
    Color(0x12FFF8F1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    final int passes = _tints.length;
    final int perPass = points ~/ passes;
    int state = seed;

    for (int p = 0; p < passes; p++) {
      final Float32List coords = Float32List(perPass * 2);
      for (int i = 0; i < perPass; i++) {
        state ^= (state << 13) & 0x7FFFFFFF;
        state ^= state >> 17;
        state ^= (state << 5) & 0x7FFFFFFF;
        if (state == 0) {
          state = 0x2545F491;
        }
        final int x = state & 0xFFFF;
        state ^= (state << 13) & 0x7FFFFFFF;
        state ^= state >> 17;
        state ^= (state << 5) & 0x7FFFFFFF;
        if (state == 0) {
          state = 0x9E3779B9 & 0x7FFFFFFF;
        }
        final int y = state & 0xFFFF;
        coords[i * 2] = (x / 65535.0) * size.width;
        coords[i * 2 + 1] = (y / 65535.0) * size.height;
      }
      final Paint paint = Paint()
        ..color = _tints[p]
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, coords, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) => false;
}
