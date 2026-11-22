import 'package:flutter/material.dart';

import 'app.dart';
import 'game/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await GameState.load();
  runApp(FarmSiteApp(state: state));
}
