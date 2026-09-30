import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_canvas/game/game_config.dart';
import 'package:meal_canvas/main.dart';

void main() {
  testWidgets('walks loader to menu to board to summary', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MealCanvasApp());
    expect(find.text('LOADING'), findsOneWidget);

    await tester.pump(
      const Duration(milliseconds: AppConfig.loaderDurationMs + 100),
    );
    await tester.pumpAndSettle();
    expect(find.text('START PLANNING'), findsOneWidget);

    await tester.tap(find.text('START PLANNING'));
    await tester.pumpAndSettle();
    expect(find.text('THE WEEK'), findsOneWidget);
    expect(find.text('0/21'), findsOneWidget);

    await tester.tap(find.text('FILL THE WEEK'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('21/21'), findsOneWidget);

    await tester.tap(find.text('BUILD LIST'));
    await tester.pumpAndSettle();
    expect(find.text('SHOPPING LIST'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START PLANNING'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FINISH WEEK'));
    await tester.pumpAndSettle();
    expect(find.text('PLAN AGAIN'), findsOneWidget);

    await tester.tap(find.text('PLAN AGAIN'));
    await tester.pumpAndSettle();
    expect(find.text('THE WEEK'), findsOneWidget);
  });

  testWidgets('board backstop reaches the summary with no input', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MealCanvasApp());
    await tester.pump(
      const Duration(milliseconds: AppConfig.loaderDurationMs + 100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('START PLANNING'));
    await tester.pumpAndSettle();

    await tester.pump(
      const Duration(milliseconds: AppConfig.idleBackstopMs + 200),
    );
    await tester.pumpAndSettle();
    expect(find.text('PLAN AGAIN'), findsOneWidget);
  });

  testWidgets('tapping a slot opens the editor and saves a meal', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MealCanvasApp());
    await tester.pump(
      const Duration(milliseconds: AppConfig.loaderDurationMs + 100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('START PLANNING'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('MEAL NAME'), findsOneWidget);

    await tester.tap(find.text('SAVE TO BOARD'));
    await tester.pumpAndSettle();
    expect(find.text('ENTER A MEAL NAME'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Test soup');
    await tester.tap(find.text('SAVE TO BOARD'));
    await tester.pumpAndSettle();
    expect(find.text('1/21'), findsOneWidget);
  });
}
