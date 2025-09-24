import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/main.dart';

void main() {
  testWidgets('GraphTodo app starts and shows canvas', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Verify the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(CanvasWidget), findsOneWidget);
    
    // Check for floating action buttons (add, connect, eraser, clear)
    expect(find.byType(FloatingActionButton), findsNWidgets(4));
    
    // Check for add node button
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Check for connection mode button (link icon)
    expect(find.byIcon(Icons.link), findsOneWidget);
    
    // Check for clear button (clear_all icon)
    expect(find.byIcon(Icons.clear_all), findsOneWidget);
  });

  testWidgets('Add node mode can be toggled', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Initially should not show add node mode indicator
    expect(find.text('Click anywhere to add a new node'), findsNothing);

    // Tap the add node toggle button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Should show add node mode indicator
    expect(find.text('Click anywhere to add a new node'), findsOneWidget);
  });

  testWidgets('Connection mode can be toggled', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Initially should show link icon (not in connect mode)
    expect(find.byIcon(Icons.link), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    // Tap the connection toggle button
    await tester.tap(find.byIcon(Icons.link));
    await tester.pump();

    // Now should show close icon (in connect mode)
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.link), findsNothing);

    // Should show connection mode indicator
    expect(find.text('Select first node to connect'), findsOneWidget);
  });

  testWidgets('Clear canvas shows confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    // Tap the clear button
    await tester.tap(find.byIcon(Icons.clear_all));
    await tester.pump();

    // Should show confirmation dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Clear Canvas'), findsOneWidget);
    expect(find.text('Remove all nodes and connections?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);

    // Tap cancel to dismiss
    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('App has dark theme background', (WidgetTester tester) async {
    await tester.pumpWidget(const GraphTodoApp());

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, equals(const Color(0xFF1A1A1A)));
  });
}
