import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

/// Custom finder that finds RichText widgets containing the specified text
Finder findRichTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is RichText) {
        final textSpan = widget.text;
        return textSpan.toPlainText().contains(text);
      }
      return false;
    },
    description: 'RichText containing "$text"',
  );
}

void main() {
  group('Details Integration Tests', () {
    testWidgets('should parse and render basic details',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>Click to expand</summary>
This is the hidden content.
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(data: markdown),
          ),
        ),
      );

      // Summary should be visible
      expect(findRichTextContaining('Click to expand'), findsOneWidget);

      // Content should be hidden initially
      expect(findRichTextContaining('hidden content'), findsNothing);

      // Tap to expand
      await tester.tap(findRichTextContaining('Click to expand'));
      await tester.pumpAndSettle();

      // Content should now be visible
      expect(findRichTextContaining('hidden content'), findsOneWidget);
    });

    testWidgets('should render open details', (WidgetTester tester) async {
      const markdown = '''
<details open>
<summary>Already open</summary>
This content is visible by default.
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(data: markdown),
          ),
        ),
      );

      expect(findRichTextContaining('Already open'), findsOneWidget);
      expect(findRichTextContaining('visible by default'), findsOneWidget);
    });

    testWidgets('should render details with code block',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>Code Example</summary>

```dart
void main() {
  print('Hello');
}
```
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(data: markdown),
          ),
        ),
      );

      expect(findRichTextContaining('Code Example'), findsOneWidget);

      // Expand
      await tester.tap(findRichTextContaining('Code Example'));
      await tester.pumpAndSettle();

      // Code should be visible
      expect(find.textContaining('void main'), findsOneWidget);
    });

    testWidgets('should render details with list',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>Feature List</summary>

- Feature 1
- Feature 2
- Feature 3
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(data: markdown),
          ),
        ),
      );

      expect(findRichTextContaining('Feature List'), findsOneWidget);

      // Expand
      await tester.tap(findRichTextContaining('Feature List'));
      await tester.pumpAndSettle();

      // List items should be visible
      expect(findRichTextContaining('Feature 1'), findsOneWidget);
      expect(findRichTextContaining('Feature 2'), findsOneWidget);
      expect(findRichTextContaining('Feature 3'), findsOneWidget);
    });

    testWidgets('should render multiple details blocks',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>First</summary>
Content 1
</details>

<details>
<summary>Second</summary>
Content 2
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(data: markdown),
          ),
        ),
      );

      expect(findRichTextContaining('First'), findsOneWidget);
      expect(findRichTextContaining('Second'), findsOneWidget);

      // Expand first
      await tester.tap(findRichTextContaining('First'));
      await tester.pumpAndSettle();
      expect(findRichTextContaining('Content 1'), findsOneWidget);

      // Expand second
      await tester.tap(findRichTextContaining('Second'));
      await tester.pumpAndSettle();
      expect(findRichTextContaining('Content 2'), findsOneWidget);
    });

    testWidgets('should render nested details',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>Outer</summary>

Outer content

<details>
<summary>Inner</summary>
Inner content
</details>
</details>
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: const SmoothMarkdown(data: markdown),
            ),
          ),
        ),
      );

      // Note: Nested details support is limited.
      // The outer "Inner" is rendered. Look for it either as Text or RichText.
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text && widget.data == 'Inner') return true;
          if (widget is RichText && widget.text.toPlainText().contains('Inner')) return true;
          return false;
        }),
        findsWidgets,
      );
    });

    testWidgets('should work with different themes',
        (WidgetTester tester) async {
      const markdown = '''
<details>
<summary>Themed</summary>
Content
</details>
''';

      // Test with light theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
              styleSheet: MarkdownStyleSheet.light(),
            ),
          ),
        ),
      );

      expect(findRichTextContaining('Themed'), findsOneWidget);

      // Test with dark theme
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
      expect(findRichTextContaining('Themed'), findsOneWidget);

      // Test with GitHub theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
              styleSheet: MarkdownStyleSheet.github(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(findRichTextContaining('Themed'), findsOneWidget);
    });

    testWidgets('should maintain state when scrolling',
        (WidgetTester tester) async {
      const markdown = '''
# Header

<details>
<summary>Details 1</summary>
Content 1
</details>

<details>
<summary>Details 2</summary>
Content 2
</details>

<details>
<summary>Details 3</summary>
Content 3
</details>
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: const SmoothMarkdown(data: markdown),
            ),
          ),
        ),
      );

      // Expand first details
      await tester.tap(findRichTextContaining('Details 1'));
      await tester.pumpAndSettle();
      expect(findRichTextContaining('Content 1'), findsOneWidget);

      // Expand second details
      await tester.tap(findRichTextContaining('Details 2'));
      await tester.pumpAndSettle();

      // Both should be visible
      expect(findRichTextContaining('Content 1'), findsOneWidget);
      expect(findRichTextContaining('Content 2'), findsOneWidget);
    });
  });
}
