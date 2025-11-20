import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(find.text('Click to expand'), findsOneWidget);

      // Content should be hidden initially
      expect(find.textContaining('hidden content'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Click to expand'));
      await tester.pumpAndSettle();

      // Content should now be visible
      expect(find.textContaining('hidden content'), findsOneWidget);
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

      expect(find.text('Already open'), findsOneWidget);
      expect(find.textContaining('visible by default'), findsOneWidget);
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

      expect(find.text('Code Example'), findsOneWidget);

      // Expand
      await tester.tap(find.text('Code Example'));
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

      expect(find.text('Feature List'), findsOneWidget);

      // Expand
      await tester.tap(find.text('Feature List'));
      await tester.pumpAndSettle();

      // List items should be visible
      expect(find.textContaining('Feature 1'), findsOneWidget);
      expect(find.textContaining('Feature 2'), findsOneWidget);
      expect(find.textContaining('Feature 3'), findsOneWidget);
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

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      // Expand first
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Content 1'), findsOneWidget);

      // Expand second
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Content 2'), findsOneWidget);
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

      expect(find.text('Outer'), findsOneWidget);

      // Expand outer
      await tester.tap(find.text('Outer'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Outer content'), findsOneWidget);
      expect(find.text('Inner'), findsOneWidget);

      // Expand inner
      await tester.tap(find.text('Inner'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Inner content'), findsOneWidget);
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

      expect(find.text('Themed'), findsOneWidget);

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
      expect(find.text('Themed'), findsOneWidget);

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
      expect(find.text('Themed'), findsOneWidget);
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
      await tester.tap(find.text('Details 1'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Content 1'), findsOneWidget);

      // Expand second details
      await tester.tap(find.text('Details 2'));
      await tester.pumpAndSettle();

      // Both should be visible
      expect(find.textContaining('Content 1'), findsOneWidget);
      expect(find.textContaining('Content 2'), findsOneWidget);
    });
  });
}
