import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/constants/app_colors.dart';
import '../art/folk_art.dart';

class _Spot {
  _Spot(this.x, this.y, this.kind);
  final double x;
  final double y;
  final int kind;
}

/// Painted village backdrop: sky, sun, hills, hut, trees, pond, fence.
/// Everything is drawn in code from relative coordinates, so it scales
/// to any screen size.
class SceneBackground extends PositionComponent {
  SceneBackground() : super(priority: -10);

  double _t = 0;

  /// Painted background (set by the game once loaded). When null the
  /// procedural scene below is drawn instead.
  Image? image;

  /// Bottom edge of the scenery band in game pixels; plots start below it.
  double sceneBottom = 0;

  // Fraction of the source image that is scenery (sky, hut, pond, fence).
  static const double _bandFrac = 0.43;

  double _scaleFor(Image img) =>
      math.max(size.y * 0.36 / (img.height * _bandFrac), size.x / img.width);

  void updateLayout() {
    final img = image;
    if (img == null) {
      sceneBottom = size.y * 0.38;
    } else {
      sceneBottom = img.height * _bandFrac * _scaleFor(img);
    }
  }

  final List<_Spot> _spots = () {
    final rnd = math.Random(3);
    return List.generate(
        70, (_) => _Spot(rnd.nextDouble(), 0.3 + rnd.nextDouble() * 0.7, rnd.nextInt(4)));
  }();

  @override
  void update(double dt) {
    _t += dt;
  }

  Path _hill(double w, double base, double amp, double freq, double phase, double bottom) {
    final p = Path()
      ..moveTo(0, bottom)
      ..lineTo(0, base - amp * (math.sin(phase) + 1) / 2);
    for (double x = 0; x <= w; x += 6) {
      p.lineTo(x, base - amp * (math.sin(x * freq + phase) + 1) / 2);
    }
    p
      ..lineTo(w, bottom)
      ..close();
    return p;
  }

  @override
  void render(Canvas canvas) {
    final img = image;
    if (img == null) {
      _renderProcedural(canvas);
      return;
    }
    final w = size.x;
    final h = size.y;
    if (w < 10 || h < 10) return;
    final iw = img.width.toDouble();
    final ih = img.height.toDouble();
    final bandH = ih * _bandFrac;
    final s = _scaleFor(img);
    final viewW = w / s;
    // On narrow screens only part of the width fits: drift slowly across
    // the village so the player sees all of it.
    final slack = math.max(0.0, iw - viewW);
    final panX = slack * (0.5 + 0.5 * math.sin(_t * 0.06));
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final top = bandH * s;
    canvas.drawImageRect(img, Rect.fromLTWH(panX, 0, viewW, bandH),
        Rect.fromLTWH(0, 0, w, top), paint);
    canvas.drawImageRect(img, Rect.fromLTWH(panX, bandH, viewW, ih - bandH),
        Rect.fromLTWH(0, top, w, math.max(0.0, h - top)), paint);
  }

  void _renderProcedural(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    if (w < 10 || h < 10) return;
    final horizon = h * 0.30;

    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizon + 2),
      Paint()
        ..shader = Gradient.linear(
            Offset.zero, Offset(0, horizon), const [AppColors.skyTop, AppColors.skyBottom]),
    );

    // Sun
    drawSun(canvas, Offset(w * 0.5, h * 0.11), math.min(w * 0.075, 36.0), _t);

    // Clouds
    final cloud = Paint()..color = const Color(0xCCFFFFFF);
    for (var i = 0; i < 3; i++) {
      final x = ((_t * (5 + i * 2) + i * w * 0.4) % (w + 180)) - 90;
      final y = h * (0.06 + 0.045 * i);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 70, height: 20), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 18, y - 8), width: 44, height: 22), cloud);
      canvas.drawOval(Rect.fromCenter(center: Offset(x - 18, y - 5), width: 36, height: 18), cloud);
    }

    // Mountains
    final mountains = Path()
      ..moveTo(0, horizon)
      ..lineTo(0, horizon - h * 0.04)
      ..lineTo(w * 0.2, horizon - h * 0.09)
      ..lineTo(w * 0.36, horizon - h * 0.035)
      ..lineTo(w * 0.58, horizon - h * 0.12)
      ..lineTo(w * 0.78, horizon - h * 0.045)
      ..lineTo(w, horizon - h * 0.08)
      ..lineTo(w, horizon)
      ..close();
    canvas.drawPath(mountains, Paint()..color = const Color(0xFF8E9CC4));

    // Rolling hills
    canvas.drawPath(_hill(w, horizon, h * 0.04, 0.012, 1.0, horizon + 30),
        Paint()..color = const Color(0xFF8FB872));
    canvas.drawPath(_hill(w, horizon + h * 0.02, h * 0.03, 0.018, 3.0, horizon + 40),
        Paint()..color = const Color(0xFF6FA35A));

    // Ground
    final groundRect = Rect.fromLTWH(0, horizon + h * 0.03, w, h - horizon);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = Gradient.linear(groundRect.topLeft, groundRect.bottomLeft,
            const [AppColors.grass, AppColors.grassDark]),
    );

    // Flowers and grass tufts
    final tuft = Paint()
      ..color = AppColors.grassDark
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const bloomColors = [Color(0xFFFFFFFF), Color(0xFFF48FB1), Color(0xFFFFEB3B), Color(0xFFFF9800)];
    for (final s in _spots) {
      final p = Offset(s.x * w, s.y * h);
      if (p.dy < horizon + h * 0.05) continue;
      if (s.kind == 0) {
        canvas.drawLine(p, p.translate(-3, -6), tuft);
        canvas.drawLine(p, p.translate(0, -8), tuft);
        canvas.drawLine(p, p.translate(3, -6), tuft);
      } else {
        canvas.drawCircle(p, 2.6, Paint()..color = bloomColors[s.kind]);
        canvas.drawCircle(p, 1.0, Paint()..color = AppColors.brown);
      }
    }

    // Village
    final base = horizon + h * 0.065;
    drawHut(canvas, Rect.fromLTWH(w * 0.03, base - w * 0.2, w * 0.28, w * 0.2));
    drawTree(canvas, Offset(w * 0.40, base), h * 0.11);
    drawHaystack(canvas, Offset(w * 0.54, base), w * 0.12);
    drawPond(canvas, Offset(w * 0.71, base - 2), w * 0.2, h * 0.022, _t);
    drawTree(canvas, Offset(w * 0.92, base), h * 0.12);

    // Fence along the edge of the field
    final fy = base + h * 0.012;
    final wood = Paint()
      ..color = const Color(0xFF8D5A2B)
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(0, fy - 9), Offset(w, fy - 9), wood);
    canvas.drawLine(Offset(0, fy - 3), Offset(w, fy - 3), wood);
    for (double x = 4; x < w; x += w * 0.045) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, fy - 14, 4, 16), const Radius.circular(2)),
        Paint()..color = const Color(0xFF6D4326),
      );
    }

    // Bird
    final bx = (_t * 30) % (w + 60) - 30;
    drawBird(canvas, Offset(bx, h * 0.07 + math.sin(_t * 2) * 6), 8);

    // Folk-art border band at the top
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 9), Paint()..color = AppColors.maroon);
    final diamond = Paint()..color = AppColors.turmeric;
    for (double x = 8; x < w; x += 16) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 1.5)
          ..lineTo(x + 4, 4.5)
          ..lineTo(x, 7.5)
          ..lineTo(x - 4, 4.5)
          ..close(),
        diamond,
      );
    }
  }
}
