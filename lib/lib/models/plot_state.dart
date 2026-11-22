enum PlotStage { empty, prepared, sown, growing, mature, withered }

/// Pure Dart data for one plot (no Flutter/Flame imports).
class PlotState {
  PlotState({required this.id, this.unlocked = true});

  final int id;
  bool unlocked;
  PlotStage stage = PlotStage.empty;
  String? cropId;
  double progress = 0; // 0..1 growth
  double moisture = 0.2; // 0..1
  double health = 1; // 0..1
  bool fertilized = false;
  bool scenarioShown = false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlocked': unlocked,
    'stage': stage.name,
    'crop': cropId,
    'progress': progress,
    'moisture': moisture,
    'health': health,
    'fert': fertilized,
    'scn': scenarioShown,
  };

  factory PlotState.fromJson(Map<String, dynamic> j) {
    final p = PlotState(id: j['id'] as int, unlocked: j['unlocked'] as bool);
    p.stage = PlotStage.values.byName(j['stage'] as String);
    p.cropId = j['crop'] as String?;
    p.progress = (j['progress'] as num).toDouble();
    p.moisture = (j['moisture'] as num).toDouble();
    p.health = (j['health'] as num).toDouble();
    p.fertilized = j['fert'] as bool;
    p.scenarioShown = j['scn'] as bool;
    return p;
  }
}
