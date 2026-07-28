import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeable_dismissible/swipeable_dismissible.dart';

void main() {
  testWidgets('SwipeDismissible renders child widget correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeDismissible(
            actions: [
              SwipeDismissableAction(label: 'Delete', onPressed: () {}),
            ],
            child: const Text('Test Child'),
          ),
        ),
      ),
    );

    expect(find.text('Test Child'), findsOneWidget);
  });
}
