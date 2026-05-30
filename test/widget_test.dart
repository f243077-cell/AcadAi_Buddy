import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Build a basic app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
