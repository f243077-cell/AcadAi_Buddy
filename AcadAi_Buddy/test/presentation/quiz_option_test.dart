import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/presentation/core/theme.dart';
import 'package:study_ai_app/presentation/pages/study/quiz/widgets/quiz_widgets.dart';

void main() {
  setUpAll(() => AppFonts.useGoogleFonts = false);

  test('option states before and after checking', () {
    OptionState s(int i, int? sel, bool checked) => optionStateFor(
        i: i, correctIndex: 1, selectedIndex: sel, checked: checked);

    expect(s(0, null, false), OptionState.idle);
    expect(s(2, 2, false), OptionState.selected);
    expect(s(1, 2, true), OptionState.correct);
    expect(s(2, 2, true), OptionState.wrong);
    expect(s(0, 2, true), OptionState.dimmed);
    expect(s(1, 1, true), OptionState.correct);
  });

  Future<void> pump(WidgetTester t, OptionState state) => t.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: QuizOptionTile(index: 1, text: 'Queue', state: state, onTap: () {}),
          ),
        ),
      );

  testWidgets('correct and wrong use an icon, not only colour', (t) async {
    await pump(t, OptionState.correct);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Option B: Queue, correct answer'),
        findsOneWidget);

    await pump(t, OptionState.wrong);
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

    await pump(t, OptionState.idle);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('tile is at least 56 dp high', (t) async {
    await pump(t, OptionState.idle);
    expect(t.getSize(find.byType(QuizOptionTile)).height,
        greaterThanOrEqualTo(56));
  });
}
