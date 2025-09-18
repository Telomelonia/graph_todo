import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/main.dart';
import 'package:graph_todo/pages/auth_page.dart';

void main() {
  testWidgets('GraphTodo app starts and shows auth page', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Wait for Firebase initialization
    await tester.pumpAndSettle();

    // Verify the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AuthPage), findsOneWidget);
    
    // Should show auth UI elements
    expect(find.text('Welcome to GraphTodo'), findsOneWidget);
  });

  testWidgets('App has dark theme background', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Wait for Firebase initialization
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, equals(const Color(0xFF1A1A1A)));
  });
}
