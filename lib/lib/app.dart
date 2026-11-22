import 'package:material_ui/material_ui.dart';

import 'game/game_state.dart';
import 'screens/farm_screen.dart';

class FarmSiteApp extends StatelessWidget {
  const FarmSiteApp({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmSite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: FarmScreen(state: state),
    );
  }
}
