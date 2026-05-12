import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tbxpert/main.dart';

void main() {
  testWidgets('Home screen renders title and mic affordance',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TBXpertApp());

    expect(find.text('TBXpert'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(
      find.textContaining('Tap to record your cough'),
      findsOneWidget,
    );
  });
}
