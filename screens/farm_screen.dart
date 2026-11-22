import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../game/farm_game.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  // Created once so rebuilds don't restart the game.
  late final FarmGame _game = FarmGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: _game),
            // Flutter UI overlays (coins, XP, menus) will sit here later.
            const Positioned(
              top: 12,
              left: 16,
              child: Text(
                'FarmSite',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
