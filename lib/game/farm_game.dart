import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

import '../core/constants/app_colors.dart';
import 'components/plot_component.dart';
import 'components/scene_background.dart';
import 'game_state.dart';

class FarmGame extends FlameGame {
  FarmGame(this.state);

  final GameState state;

  static const int columns = 3;
  static const int rows = 2;

  final SceneBackground _scene = SceneBackground();
  final List<PlotComponent> _components = [];

  @override
  Color backgroundColor() => AppColors.grass;

  @override
  Future<void> onLoad() async {
    try {
      _scene.image = await images.load('background.jpg');
    } catch (_) {
      // Asset missing: the procedural scene is drawn instead.
    }
    add(_scene);
    for (final plot in state.plots) {
      final c = PlotComponent(plot: plot, game: state);
      _components.add(c);
      add(c);
    }
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_components.isNotEmpty) _layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    state.tick(math.min(dt, 0.5));
  }

  void _layout() {
    final double bottomReserved = (size.y * 0.32).clamp(170.0, 240.0);
    const double margin = 16;
    const double gap = 14;

    _scene.size = Vector2(size.x, size.y);
    _scene.updateLayout();

    final top = _scene.sceneBottom + 8;
    final availH = math.max(0.0, size.y - bottomReserved - top);
    final cellW0 = (size.x - margin * 2 - gap * (columns - 1)) / columns;
    final cellW = math.max(
        0.0, math.min(cellW0, (availH - gap * (rows - 1)) / rows / 0.85));
    final cellH = cellW * 0.85;

    final gridW = cellW * columns + gap * (columns - 1);
    final gridH = cellH * rows + gap * (rows - 1);
    final startX = (size.x - gridW) / 2;
    final startY = top + (availH - gridH) / 2;

    for (var i = 0; i < _components.length; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      _components[i]
        ..size = Vector2(cellW, cellH)
        ..position = Vector2(
          startX + col * (cellW + gap),
          startY + row * (cellH + gap),
        );
    }
  }
}
