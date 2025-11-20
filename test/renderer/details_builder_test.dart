import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/src/config/style_sheet.dart';
import 'package:flutter_smooth_markdown/src/parser/ast/markdown_node.dart';
import 'package:flutter_smooth_markdown/src/renderer/builders/details_builder.dart';
import 'package:flutter_smooth_markdown/src/renderer/widget_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetailsBuilder Tests', () {
    late DetailsBuilder builder;
    late MarkdownStyleSheet styleSheet;
    late MarkdownRenderContext context;

    setUp(() {
      builder = const DetailsBuilder();
      styleSheet = MarkdownStyleSheet.light();
      context = const MarkdownRenderContext();
    });

    test('should identify details nodes', () {
      const node = DetailsNode(
        summary: [TextNode('Summary')],
        children: [TextNode('Content')],
      );

      expect(builder.canBuild(node), isTrue);
    });

    test('should not identify non-details nodes', () {
      const node = TextNode('Not a details node');

      expect(builder.canBuild(node), isFalse);
    });

    testWidgets('should render closed details', (WidgetTester tester) async {
      const node = DetailsNode(
        summary: [TextNode('Click to expand')],
        children: [TextNode('Hidden content')],
        isOpen: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder.build(node, styleSheet, context),
          ),
        ),
      );

      expect(find.text('Click to expand'), findsOneWidget);
      // Content should not be visible initially
      expect(find.text('Hidden content'), findsNothing);
    });

    testWidgets('should render open details', (WidgetTester tester) async {
      const node = DetailsNode(
        summary: [TextNode('Already expanded')],
        children: [TextNode('Visible content')],
        isOpen: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder.build(node, styleSheet, context),
          ),
        ),
      );

      expect(find.text('Already expanded'), findsOneWidget);
      expect(find.text('Visible content'), findsOneWidget);
    });

    testWidgets('should toggle on tap', (WidgetTester tester) async {
      const node = DetailsNode(
        summary: [TextNode('Toggle me')],
        children: [TextNode('Toggle content')],
        isOpen: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder.build(node, styleSheet, context),
          ),
        ),
      );

      // Initially closed
      expect(find.text('Toggle content'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Toggle me'));
      await tester.pumpAndSettle();

      // Should now be visible
      expect(find.text('Toggle content'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Toggle me'));
      await tester.pumpAndSettle();

      // Should be hidden again
      expect(find.text('Toggle content'), findsNothing);
    });

    testWidgets('should render empty details', (WidgetTester tester) async {
      const node = DetailsNode(
        summary: [TextNode('Empty details')],
        children: [],
        isOpen: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder.build(node, styleSheet, context),
          ),
        ),
      );

      expect(find.text('Empty details'), findsOneWidget);
      // No error should occur with empty children
    });

    testWidgets('should display expand/collapse icons',
        (WidgetTester tester) async {
      const node = DetailsNode(
        summary: [TextNode('Icon test')],
        children: [TextNode('Content')],
        isOpen: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder.build(node, styleSheet, context),
          ),
        ),
      );

      // Should show right arrow when closed
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('Icon test'));
      await tester.pumpAndSettle();

      // Should show down arrow when open
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });
}
