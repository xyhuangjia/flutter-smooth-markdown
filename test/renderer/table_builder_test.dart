import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_smooth_markdown/src/renderer/builders/table_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableBuilder Tests', () {
    late TableBuilder builder;
    late MarkdownStyleSheet styleSheet;

    setUp(() {
      builder = const TableBuilder();
      styleSheet = MarkdownStyleSheet.light();
    });

    test('should identify table nodes', () {
      final tableNode = TableNode(
        headers: [
          [const TextNode('Header 1')],
          [const TextNode('Header 2')],
        ],
        alignments: [null, null],
        rows: [],
      );

      expect(builder.canBuild(tableNode), true);
      expect(builder.canBuild(const TextNode('text')), false);
    });

    testWidgets('should render simple table', (WidgetTester tester) async {
      final tableNode = TableNode(
        headers: [
          [const TextNode('Header 1')],
          [const TextNode('Header 2')],
        ],
        alignments: [null, null],
        rows: [
          TableRowNode([
            [const TextNode('Cell 1')],
            [const TextNode('Cell 2')],
          ]),
        ],
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: builder.build(
            tableNode,
            styleSheet,
            const MarkdownRenderContext(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should render table with alignments', (WidgetTester tester) async {
      final tableNode = TableNode(
        headers: [
          [const TextNode('Left')],
          [const TextNode('Center')],
          [const TextNode('Right')],
        ],
        alignments: [
          TableAlignment.left,
          TableAlignment.center,
          TableAlignment.right,
        ],
        rows: [
          TableRowNode([
            [const TextNode('L1')],
            [const TextNode('C1')],
            [const TextNode('R1')],
          ]),
        ],
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: builder.build(
            tableNode,
            styleSheet,
            const MarkdownRenderContext(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should render table with inline elements', (WidgetTester tester) async {
      final tableNode = TableNode(
        headers: [
          [const TextNode('Name')],
          [const TextNode('Description')],
        ],
        alignments: [null, null],
        rows: [
          TableRowNode([
            [
              BoldNode([const TextNode('Bold')])
            ],
            [
              ItalicNode([const TextNode('Italic')])
            ],
          ]),
        ],
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: builder.build(
            tableNode,
            styleSheet,
            const MarkdownRenderContext(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should apply table border from style sheet', (WidgetTester tester) async {
      final customStyleSheet = MarkdownStyleSheet.light().copyWith(
        tableBorder: TableBorder.all(color: Colors.red, width: 2),
      );

      final tableNode = TableNode(
        headers: [
          [const TextNode('Header')],
        ],
        alignments: [null],
        rows: [],
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: builder.build(
            tableNode,
            customStyleSheet,
            const MarkdownRenderContext(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });
  });
}
