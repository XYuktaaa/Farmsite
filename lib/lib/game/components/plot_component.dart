import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';
import '../../models/plot_state.dart';
import '../game_state.dart';

/// Draws one plot from its [PlotState]. Reads state every frame,
/// so game logic changes show up automatically.
class PlotComponent extends PositionComponent with TapCallbacks {
  PlotComponent({required this.plot, required this.game})
    : super(size: Vector2.zero());

  final PlotState plot;
  final GameState game;

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(12),
    );

    if (!plot.unlocked) {
      _renderLocked(canvas, rrect, w, h);
      return;
    }

    final soil = plot.stage == PlotStage.empty
        ? AppColors.untilled
        : Color.lerp(AppColors.soilDry, AppColors.soilWet, plot.moisture)!;
    canvas.drawRRect(rrect, Paint()..color = soil);

    if (plot.stage != PlotStage.empty) {
      final furrow = Paint()
        ..color = const Color(0x33000000)
        ..strokeWidth = 3;
      for (final f in [0.3, 0.5, 0.7]) {
        canvas.drawLine(
          Offset(w * 0.08, h * f),
          Offset(w * 0.92, h * f),
          furrow,
        );
      }
      _renderCrop(canvas, w, h);
      _renderBars(canvas, w, h);
    }

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.plotBorder,
    );

    if (game.selectedId == plot.id) {
      canvas.drawRRect(
        rrect.deflate(2.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = AppColors.selection,
      );
    }
  }

  void _renderLocked(Canvas canvas, RRect rrect, double w, double h) {
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF9E9E9E));
    final dark = Paint()..color = const Color(0xFF616161);
    final c = Offset(w / 2, h / 2);
    final s = w * 0.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c.translate(0, s * 0.4),
          width: s * 1.6,
          height: s * 1.3,
        ),
        const Radius.circular(4),
      ),
      dark,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: c.translate(0, -s * 0.2),
        width: s,
        height: s * 1.2,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFF616161),
    );
  }

  void _renderCrop(Canvas canvas, double w, double h) {
    final crop = crops[plot.cropId];
    if (crop == null) return;

    if (plot.stage == PlotStage.sown) {
      final seed = Paint()..color = const Color(0xFFC5E1A5);
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          canvas.drawCircle(
            Offset(w * (0.25 + 0.25 * c), h * (0.3 + 0.2 * r)),
            w * 0.025,
            seed,
          );
        }
      }
      return;
    }

    final withered = plot.stage == PlotStage.withered;
    final stemColor = withered
        ? const Color(0xFFBCAAA4)
        : Color.lerp(
            const Color(0xFFD7CCA0),
            const Color(0xFF2E7D32),
            plot.health,
          )!;
    final stem = Paint()
      ..color = stemColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final head = Paint()..color = Color(crop.color);

    final grow = withered ? 0.4 : plot.progress;
    final stemH = h * 0.05 + grow * h * 0.13;
    final lean = withered ? w * 0.03 : 0.0;

    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final x = w * (0.25 + 0.25 * c);
        final baseY = h * (0.34 + 0.2 * r);
        final top = Offset(x + lean, baseY - stemH);
        canvas.drawLine(Offset(x, baseY), top, stem);
        if (plot.stage == PlotStage.mature) {
          canvas.drawCircle(top, w * 0.04, head);
        }
      }
    }
  }

  void _renderBars(Canvas canvas, double w, double h) {
    final track = Paint()..color = const Color(0x55000000);
    final x = w * 0.1;
    final bw = w * 0.8;

    void bar(double y, double v, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, bw, 5),
          const Radius.circular(3),
        ),
        track,
      );
      if (v > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, bw * v, 5),
            const Radius.circular(3),
          ),
          Paint()..color = c,
        );
      }
    }

    bar(h - 14, plot.moisture, AppColors.moisture);
    if (plot.cropId != null && plot.stage != PlotStage.withered) {
      bar(h - 7, plot.health, AppColors.health);
    }
  }

  @override
  void onTapDown(TapDownEvent event) => game.select(plot.id);
}
