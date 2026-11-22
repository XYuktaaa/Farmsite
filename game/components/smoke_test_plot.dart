import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
// import 'package:flame/game.dart';

import '../../core/constants/app_colors.dart';

/// Temporary component that proves rendering and tap input work.
/// It will be replaced by the real plot component in Phase 2.
class SmokeTestPlot extends RectangleComponent with TapCallbacks {
  SmokeTestPlot({required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(120),
        anchor: Anchor.center,
        paint: Paint()..color = AppColors.soilDry,
      );

  bool _wet = false;

  @override
  void onTapDown(TapDownEvent event) {
    _wet = !_wet;
    paint.color = _wet ? AppColors.soilWet : AppColors.soilDry;
  }
}
