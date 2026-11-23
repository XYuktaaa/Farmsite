import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../education/content.dart';
import '../game/farm_game.dart';
import '../game/game_state.dart';
import '../models/crop.dart';
import '../models/plot_state.dart';
import 'sheets.dart';
import 'widgets/narrator.dart';
import 'widgets/ornate.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key, required this.state});

  final GameState state;

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  late final FarmGame _game = FarmGame(widget.state);
  GameState get gs => widget.state;

  @override
  void initState() {
    super.initState();
    gs.onMessage = _toast;
    gs.onLesson = _lesson;
    gs.onScenario = _scenario;
    gs.onUnlock = _unlock;
    WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
  }

  void _welcome() {
    if (!mounted || gs.welcomed) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NarratorDialog(
        title: 'Namaste! Welcome to FarmSite',
        body: const Text(
          'I am Meena, and I will guide you through your first season. '
          'Tap a plot, prepare the soil, sow a seed and water it. Each time '
          'you try something new I will pop up with a short lesson, so you '
          'learn real farming as you play.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              gs.markWelcomed();
            },
            child: const Text('Let us begin'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gs.onMessage = null;
    gs.onLesson = null;
    gs.onScenario = null;
    gs.onUnlock = null;
    super.dispose();
  }

  // ---------- dialogs / toasts ----------
  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 250, left: 16, right: 16),
      ));
  }

  void _lesson(Lesson l) {
    if (!mounted) return;
    showLessonDialog(context, l, reward: true);
  }

  void _unlock(int id) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_open),
        title: const Text('Expand your farm?'),
        content: Text('Unlock this plot for ₹${GameState.plotUnlockCost}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              gs.unlockPlot(id);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _scenario(int plotId) {
    if (!mounted) return;
    final crop = crops[gs.plots[plotId].cropId];
    if (crop == null) return;
    String? result;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => NarratorDialog(
          title: '${crop.name} shows water stress',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result == null
                  ? 'Plot ${plotId + 1}: the leaves are drooping and the soil '
                      'looks dry. What will you do?'
                  : result!),
              if (result == null) ...[
                const SizedBox(height: 10),
                ...List.generate(
                  scenarioOptions.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final r = gs.resolveScenario(plotId, i);
                          setS(() => result = r);
                        },
                        child: Text(scenarioOptions[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (result != null)
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continue'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSeed() async {
    final p = gs.selected;
    if (p == null) return;
    if (gs.seeds.isEmpty) {
      _toast('You have no seeds. Open the Shop.');
      return;
    }
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: TitleBanner('Choose a seed'),
            ),
            for (final e in gs.seeds.entries)
              ListTile(
                leading: CircleAvatar(backgroundColor: Color(crops[e.key]!.color)),
                title: Text('${crops[e.key]!.name} x${e.value}'),
                subtitle: Text('${crops[e.key]!.season.label} season'),
                onTap: () => Navigator.pop(ctx, e.key),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (id != null) gs.sow(p.id, id);
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grass,
      body: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 480),
    child: SizedBox.expand(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),
            Positioned(top: 0, left: 0, right: 0, child: _hud()),
            Positioned(bottom: 0, left: 0, right: 0, child: _bottomPanel()),
          ],
        ),
      ),
    ),
  ),
),
    );
  }

  Widget _hud() {
    return ListenableBuilder(
      listenable: gs,
      builder: (c, w) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      right: 0,
                      top: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.only(left: 32, right: 12),
                        decoration: folkPill(radius: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${gs.level} · XP ${gs.xp % 100}/100',
                              style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: gs.levelProgress, minHeight: 7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(left: 0, top: 0, child: FarmerAvatar(size: 54)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: folkPill(radius: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RupeeCoin(size: 26),
                  const SizedBox(width: 6),
                  Text(
                    '${gs.coins}',
                    style: const TextStyle(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _status(PlotState? p) {
    if (p == null) return 'Tap a plot to select it';
    final n = 'Plot ${p.id + 1}';
    switch (p.stage) {
      case PlotStage.empty:
        return '$n · Untilled. Prepare the soil';
      case PlotStage.prepared:
        return '$n · Soil ready. Sow a seed';
      case PlotStage.withered:
        return '$n · Crop withered. Till to restart';
      default:
        final c = crops[p.cropId]!;
        return '$n · ${c.name} (${c.season.label}) · ${p.stage.name}';
    }
  }

  Widget _stat(IconData icon, Color color, String label, double v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 3),
        Text(
          '$label ${(v * 100).round()}%',
          style: const TextStyle(
              color: AppColors.brown, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  /// Selected-plot info. The icon colours match the bars drawn on each plot:
  /// blue drop = water, green heart = health, gold = growth.
  Widget _statusPanel(PlotState? p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xEEFFF3D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.maroon, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _status(p),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.brown, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (p != null && p.stage != PlotStage.empty) ...[
            const SizedBox(height: 3),
            Wrap(
              spacing: 12,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: [
                _stat(Icons.water_drop, AppColors.moisture, 'Water', p.moisture),
                if (p.cropId != null &&
                    p.stage != PlotStage.prepared &&
                    p.stage != PlotStage.withered) ...[
                  _stat(Icons.favorite, AppColors.health, 'Health', p.health),
                  _stat(Icons.grass, AppColors.turmeric, 'Growth', p.progress),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bottomPanel() {
    return ListenableBuilder(
      listenable: gs,
      builder: (c, w) {
        final p = gs.selected;
        final stage = p?.stage;
        final inSoil = stage != null &&
            stage != PlotStage.empty &&
            stage != PlotStage.withered;
        final screenWidth = MediaQuery.sizeOf(context).width;
		final buttonSize = screenWidth < 350 ? 36.0 : 46.0;

        VoidCallback? act(bool ok, void Function(int) f) =>
            (ok && p != null) ? () => f(p.id) : null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusPanel(p),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: folkPill(radius: 36),
                child: Row(
                  children: [
                    const LotusIcon(size: 18),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.agriculture,
                            label: 'Till',
                            buttonSize: buttonSize,
                            onTap: act(
                                stage == PlotStage.empty || stage == PlotStage.withered,
                                gs.till),
                          ),
                          _ActionButton(
                            icon: Icons.grass,
                            label: 'Sow',
                            buttonSize: buttonSize,
                            onTap: act(stage == PlotStage.prepared, (_) => _pickSeed()),
                          ),
                          _ActionButton(
                            icon: Icons.water_drop,
                            label: 'Water',
                            buttonSize: buttonSize,
                            onTap: act(inSoil, gs.water),
                          ),
                          _ActionButton(
                            icon: Icons.science,
                            label: 'Fertilize',
                            buttonSize: buttonSize,
                            onTap: act(
                                stage == PlotStage.sown || stage == PlotStage.growing,
                                gs.fertilize),
                          ),
                          _ActionButton(
                            icon: Icons.shopping_basket,
                            label: 'Harvest',
                            buttonSize: buttonSize,
                            onTap: act(stage == PlotStage.mature, gs.harvest),
                          ),
                        ],
                      ),
                    ),
                    const LotusIcon(size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FolkNavBar(
              children: [
                NavItem(icon: Icons.store, label: 'Shop', onTap: () => showShop(context, gs)),
                NavItem(icon: Icons.inventory_2, label: 'Barn', onTap: () => showBarn(context, gs)),
                NavItem(icon: Icons.eco, label: 'Farm', highlight: true, onTap: () {}),
                NavItem(icon: Icons.menu_book, label: 'Learn', onTap: () => showLearn(context, gs)),
                NavItem(icon: Icons.person, label: 'Profile', onTap: () => showProfile(context, gs)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.buttonSize = 46,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                      colors: [Color(0xFFFFF8E1), Color(0xFFF0CD7E)]),
                  border: Border.all(color: AppColors.turmeric, width: 3),
                ),
                child: Icon(icon, color: AppColors.maroon, size: 24),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.brown, fontSize: 10.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
