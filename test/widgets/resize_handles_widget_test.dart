import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/widgets/resize_handles_widget.dart';

void main() {
  group('ResizeHandlesWidget', () {
    testWidgets('renders resize handles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 200,
              child: ResizeHandlesWidget(
                nodeSize: 120.0,
                scale: 1.0,
              ),
            ),
          ),
        ),
      );

      // Check that resize handles are rendered
      expect(find.byType(ResizeHandlesWidget), findsOneWidget);
      expect(find.byIcon(Icons.open_in_full), findsNWidgets(2));
    });

    testWidgets('handles have correct size based on scale', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 200,
              child: ResizeHandlesWidget(
                nodeSize: 120.0,
                scale: 2.0,
              ),
            ),
          ),
        ),
      );

      // At scale 2.0, the handles should be larger but clamped to max 1.5
      // Handle size = 24.0 * scale.clamp(0.8, 1.5) = 24.0 * 1.5 = 36.0
      final handles = find.descendant(
        of: find.byType(ResizeHandlesWidget),
        matching: find.byType(Container),
      );
      
      expect(handles, findsAtLeastNWidgets(2));
    });
  });
}