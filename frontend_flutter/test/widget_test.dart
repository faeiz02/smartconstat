// Smoke test: l'app se construit sans erreur de widget racine.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_accident_app/main.dart';

void main() {
  testWidgets('SmartConstat se charge', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartConstatApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
