import 'package:flutter/material.dart';

import 'core/theme.dart';
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
      theme: buildFolkTheme(),
      home: FarmScreen(state: state),
    );
  }
}
