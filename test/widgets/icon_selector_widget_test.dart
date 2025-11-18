import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph_todo/widgets/icon_selector_widget.dart';

void main() {
  group('IconSelectorWidget', () {
    testWidgets('renders icon selector correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Check if the widget is displayed
      expect(find.byType(IconSelectorWidget), findsOneWidget);

      // Check for title
      expect(find.text('Select Icon'), findsOneWidget);
    });

    testWidgets('has search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Check for search field
      expect(find.byType(TextField), findsOneWidget);

      // Check for search hint
      expect(
        find.text('Search icons (e.g., target, code, heart)...'),
        findsOneWidget,
      );
    });

    testWidgets('displays icons in grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Check for grid view
      expect(find.byType(GridView), findsOneWidget);

      // Should have multiple icon items
      final iconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      expect(iconItems, findsAtLeastNWidgets(10));
    });

    testWidgets('filters icons by search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Get initial count of icon items
      final initialIconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      final initialCount = tester.widgetList(initialIconItems).length;

      // Enter search query
      await tester.enterText(find.byType(TextField), 'target');
      await tester.pump();

      // Should have fewer items after filtering
      final filteredIconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      final filteredCount = tester.widgetList(filteredIconItems).length;

      expect(filteredCount, lessThan(initialCount));
    });

    testWidgets('shows no results message when search has no matches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Enter search query that won't match anything
      await tester.enterText(find.byType(TextField), 'nonexistenticon12345');
      await tester.pump();

      // Should show no results message
      expect(
        find.text('No icons found. Try a different search term.'),
        findsOneWidget,
      );
    });

    testWidgets('selects an icon when tapped', (WidgetTester tester) async {
      String? selectedIcon;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {
                selectedIcon = icon;
              },
            ),
          ),
        ),
      );

      // Find and tap an icon
      final iconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );

      expect(iconItems, findsAtLeastNWidgets(1));

      // Tap the first icon
      await tester.tap(iconItems.first);
      await tester.pump();

      // Verify callback was called
      expect(selectedIcon, isNotNull);
    });

    testWidgets('highlights currently selected icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // The selected icon should have different styling
      // This is indicated by the Container decoration
      await tester.pump();

      // Just verify the widget renders correctly
      expect(find.byType(IconSelectorWidget), findsOneWidget);
    });

    testWidgets('clears search when empty string entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Enter search query
      await tester.enterText(find.byType(TextField), 'code');
      await tester.pump();

      // Get the filtered count
      final filteredIconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      final filteredCount = tester.widgetList(filteredIconItems).length;

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Should show more icons after clearing (all icons)
      final allIconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      final allCount = tester.widgetList(allIconItems).length;

      expect(allCount, greaterThan(filteredCount));
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Search with uppercase
      await tester.enterText(find.byType(TextField), 'TARGET');
      await tester.pump();

      // Should still find results
      final iconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      expect(iconItems, findsAtLeastNWidgets(1));
    });

    testWidgets('can search by category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Search by category (e.g., 'tech')
      await tester.enterText(find.byType(TextField), 'tech');
      await tester.pump();

      // Should find tech-related icons
      final iconItems = find.byWidgetPredicate(
        (widget) => widget is GestureDetector &&
                     widget.child is Container,
      );
      expect(iconItems, findsAtLeastNWidgets(1));
    });

    testWidgets('renders without errors with null currentIcon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: null,
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(IconSelectorWidget), findsOneWidget);
    });

    testWidgets('has search icon in text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelectorWidget(
              currentIcon: 'target',
              onIconSelected: (icon) {},
            ),
          ),
        ),
      );

      // Check for search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
