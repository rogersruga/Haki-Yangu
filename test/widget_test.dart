// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:haki_yangu/main.dart';

void main() {
  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HakiYanguApp());

    // Let the initial frame render
    await tester.pump();

    // Verify that splash screen elements are present
    expect(find.text('HAKI YANGU'), findsOneWidget);
    expect(find.text('Know. Protect. Defend.'), findsOneWidget);
    expect(find.byIcon(Icons.balance), findsOneWidget);

    // Verify the progress indicator is present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Clean up by waiting for all animations and timers to complete
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('Splash screen animations work correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HakiYanguApp());

    // Verify we start on splash screen
    expect(find.text('HAKI YANGU'), findsOneWidget);
    expect(find.text('Know. Protect. Defend.'), findsOneWidget);

    // Pump a few frames to let animations start
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify elements are still there during animation
    expect(find.text('HAKI YANGU'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Clean up remaining animations
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
