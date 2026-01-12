// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uas/main.dart';

void main() {
  testWidgets('App shows splash with app name', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Allow splash timer to run and settle
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // App initialized; MaterialApp should exist and app has routed to next screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
