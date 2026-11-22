import 'dart:ui';

import 'package:flame/game.dart';

import '../core/constants/app_colors.dart';
import 'components/smoke_test_plot.dart';

class FarmGame extends FlameGame {
  @override
  Color backgroundColor() => AppColors.grass;

  @override
  Future<void> onLoad() async {
    add(SmokeTestPlot(position: size / 2));
  }
}
