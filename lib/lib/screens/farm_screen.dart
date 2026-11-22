import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_colors.dart';
import '../education/content.dart';
import '../game/farm_game.dart';
import '../game/game_state.dart';
import '../models/crop.dart';
import '../models/plot_state.dart';
import 'sheets.dart';

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
      ..showSnackBar(
        SnackBar(
          content: Text(m),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 200, left: 16, right: 16),
        ),
      );
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
        content: Text(
          'Unlock this plot for ${GameState.plotUnlockCost} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
        builder: (ctx, setS) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          title: Text('${crop.name} shows water stress'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plot ${plotId + 1}: leaves are drooping and the soil '
                  'looks dry. What do you do?',
                ),
                const SizedBox(height: 12),
                if (result == null)
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
                  )
                else
                  Text(result!),
              ],
            ),
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
            const ListTile(title: Text('Choose a seed to sow')),
            for (final e in gs.seeds.entries)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(crops[e.key]!.color),
                ),
                title: Text('${crops[e.key]!.name} x${e.value}'),
                subtitle: Text('${crops[e.key]!.season.label} season'),
                onTap: () => Navigator.pop(ctx, e.key),
              ),
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),
            Positioned(top: 0, left: 0, right: 0, child: _hud()),
            Positioned(bottom: 0, left: 0, right: 0, child: _bottomPanel()),
          ],
        ),
      ),
    );
  }

  Widget _hud() {
    const white = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    return ListenableBuilder(
      listenable: gs,
      builder: (c, w) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepOrange,
              child: Text('${gs.level}', style: white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${gs.level} · XP ${gs.xp % 100}/100',
                    style: white,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: gs.levelProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.wood,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${gs.coins}', style: white),
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
        return '$n · ${c.name} (${c.season.label}) · ${p.stage.name} '
            '${(p.progress * 100).round()}% · health ${(p.health * 100).round()}%';
    }
  }

  Widget _bottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.wood,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: ListenableBuilder(
        listenable: gs,
        builder: (c, w) {
          final p = gs.selected;
          final stage = p?.stage;
          final inSoil =
              stage != null &&
              stage != PlotStage.empty &&
              stage != PlotStage.withered;

          VoidCallback? act(bool ok, void Function(int) f) =>
              (ok && p != null) ? () => f(p.id) : null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _status(p),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.agriculture,
                    label: 'Till',
                    onTap: act(
                      stage == PlotStage.empty || stage == PlotStage.withered,
                      gs.till,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.grass,
                    label: 'Sow',
                    onTap: act(stage == PlotStage.prepared, (_) => _pickSeed()),
                  ),
                  _ActionButton(
                    icon: Icons.water_drop,
                    label: 'Water',
                    onTap: act(inSoil, gs.water),
                  ),
                  _ActionButton(
                    icon: Icons.science,
                    label: 'Fertilize',
                    onTap: act(
                      stage == PlotStage.sown || stage == PlotStage.growing,
                      gs.fertilize,
                    ),
                  ),
                  _ActionButton(
                    icon: Icons.shopping_basket,
                    label: 'Harvest',
                    onTap: act(stage == PlotStage.mature, gs.harvest),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavButton(Icons.store, 'Shop', () => showShop(context, gs)),
                  _NavButton(
                    Icons.inventory_2,
                    'Barn',
                    () => showBarn(context, gs),
                  ),
                  _NavButton(
                    Icons.school,
                    'Learn',
                    () => showLearn(context, gs),
                  ),
                  _NavButton(
                    Icons.person,
                    'Profile',
                    () => showProfile(context, gs),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.grass,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amber[200]),
            Text(
              label,
              style: TextStyle(color: Colors.amber[200], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
