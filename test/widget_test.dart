import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmsite/app.dart';
import 'package:farmsite/game/farm_game.dart';
import 'package:farmsite/game/game_state.dart';

void main() {
  testWidgets('FarmSite shows the game and navigation', (tester) async {
    await tester.pumpWidget(FarmSiteApp(state: GameState()));
    await tester.pump();
    expect(find.byType(GameWidget<FarmGame>), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
  });
}
