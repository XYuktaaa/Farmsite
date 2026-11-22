import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';
import '../../models/plot_state.dart';
import '../art/folk_art.dart';
import '../game_state.dart';

/// Draws one plot from its [PlotState]. Reads state every frame,
/// so game logic changes show up automatically.
class PlotComponent extends PositionComponent with TapCallbacks {
  PlotComponent({required this.plot, required this.game})
      : super(size: Vector2.zero());

  final PlotState plot;
  final GameState game;

  static final TextPaint _pillText = TextPaint(
    style: const TextStyle(
        color: AppColors.brown, fontSize: 11, fontWeight: FontWeight.bold),
  );
  static final TextPaint _lockText = TextPaint(
    style: const TextStyle(
        color: AppColors.cream, fontSize: 12, fontWeight: FontWeight.bold),
  );

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;
    final outer = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(14));

    if (!plot.unlocked) {
      _renderLocked(canvas, outer, w, h);
      return;
    }

    // Rangoli-style frame
    canvas.drawRRect(outer, Paint()..color = AppColors.plotBorder);
    drawDottedBorder(canvas, outer.deflate(5.5), AppColors.cream);
    final inner = outer.deflate(11);
    final ir = inner.outerRect;

    final soil = plot.stage == PlotStage.empty
        ? AppColors.untilled
        : Color.lerp(AppColors.soilDry, AppColors.soilWet, plot.moisture)!;
    canvas.drawRRect(inner, Paint()..color = soil);

    canvas.save();
    canvas.clipRRect(inner);
    if (plot.stage == PlotStage.empty) {
      final speck = Paint()..color = const Color(0x33000000);
      for (var i = 0; i < 14; i++) {
        final fx = ((i * 37 + plot.id * 11) % 100) / 100;
        final fy = ((i * 53 + plot.id * 7) % 100) / 100;
        canvas.drawCircle(
            Offset(ir.left + ir.width * fx, ir.top + ir.height * fy), 2, speck);
      }
    } else {
      final dark = Paint()
        ..color = const Color(0x40000000)
        ..strokeWidth = 2.5;
      final light = Paint()
        ..color = const Color(0x22FFFFFF)
        ..strokeWidth = 2;
      for (var i = 1; i <= 3; i++) {
        final y = ir.top + ir.height * (i / 4);
        canvas.drawLine(Offset(ir.left, y), Offset(ir.right, y), dark);
        canvas.drawLine(Offset(ir.left, y + 2.5), Offset(ir.right, y + 2.5), light);
      }
    }
    canvas.restore();

    _renderCrops(canvas, ir);
    if (plot.stage != PlotStage.empty) _renderBars(canvas, w, h);
    _renderPill(canvas, w);

    if (game.selectedId == plot.id) {
      canvas.drawRRect(
        outer.inflate(2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = AppColors.selection
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawRRect(
        outer.inflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.selection,
      );
    }
  }

  void _renderLocked(Canvas canvas, RRect outer, double w, double h) {
    canvas.drawRRect(outer, Paint()..color = AppColors.plotBorder);
    drawDottedBorder(canvas, outer.deflate(5.5), AppColors.cream);
    canvas.drawRRect(outer.deflate(11), Paint()..color = const Color(0xFF6B4630));

    final c = Offset(w / 2, h * 0.45);
    final s = math.min(w, h) * 0.2;
    final cream = Paint()..color = AppColors.cream;
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, -s * 0.35), width: s * 1.1, height: s * 1.4),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.cream,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, s * 0.3), width: s * 1.7, height: s * 1.3),
        const Radius.circular(5),
      ),
      cream,
    );
    canvas.drawCircle(c.translate(0, s * 0.25), s * 0.18, Paint()..color = AppColors.brown);
    _lockText.render(canvas, '₹${GameState.plotUnlockCost}', Vector2(w / 2, h * 0.78),
        anchor: Anchor.center);
  }

  void _renderCrops(Canvas canvas, Rect ir) {
    final crop = crops[plot.cropId];
    if (crop == null) return;
    final maxH = ir.height * 0.5;

    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 3; c++) {
        final base = Offset(
          ir.left + ir.width * (0.2 + 0.3 * c),
          ir.top + ir.height * (0.48 + 0.32 * r),
        );
        if (plot.stage == PlotStage.sown) {
          final seed = Paint()..color = const Color(0xFFF2C14E);
          for (final o in const [Offset(-4, 0), Offset(3, 2), Offset(0, -3)]) {
            canvas.drawOval(Rect.fromCenter(center: base + o, width: 5, height: 3.2), seed);
          }
        } else {
          _plant(canvas, crop, base, maxH);
        }
      }
    }
  }

  void _plant(Canvas canvas, Crop crop, Offset base, double maxH) {
    final withered = plot.stage == PlotStage.withered;
    final mature = plot.stage == PlotStage.mature;
    final grow = withered ? 0.35 : plot.progress;
    final hgt = maxH * (0.3 + 0.7 * grow);
    final lean = withered ? hgt * 0.25 : 0.0;
    final top = Offset(base.dx + lean, base.dy - hgt);
    final green = withered
        ? const Color(0xFFBCAAA4)
        : Color.lerp(const Color(0xFFBDB45C), const Color(0xFF3D9A2B), plot.health)!;
    final stem = Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, maxH * 0.07)
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = green;
    final grain = Color(crop.color);

    void blade(Offset from, Offset to, double bend) {
      final mid = Offset((from.dx + to.dx) / 2 + bend, (from.dy + to.dy) / 2);
      final p = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(mid.dx, mid.dy - 2, to.dx, to.dy)
        ..quadraticBezierTo(mid.dx + bend * 0.3, mid.dy + 3, from.dx, from.dy);
      canvas.drawPath(p, leaf);
    }

    switch (crop.id) {
      case 'wheat':
        canvas.drawLine(base, top, stem);
        blade(Offset(base.dx, base.dy - hgt * 0.25),
            Offset(base.dx - hgt * 0.35, base.dy - hgt * 0.6), -hgt * 0.1);
        blade(Offset(base.dx, base.dy - hgt * 0.4),
            Offset(base.dx + hgt * 0.35, base.dy - hgt * 0.75), hgt * 0.1);
        if (grow > 0.45) {
          final c = mature ? grain : Color.lerp(green, grain, 0.5)!;
          final gp = Paint()..color = c;
          final earH = hgt * 0.4;
          for (var i = 0; i < 4; i++) {
            final y = top.dy + earH * (i / 3);
            canvas.drawOval(
                Rect.fromCenter(center: Offset(top.dx - hgt * 0.06, y), width: hgt * 0.12, height: hgt * 0.17),
                gp);
            canvas.drawOval(
                Rect.fromCenter(center: Offset(top.dx + hgt * 0.06, y + hgt * 0.05), width: hgt * 0.12, height: hgt * 0.17),
                gp);
          }
        }
      case 'rice':
        for (final a in const [-1.0, 0.0, 1.0]) {
          final to = Offset(top.dx + a * hgt * 0.28, top.dy + (a == 0 ? 0 : hgt * 0.15));
          blade(base, to, a * hgt * 0.12);
        }
        if (grow > 0.55) {
          final gp = Paint()..color = mature ? grain : Color.lerp(green, grain, 0.5)!;
          for (var i = 0; i < 5; i++) {
            final t = i / 4;
            canvas.drawCircle(
                Offset(top.dx + hgt * 0.32 * t, top.dy + hgt * 0.1 + hgt * 0.3 * t * t),
                hgt * 0.05,
                gp);
          }
        }
      case 'maize':
        canvas.drawLine(
            base,
            top,
            Paint()
              ..color = green
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(2.4, maxH * 0.1)
              ..strokeCap = StrokeCap.round);
        for (final s in const [-1.0, 1.0]) {
          for (final lv in const [0.3, 0.55]) {
            blade(Offset(base.dx, base.dy - hgt * lv),
                Offset(base.dx + s * hgt * 0.5, base.dy - hgt * (lv + 0.15)), s * hgt * 0.1);
          }
        }
        if (grow > 0.6) {
          final cob = mature ? grain : Color.lerp(green, grain, 0.4)!;
          final cp = Offset(base.dx + hgt * 0.13, base.dy - hgt * 0.5);
          canvas.drawOval(Rect.fromCenter(center: cp, width: hgt * 0.15, height: hgt * 0.3),
              Paint()..color = cob);
          blade(cp.translate(0, hgt * 0.1), cp.translate(hgt * 0.15, -hgt * 0.12), hgt * 0.05);
        }
    }
  }

  void _drop(Canvas canvas, Offset o, double r, Color color) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r)
      ..cubicTo(o.dx + r * 1.1, o.dy, o.dx + r * 0.9, o.dy + r, o.dx, o.dy + r)
      ..cubicTo(o.dx - r * 0.9, o.dy + r, o.dx - r * 1.1, o.dy, o.dx, o.dy - r);
    canvas.drawPath(p, Paint()..color = color);
  }

  void _heart(Canvas canvas, Offset o, double r, Color color) {
    final p = Path()
      ..moveTo(o.dx, o.dy + r)
      ..cubicTo(o.dx - r * 1.6, o.dy - r * 0.2, o.dx - r * 0.9, o.dy - r * 1.2, o.dx, o.dy - r * 0.4)
      ..cubicTo(o.dx + r * 0.9, o.dy - r * 1.2, o.dx + r * 1.6, o.dy - r * 0.2, o.dx, o.dy + r);
    canvas.drawPath(p, Paint()..color = color);
  }

  /// Blue bar + drop icon = soil water. Green bar + heart icon = crop health.
  /// The gold pill on top is the growth timer.
  void _renderBars(Canvas canvas, double w, double h) {
    final track = Paint()..color = const Color(0x77000000);
    final x = w * 0.28;
    final bw = w * 0.56;

    void bar(double y, double v, Color c) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw, 5), const Radius.circular(3)), track);
      if (v > 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bw * v, 5), const Radius.circular(3)),
            Paint()..color = c);
      }
    }

    bar(h - 23, plot.moisture, AppColors.moisture);
    _drop(canvas, Offset(x - 9, h - 20.5), 3.6, AppColors.moisture);
    if (plot.cropId != null && plot.stage != PlotStage.withered) {
      bar(h - 16.5, plot.health, AppColors.health);
      _heart(canvas, Offset(x - 9, h - 14), 3.2, AppColors.health);
    }
  }

  void _renderPill(Canvas canvas, double w) {
    final crop = crops[plot.cropId];
    String label;
    double fill;
    Color color = AppColors.turmeric;
    switch (plot.stage) {
      case PlotStage.sown:
      case PlotStage.growing:
        label = 'Grow ${((1 - plot.progress) * (crop?.growSeconds ?? 0)).ceil()}s';
        fill = plot.progress;
      case PlotStage.mature:
        label = 'Ready!';
        fill = 1;
        color = const Color(0xFF9CCC65);
      case PlotStage.withered:
        label = 'Withered';
        fill = 0;
      default:
        return;
    }
    final rect = Rect.fromCenter(
        center: Offset(w / 2, 3), width: math.min(w * 0.64, 68), height: 18);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    canvas.drawRRect(rr, Paint()..color = AppColors.cream);
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width * fill, rect.height),
        Paint()..color = color);
    canvas.restore();
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.maroon,
    );
    _pillText.render(canvas, label, Vector2(rect.center.dx, rect.center.dy),
        anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) => game.select(plot.id);
}
