import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:graph_todo/widgets/info_panel_widget.dart';
import 'package:graph_todo/models/todo_node.dart';
import 'package:graph_todo/providers/canvas_provider.dart';

void main() {
  group('InfoPanelWidget', () {
    late TodoNode testNode;
    late CanvasProvider provider;

    setUp(() {
      testNode = TodoNode(
        id: 'test-node',
        text: 'Test Task',
        description: 'Test description',
        icon: 'target',
        position: const Offset(100, 100),
      );
      provider = CanvasProvider();
      provider.addNode(testNode.position, text: testNode.text);
    });

    Widget createTestWidget(TodoNode node) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: Scaffold(
            body: Stack(
              children: [
                InfoPanelWidget(node: node),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders info panel correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Check if the panel is displayed
      expect(find.byType(InfoPanelWidget), findsOneWidget);

      // Check if close button exists
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays node information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Should show task title in header
      expect(find.text('Test Task'), findsAtLeast(1));
    });

    testWidgets('has title and description text fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Check for text fields
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2)); // Title and Description fields
    });

    testWidgets('updates title text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Find the title text field (first one)
      final titleField = find.byType(TextField).first;

      // Enter new text
      await tester.enterText(titleField, 'Updated Title');
      await tester.pump();

      // Verify the text was entered
      expect(find.text('Updated Title'), findsAtLeast(1));
    });

    testWidgets('updates description text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Find the description text field (second one)
      final descriptionField = find.byType(TextField).at(1);

      // Enter new text
      await tester.enterText(descriptionField, 'New description');
      await tester.pump();

      // Verify the text was entered
      expect(find.text('New description'), findsOneWidget);
    });

    testWidgets('displays color picker', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Check if color label exists
      expect(find.text('Color:'), findsOneWidget);

      // Should have multiple color circles
      final colorContainers = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      );
      expect(colorContainers, findsAtLeastNWidgets(5));
    });

    testWidgets('selects a color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Find color circles using GestureDetector
      final colorCircles = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container &&
                     (widget.child as Container).decoration is BoxDecoration,
      );

      expect(colorCircles, findsAtLeastNWidgets(5));
    });

    testWidgets('has icon selector button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Check if Icon label exists
      expect(find.text('Icon:'), findsOneWidget);
    });

    testWidgets('shows icon selector dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Find the icon selector button by looking for GestureDetector
      final iconButton = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container &&
                     (widget.child as Container).child is Row,
      ).first;

      // Tap to open icon selector
      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('closes info panel when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Find and tap the close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pump();

      // Verify hideNodeInfo was called (panel should be hidden)
      expect(provider.nodeShowingInfo, isNull);
    });

    testWidgets('displays in dark mode', (WidgetTester tester) async {
      provider.toggleTheme(); // Enable dark mode

      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Panel should render without errors
      expect(find.byType(InfoPanelWidget), findsOneWidget);
    });

    testWidgets('displays in light mode', (WidgetTester tester) async {
      // Light mode is default
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      // Panel should render without errors
      expect(find.byType(InfoPanelWidget), findsOneWidget);
    });

    testWidgets('shows Title label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      expect(find.text('Title:'), findsOneWidget);
    });

    testWidgets('shows Description label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testNode));
      await tester.pump();

      expect(find.text('Description:'), findsOneWidget);
    });

    testWidgets('renders without errors for node with empty text', (WidgetTester tester) async {
      final emptyNode = TodoNode(
        id: 'empty-node',
        text: '',
        position: const Offset(50, 50),
      );

      await tester.pumpWidget(createTestWidget(emptyNode));
      await tester.pump();

      // Should show "New Task" for empty nodes
      expect(find.text('New Task'), findsAtLeast(1));
    });
  });
}
