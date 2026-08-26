import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_survival/core/storage/game_storage.dart';
import 'package:tap_survival/game/game_controller.dart';
import 'package:tap_survival/main.dart';

void main() {
  testWidgets('App initializes and displays main menu with Tap Survival title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await GameStorage.init();
    final controller = GameController(storage);

    await tester.pumpWidget(TapSurvivalApp(controller: controller));
    await tester.pump();

    expect(find.text('TAP SURVIVAL'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);
    expect(find.text('SHOP'), findsOneWidget);
    expect(find.text('HIGH SCORES'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);

    // Tap on SHOP button
    await tester.tap(find.text('SHOP'));
    await tester.pump();
    expect(find.text('OBSTACLE SHOP'), findsOneWidget);
    expect(find.text('SHAPES'), findsOneWidget);
    expect(find.text('COLORS'), findsOneWidget);

    // Tap BACK button
    await tester.tap(find.text('BACK'));
    await tester.pump();
    expect(find.text('TAP SURVIVAL'), findsOneWidget);

    // Tap SETTINGS button
    await tester.tap(find.text('SETTINGS'));
    await tester.pump();
    expect(find.text('CHARACTER SELECT'), findsOneWidget);
    expect(find.text('ACTORS'), findsOneWidget);

    // Tap BACK button
    await tester.tap(find.text('BACK'));
    await tester.pump();
    expect(find.text('TAP SURVIVAL'), findsOneWidget);

    // Tap NEW GAME button
    await tester.tap(find.text('NEW GAME'));
    await tester.pump();
    expect(find.text('TAP SURVIVAL'), findsNothing);
    expect(find.textContaining('Score:'), findsOneWidget);
  });

  test('GameController state changes and mechanics', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await GameStorage.init();
    final controller = GameController(storage);
    controller.init(400, 800);

    expect(controller.currentState, GameState.mainMenu);

    controller.startGame();
    expect(controller.currentState, GameState.playing);
    expect(controller.score, 0);

    // Toggle player lane
    final initialLeft = controller.player.isLeftLane;
    controller.player.toggleLane();
    expect(controller.player.isLeftLane, !initialLeft);

    // Pause game
    controller.pauseGame();
    expect(controller.currentState, GameState.paused);

    // Resume game
    controller.resumeGame();
    expect(controller.currentState, GameState.playing);
  });
}
