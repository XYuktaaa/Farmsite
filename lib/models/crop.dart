enum Season {
  kharif('Kharif'),
  rabi('Rabi'),
  zaid('Zaid');

  const Season(this.label);
  final String label;
}

/// Static crop definition. Pure Dart: numbers here are simplified
/// game values, not real agronomic data.
class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.season,
    required this.seedCost,
    required this.sellPrice,
    required this.growSeconds,
    required this.minMoisture,
    required this.maxMoisture,
    required this.dryRate,
    required this.unlockLevel,
    required this.color,
    required this.tip,
  });

  final String id;
  final String name;
  final Season season;
  final int seedCost;
  final int sellPrice;
  final int growSeconds; // real seconds to mature (prototype speed)
  final double minMoisture; // below this the crop is water-stressed
  final double maxMoisture; // above this the crop is waterlogged
  final double dryRate; // moisture lost per second
  final int unlockLevel;
  final int color; // ARGB, used for drawing
  final String tip;
}

const Map<String, Crop> crops = {
  'wheat': Crop(
    id: 'wheat',
    name: 'Wheat',
    season: Season.rabi,
    seedCost: 10,
    sellPrice: 8,
    growSeconds: 60,
    minMoisture: 0.2,
    maxMoisture: 0.75,
    dryRate: 0.012,
    unlockLevel: 1,
    color: 0xFFD4A017,
    tip: 'Cool-season crop. Needs moderate water and dislikes waterlogging.',
  ),
  'maize': Crop(
    id: 'maize',
    name: 'Maize',
    season: Season.kharif,
    seedCost: 15,
    sellPrice: 12,
    growSeconds: 75,
    minMoisture: 0.25,
    maxMoisture: 0.8,
    dryRate: 0.012,
    unlockLevel: 2,
    color: 0xFFFFC107,
    tip: 'Grown in several seasons in India. Sensitive to both drought and standing water.',
  ),
  'rice': Crop(
    id: 'rice',
    name: 'Rice',
    season: Season.kharif,
    seedCost: 20,
    sellPrice: 16,
    growSeconds: 90,
    minMoisture: 0.45,
    maxMoisture: 1.01, // paddy rice tolerates saturated soil
    dryRate: 0.006,
    unlockLevel: 3,
    color: 0xFFE0D8A8,
    tip: 'Monsoon crop. Thrives in saturated, flooded fields.',
  ),
};

const List<String> cropOrder = ['wheat', 'maize', 'rice'];
