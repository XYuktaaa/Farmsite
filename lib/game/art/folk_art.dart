import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_colors.dart';

/// Dots placed along a rounded-rect outline (rangoli-style border).
void drawDottedBorder(Canvas canvas, RRect rrect, Color color,
    {double dotRadius = 2.2, double spacing = 9}) {
  final paint = Paint()..color = color;
  final path = Path()..addRRect(rrect);
  for (final metric in path.computeMetrics()) {
    for (double d = 0; d < metric.length; d += spacing) {
      final t = metric.getTangentForOffset(d);
      if (t != null) canvas.drawCircle(t.position, dotRadius, paint);
    }
  }
}

void drawLotus(Canvas canvas, Offset c, double r,
    {Color petal = const Color(0xFFF48FB1), Color tip = const Color(0xFFD81B60)}) {
  final fill = Paint()..color = petal;
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(0.8, r * 0.07)
    ..color = tip;
  for (final a in [-0.9, 0.9, -0.45, 0.45, 0.0]) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(a);
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-r * 0.38, -r * 0.5, 0, -r)
      ..quadraticBezierTo(r * 0.38, -r * 0.5, 0, 0);
    canvas.drawPath(p, fill);
    canvas.drawPath(p, edge);
    canvas.restore();
  }
}

void drawSun(Canvas canvas, Offset c, double r, double t) {
  final rays = Paint();
  const n = 16;
  for (var i = 0; i < n; i++) {
    final a = t * 0.15 + i * 2 * math.pi / n;
    rays.color = i.isEven ? AppColors.saffron : AppColors.turmeric;
    final p = Path()
      ..moveTo(c.dx + math.cos(a - 0.11) * r * 1.05,
          c.dy + math.sin(a - 0.11) * r * 1.05)
      ..lineTo(c.dx + math.cos(a) * r * 1.7, c.dy + math.sin(a) * r * 1.7)
      ..lineTo(c.dx + math.cos(a + 0.11) * r * 1.05,
          c.dy + math.sin(a + 0.11) * r * 1.05)
      ..close();
    canvas.drawPath(p, rays);
  }
  canvas.drawCircle(c, r * 1.08, Paint()..color = AppColors.saffron);
  canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFD54A));
  final dark = Paint()..color = AppColors.brown;
  canvas.drawCircle(c.translate(-r * 0.33, -r * 0.15), r * 0.09, dark);
  canvas.drawCircle(c.translate(r * 0.33, -r * 0.15), r * 0.09, dark);
  canvas.drawArc(
    Rect.fromCenter(center: c.translate(0, r * 0.15), width: r * 0.7, height: r * 0.5),
    0.2,
    math.pi - 0.4,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..color = AppColors.brown,
  );
  final cheek = Paint()..color = const Color(0x66E57373);
  canvas.drawCircle(c.translate(-r * 0.55, r * 0.15), r * 0.13, cheek);
  canvas.drawCircle(c.translate(r * 0.55, r * 0.15), r * 0.13, cheek);
}

void drawTree(Canvas canvas, Offset base, double h) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(base.dx - h * 0.06, base.dy - h * 0.5, h * 0.12, h * 0.5),
      Radius.circular(h * 0.03),
    ),
    Paint()..color = const Color(0xFF6D4326),
  );
  final cy = base.dy - h * 0.68;
  canvas.drawCircle(Offset(base.dx - h * 0.22, cy + h * 0.06), h * 0.26,
      Paint()..color = AppColors.leafDark);
  canvas.drawCircle(Offset(base.dx + h * 0.22, cy + h * 0.06), h * 0.26,
      Paint()..color = AppColors.leafDark);
  canvas.drawCircle(
      Offset(base.dx, cy - h * 0.05), h * 0.32, Paint()..color = AppColors.leaf);
  canvas.drawCircle(Offset(base.dx - h * 0.08, cy - h * 0.12), h * 0.16,
      Paint()..color = const Color(0xFF6FB04A));
  final fruit = Paint()..color = const Color(0xFFE53935);
  final bloom = Paint()..color = AppColors.cream;
  for (var i = 0; i < 8; i++) {
    final a = i * 0.9;
    final rr = h * (0.12 + 0.05 * (i % 3));
    canvas.drawCircle(
      Offset(base.dx + math.cos(a) * rr * 1.6, cy + math.sin(a) * rr * 1.2),
      h * 0.03,
      i.isEven ? fruit : bloom,
    );
  }
}

/// Village hut with a thatched roof and a painted terracotta band.
void drawHut(Canvas canvas, Rect r) {
  final wallTop = r.top + r.height * 0.42;
  final wall = Rect.fromLTRB(
      r.left + r.width * 0.08, wallTop, r.right - r.width * 0.08, r.bottom);
  canvas.drawRect(wall, Paint()..color = const Color(0xFFF6E7C8));
  final band = Rect.fromLTWH(
      wall.left, wall.top + wall.height * 0.12, wall.width, wall.height * 0.38);
  canvas.drawRect(band, Paint()..color = AppColors.terracotta);
  final dot = Paint()..color = AppColors.cream;
  for (var i = 0; i < 6; i++) {
    canvas.drawCircle(
        Offset(band.left + band.width * (0.1 + 0.16 * i), band.center.dy),
        band.height * 0.14,
        dot);
  }
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      Rect.fromLTWH(wall.center.dx - wall.width * 0.1,
          wall.bottom - wall.height * 0.45, wall.width * 0.2, wall.height * 0.45),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    ),
    Paint()..color = AppColors.deepMaroon,
  );
  final roofBottom = wallTop + 4;
  canvas.drawPath(
    Path()
      ..moveTo(r.left, roofBottom)
      ..lineTo(r.center.dx, r.top)
      ..lineTo(r.right, roofBottom)
      ..close(),
    Paint()..color = const Color(0xFFD9A13B),
  );
  final hatch = Paint()
    ..color = const Color(0xFFB97F22)
    ..strokeWidth = 2;
  for (var i = 1; i < 7; i++) {
    final f = i / 7;
    final y = r.top + (roofBottom - r.top) * f;
    final hw = (r.width / 2) * f;
    canvas.drawLine(Offset(r.center.dx - hw, y), Offset(r.center.dx + hw, y), hatch);
  }
}

void drawHaystack(Canvas canvas, Offset base, double w) {
  final path = Path()
    ..moveTo(base.dx - w / 2, base.dy)
    ..quadraticBezierTo(base.dx - w * 0.45, base.dy - w * 0.8, base.dx, base.dy - w * 0.85)
    ..quadraticBezierTo(base.dx + w * 0.45, base.dy - w * 0.8, base.dx + w / 2, base.dy)
    ..close();
  canvas.drawPath(path, Paint()..color = const Color(0xFFE6B84A));
  final line = Paint()
    ..color = const Color(0xFFB98A24)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  for (var i = 1; i < 5; i++) {
    final y = base.dy - w * 0.17 * i;
    canvas.drawLine(Offset(base.dx - w * (0.42 - 0.07 * i), y),
        Offset(base.dx + w * (0.42 - 0.07 * i), y), line);
  }
}

void drawBird(Canvas canvas, Offset c, double s) {
  final p = Path()
    ..moveTo(c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx - s / 2, c.dy - s * 0.7, c.dx, c.dy)
    ..quadraticBezierTo(c.dx + s / 2, c.dy - s * 0.7, c.dx + s, c.dy);
  canvas.drawPath(
    p,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFFFFF),
  );
}

void drawPond(Canvas canvas, Offset c, double w, double h, double t) {
  canvas.drawOval(Rect.fromCenter(center: c, width: w + 6, height: h + 4),
      Paint()..color = const Color(0xFF3E8E4A));
  canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h),
      Paint()..color = const Color(0xFF4FB3D9));
  final k = 0.55 + 0.25 * math.sin(t * 1.5);
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w * k, height: h * k),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x88FFFFFF),
  );
  canvas.drawOval(Rect.fromCenter(center: c.translate(-w * 0.2, 0), width: w * 0.16, height: h * 0.5),
      Paint()..color = AppColors.leaf);
  drawLotus(canvas, c.translate(-w * 0.2, -h * 0.05), h * 0.55);
  drawLotus(canvas, c.translate(w * 0.18, h * 0.05), h * 0.45,
      petal: const Color(0xFFFFFFFF), tip: const Color(0xFFF48FB1));
}
