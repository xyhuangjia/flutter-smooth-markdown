import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Table Integration Tests', () {
    testWidgets('should parse and render simple table', (WidgetTester tester) async {
      const markdown = '''
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should render table with alignment', (WidgetTester tester) async {
      const markdown = '''
| Left | Center | Right |
|:-----|:------:|------:|
| L1   | C1     | R1    |
| L2   | C2     | R2    |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should render table with inline formatting', (WidgetTester tester) async {
      const markdown = '''
| Name | Description |
|------|-------------|
| **Bold** | *Italic* |
| `code` | [link](url) |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
              onTapLink: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should render multiple tables', (WidgetTester tester) async {
      const markdown = '''
# First Table

| A | B |
|---|---|
| 1 | 2 |

# Second Table

| X | Y |
|---|---|
| 3 | 4 |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SmoothMarkdown(
                data: markdown,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both tables are rendered
      expect(find.byType(Table), findsNWidgets(2));
    });

    testWidgets('should apply custom table styles', (WidgetTester tester) async {
      const markdown = '''
| Header |
|--------|
| Data   |
''';

      final customStyleSheet = MarkdownStyleSheet.light().copyWith(
        tableBorder: TableBorder.all(color: Colors.red, width: 2),
        tableHeaderDecoration: const BoxDecoration(color: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
              styleSheet: customStyleSheet,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should handle empty cells', (WidgetTester tester) async {
      const markdown = '''
| Col1 | Col2 |
|------|------|
|      | Data |
| Data |      |
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('should work with dark theme', (WidgetTester tester) async {
      const markdown = '''
| Feature | Status |
|---------|--------|
| Dark Mode | ✅ |
| Tables | ✅ |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
              styleSheet: MarkdownStyleSheet.dark(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify table is rendered
      expect(find.byType(Table), findsOneWidget);
    });
  });
}
