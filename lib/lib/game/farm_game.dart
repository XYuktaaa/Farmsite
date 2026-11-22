import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

import '../core/constants/app_colors.dart';
import 'components/plot_component.dart';
import 'game_state.dart';

class FarmGame extends FlameGame {
  FarmGame(this.state);

  final GameState state;

  static const int columns = 2;
  static const int rows = 3;

  final List<PlotComponent> _components = [];

  @override
  Color backgroundColor() => AppColors.grass;

  @override
  Future<void> onLoad() async {
    for (final plot in state.plots) {
      final c = PlotComponent(plot: plot, game: state);
      _components.add(c);
      add(c);
    }
    _layoutPlots();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_components.isNotEmpty) _layoutPlots();
  }

  @override
  void update(double dt) {
    super.update(dt);
    state.tick(math.min(dt, 0.5));
  }

  void _layoutPlots() {
    const double topReserved = 70;
    const double bottomReserved = 200;
    const double margin = 24;
    const double gap = 16;

    final availableW = size.x - margin * 2;
    final availableH = size.y - topReserved - bottomReserved;

    final cellW = (availableW - gap * (columns - 1)) / columns;
    final cellH = (availableH - gap * (rows - 1)) / rows;
    final cell = math.max(0.0, math.min(cellW, cellH));

    final gridW = cell * columns + gap * (columns - 1);
    final gridH = cell * rows + gap * (rows - 1);
    final startX = (size.x - gridW) / 2;
    final startY = topReserved + (availableH - gridH) / 2;

    for (var i = 0; i < _components.length; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      _components[i]
        ..size = Vector2.all(cell)
        ..position = Vector2(
          startX + col * (cell + gap),
          startY + row * (cell + gap),
        );
    }
  }
}
