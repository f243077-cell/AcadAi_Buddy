import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/presentation/core/theme.dart';
import 'package:study_ai_app/presentation/core/widgets/markdown_view.dart';
import 'package:study_ai_app/presentation/pages/study/chat/widgets/message_bubble.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  setUpAll(() => AppFonts.useGoogleFonts = false);

  ChatMessage msg(String content, MessageRole role) => ChatMessage(
        id: 'm',
        content: content,
        role: role,
        timestamp: DateTime(2026),
        chatId: 'c',
      );

  testWidgets('AI message renders markdown, code block with copy, and math',
      (tester) async {
    await tester.pumpWidget(_wrap(AiMessage(
      message: msg(
          '**Bold** text and \$x^2\$.\n\n```python\nprint(1)\n```', MessageRole.model),
      onRegenerate: () {},
    )));
    expect(find.byType(CodeBlock), findsOneWidget);
    expect(find.text('python'), findsOneWidget);
    expect(find.text('print(1)'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    // Inline math is rendered, not left as raw dollars.
    expect(find.textContaining(r'$x^2$'), findsNothing);
  });

  testWidgets('failed user message shows Not sent and Retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(UserBubble(
      message: msg('Hello', MessageRole.user),
      failed: true,
      onRetry: () => retried = true,
    )));
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Not sent.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  test('date separator labels', () {
    final now = DateTime(2026, 10, 2, 12);
    expect(DateSeparator.labelFor(DateTime(2026, 10, 2, 8), now), 'Today');
    expect(DateSeparator.labelFor(DateTime(2026, 10, 1, 23), now), 'Yesterday');
  });
}
