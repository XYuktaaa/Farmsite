import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../education/content.dart';
import '../models/crop.dart';
import '../models/plot_state.dart';

double _clamp01(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);

class Achievement {
  const Achievement(this.title, this.description, this.done);
  final String title;
  final String description;
  final bool done;
}

/// All game rules and player data. No drawing code lives here.
///
/// Simplified simulation rules (documented, not real agronomy):
///  * Soil moisture (0..1) drops over time at a crop-specific rate.
///  * Outside the crop's [minMoisture, maxMoisture] range, health falls and
///    growth slows to 30%. Inside it, health slowly recovers.
///  * Fertilizer multiplies growth speed by 1.3.
///  * Harvest yield = 1 + round(health * 3).
class GameState extends ChangeNotifier {
  static const _saveKey = 'farmsite_save_v1';
  static const plotUnlockCost = 100;

  SharedPreferences? _prefs;

  int coins = 100;
  int xp = 0;
  int fertilizer = 1;
  final Map<String, int> seeds = {'wheat': 2};
  final Map<String, int> produce = {};
  final Map<String, int> harvested = {};
  final Set<String> lessonsSeen = {};
  final Set<String> quizzesDone = {};
  final List<PlotState> plots =
      List.generate(6, (i) => PlotState(id: i, unlocked: i < 4));
  int? selectedId;
  bool welcomed = false;

  // UI hooks, set by the screen.
  void Function(String message)? onMessage;
  void Function(Lesson lesson)? onLesson;
  void Function(int plotId)? onScenario;
  void Function(int plotId)? onUnlock;

  int get level => 1 + xp ~/ 100;
  double get levelProgress => (xp % 100) / 100;
  PlotState? get selected => selectedId == null ? null : plots[selectedId!];

  List<Achievement> get achievements => [
        Achievement('First Harvest', 'Harvest any crop',
            harvested.values.fold(0, (a, b) => a + b) > 0),
        Achievement('Crop Collector', 'Harvest wheat, rice and maize',
            harvested.keys.length >= 3),
        Achievement('Student Farmer', 'Answer 3 quiz questions correctly',
            quizzesDone.length >= 3),
        Achievement('Landowner', 'Unlock all 6 plots',
            plots.every((p) => p.unlocked)),
        Achievement('Seasoned Farmer', 'Reach level 5', level >= 5),
      ];

  // ---------- time ----------
  double _sinceNotify = 0;
  double _sinceSave = 0;

  void tick(double dt) {
    for (final p in plots) {
      if (!p.unlocked) continue;
      if (p.stage == PlotStage.empty || p.stage == PlotStage.withered) continue;

      final crop = crops[p.cropId];
      p.moisture = _clamp01(p.moisture - dt * (crop?.dryRate ?? 0.008));
      if (crop == null || p.stage == PlotStage.mature) continue;

      final dry = p.moisture < crop.minMoisture;
      final wet = p.moisture > crop.maxMoisture;
      p.health = _clamp01(p.health + dt * ((dry || wet) ? -0.025 : 0.01));

      if (p.health <= 0) {
        p.stage = PlotStage.withered;
        _say('The crop on plot ${p.id + 1} withered. Till the plot to restart.');
        continue;
      }

      final rate = ((dry || wet) ? 0.3 : 1.0) * (p.fertilized ? 1.3 : 1.0);
      p.progress += dt / crop.growSeconds * rate;
      if (p.progress >= 1) {
        p.progress = 1;
        p.stage = PlotStage.mature;
        _say('${crop.name} on plot ${p.id + 1} is ready to harvest!');
      } else {
        p.stage = p.progress < 0.2 ? PlotStage.sown : PlotStage.growing;
      }

      if (dry && !p.scenarioShown && onScenario != null) {
        p.scenarioShown = true;
        onScenario?.call(p.id);
      }
    }

    _sinceNotify += dt;
    _sinceSave += dt;
    if (_sinceNotify >= 0.5) {
      _sinceNotify = 0;
      notifyListeners();
    }
    if (_sinceSave >= 5) {
      _sinceSave = 0;
      _save();
    }
  }

  // ---------- helpers ----------
  void _say(String m) => onMessage?.call(m);

  void _changed() {
    notifyListeners();
    _save();
  }

  void addXp(int n) {
    final before = level;
    xp += n;
    if (level > before) _say('Level up! You are now level $level.');
  }

  void _teach(String id) {
    if (lessonsSeen.add(id)) {
      addXp(5);
      final l = lessons[id];
      if (l != null) onLesson?.call(l);
    }
  }

  // ---------- plot actions ----------
  void select(int id) {
    if (!plots[id].unlocked) {
      onUnlock?.call(id);
      return;
    }
    selectedId = id;
    notifyListeners();
  }

  void unlockPlot(int id) {
    if (coins < plotUnlockCost) {
      _say('You need $plotUnlockCost coins to expand.');
      return;
    }
    coins -= plotUnlockCost;
    plots[id].unlocked = true;
    selectedId = id;
    _changed();
  }

  void till(int id) {
    final p = plots[id];
    if (p.stage != PlotStage.empty && p.stage != PlotStage.withered) {
      _say('This plot is already prepared.');
      return;
    }
    p
      ..stage = PlotStage.prepared
      ..cropId = null
      ..progress = 0
      ..health = 1
      ..moisture = 0.5
      ..fertilized = false
      ..scenarioShown = false;
    addXp(2);
    _teach('soil');
    _changed();
  }

  void sow(int id, String cropId) {
    final p = plots[id];
    if (p.stage != PlotStage.prepared) {
      _say('Prepare the soil first.');
      return;
    }
    final have = seeds[cropId] ?? 0;
    if (have <= 0) {
      _say('No seeds left. Visit the shop.');
      return;
    }
    if (have == 1) {
      seeds.remove(cropId);
    } else {
      seeds[cropId] = have - 1;
    }
    p
      ..cropId = cropId
      ..stage = PlotStage.sown
      ..progress = 0
      ..health = 1;
    addXp(3);
    _teach('seeds');
    _changed();
  }

  void water(int id) {
    final p = plots[id];
    if (p.stage == PlotStage.empty || p.stage == PlotStage.withered) {
      _say('Prepare the soil first.');
      return;
    }
    p.moisture = _clamp01(p.moisture + 0.4);
    final crop = crops[p.cropId];
    if (crop != null && p.moisture > crop.maxMoisture) {
      _say('Careful: too much water can harm ${crop.name}.');
    }
    _teach('water');
    _changed();
  }

  void fertilize(int id) {
    final p = plots[id];
    if (p.stage != PlotStage.sown && p.stage != PlotStage.growing) {
      _say('Fertilize a growing crop.');
      return;
    }
    if (p.fertilized) {
      _say('This crop is already fertilized.');
      return;
    }
    if (fertilizer <= 0) {
      _say('No fertilizer. Buy some in the shop.');
      return;
    }
    fertilizer--;
    p.fertilized = true;
    addXp(3);
    _teach('fertilizer');
    _changed();
  }

  void harvest(int id) {
    final p = plots[id];
    final cid = p.cropId;
    if (p.stage != PlotStage.mature || cid == null) {
      _say('Not ready to harvest yet.');
      return;
    }
    final qty = 1 + (p.health * 3).round();
    produce[cid] = (produce[cid] ?? 0) + qty;
    harvested[cid] = (harvested[cid] ?? 0) + qty;
    p
      ..stage = PlotStage.empty
      ..cropId = null
      ..progress = 0
      ..fertilized = false;
    addXp(15);
    _say('Harvested $qty ${crops[cid]!.name}. Healthier crops give more.');
    _teach('harvest');
    _changed();
  }

  // ---------- economy ----------
  void buySeed(String cropId) {
    final c = crops[cropId]!;
    if (level < c.unlockLevel) {
      _say('${c.name} unlocks at level ${c.unlockLevel}.');
      return;
    }
    if (coins < c.seedCost) {
      _say('Not enough coins.');
      return;
    }
    coins -= c.seedCost;
    seeds[cropId] = (seeds[cropId] ?? 0) + 1;
    _changed();
  }

  void buyFertilizer() {
    const cost = 10;
    if (coins < cost) {
      _say('Not enough coins.');
      return;
    }
    coins -= cost;
    fertilizer++;
    _changed();
  }

  void sell(String cropId) {
    final q = produce[cropId] ?? 0;
    if (q == 0) return;
    final earned = q * crops[cropId]!.sellPrice;
    coins += earned;
    produce.remove(cropId);
    addXp(q);
    _say('Sold $q ${crops[cropId]!.name} for $earned coins.');
    _changed();
  }

  void markWelcomed() {
    welcomed = true;
    _changed();
  }

  // ---------- education ----------
  void answerQuiz(String id, bool correct) {
    if (correct && quizzesDone.add(id)) {
      coins += 10;
      addXp(15);
      _changed();
    }
  }

  /// Decision scenario: a crop shows water stress. Returns the explanation.
  String resolveScenario(int plotId, int choice) {
    final p = plots[plotId];
    final crop = crops[p.cropId];
    String result;
    switch (choice) {
      case 0:
        p.moisture = _clamp01(p.moisture + 0.4);
        addXp(10);
        result = 'Watering right away relieved the stress, but you guessed. '
            'Without checking you could have under- or over-watered.';
      case 1:
        final reading = (p.moisture * 100).round();
        if (crop != null) {
          final top = crop.maxMoisture > 1 ? 0.9 : crop.maxMoisture;
          final target = (crop.minMoisture + top) / 2;
          p.moisture = math.max(p.moisture, target);
        }
        addXp(20);
        result = 'Best choice. You measured moisture first (about $reading%), '
            'confirmed it was too low, and watered just enough to reach the '
            'healthy range.';
      case 2:
        p.health = _clamp01(p.health - 0.1);
        addXp(2);
        result = 'Extra fertilizer does not fix water stress. Plants take up '
            'nutrients dissolved in soil water, and too much fertilizer can '
            'burn roots.';
      default:
        p.health = _clamp01(p.health - 0.2);
        result = 'Waiting let the stress continue and the crop lost health. '
            'Water stress is easiest to fix early.';
    }
    _teach('health');
    _changed();
    return result;
  }

  // ---------- persistence ----------
  static Future<GameState> load() async {
    final s = GameState();
    final prefs = await SharedPreferences.getInstance();
    s._prefs = prefs;
    final raw = prefs.getString(_saveKey);
    if (raw != null) {
      try {
        s._restore(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt save: start fresh.
      }
    }
    return s;
  }

  void _restore(Map<String, dynamic> j) {
    coins = j['coins'] as int;
    xp = j['xp'] as int;
    fertilizer = j['fert'] as int;
    seeds
      ..clear()
      ..addAll((j['seeds'] as Map).cast<String, int>());
    produce
      ..clear()
      ..addAll((j['produce'] as Map).cast<String, int>());
    harvested
      ..clear()
      ..addAll((j['harvested'] as Map).cast<String, int>());
    lessonsSeen
      ..clear()
      ..addAll((j['lessons'] as List).cast<String>());
    quizzesDone
      ..clear()
      ..addAll((j['quizzes'] as List).cast<String>());
    welcomed = (j['welcomed'] as bool?) ?? false;
    final list = j['plots'] as List;
    for (var i = 0; i < plots.length && i < list.length; i++) {
      plots[i] = PlotState.fromJson((list[i] as Map).cast<String, dynamic>());
    }
  }

  void _save() {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setString(
      _saveKey,
      jsonEncode({
        'coins': coins,
        'xp': xp,
        'fert': fertilizer,
        'seeds': seeds,
        'produce': produce,
        'harvested': harvested,
        'lessons': lessonsSeen.toList(),
        'quizzes': quizzesDone.toList(),
        'welcomed': welcomed,
        'plots': plots.map((p) => p.toJson()).toList(),
      }),
    );
  }
}
