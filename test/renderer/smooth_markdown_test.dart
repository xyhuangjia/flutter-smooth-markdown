import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmoothMarkdown Widget Tests', () {
    testWidgets('should render simple text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: 'Hello World',
            useRepaintBoundary: false,
            enableCache: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should render header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '# Header 1',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Header 1'), findsOneWidget);
    });

    testWidgets('should render bold text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '**Bold text**',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Bold text'), findsOneWidget);
    });

    testWidgets('should render italic text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '*Italic text*',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Italic text'), findsOneWidget);
    });

    testWidgets('should render inline code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: 'Code: `var x = 1;`',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Code: '), findsOneWidget);
      expect(find.text('var x = 1;'), findsOneWidget);
    });

    testWidgets('should render code block', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
```dart
void main() {
  print('Hello');
}
```
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.textContaining('void main()'), findsOneWidget);
    });

    testWidgets('should render list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
- Item 1
- Item 2
- Item 3
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('• '), findsNWidgets(3));
    });

    testWidgets('should render ordered list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
1. First
2. Second
3. Third
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('1. '), findsOneWidget);
      expect(find.text('2. '), findsOneWidget);
      expect(find.text('3. '), findsOneWidget);
    });

    testWidgets('should render task list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
- [x] Completed task
- [ ] Pending task
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Completed task'), findsOneWidget);
      expect(find.text('Pending task'), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('should render blockquote', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '> This is a quote',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('This is a quote'), findsOneWidget);
    });

    testWidgets('should render horizontal rule', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
Text above

---

Text below
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Text above'), findsOneWidget);
      expect(find.text('Text below'), findsOneWidget);
    });

    testWidgets('should render link', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '[Click here](https://example.com)',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Click here'), findsOneWidget);
    });

    testWidgets('should call onTapLink callback', (tester) async {
      String? tappedUrl;

      await tester.pumpWidget(
        MaterialApp(
          home: SmoothMarkdown(
            data: '[Link](https://example.com)',
            useRepaintBoundary: false,
            enableCache: false,
            onTapLink: (url) {
              tappedUrl = url;
            },
          ),
        ),
      );

      await tester.tap(find.text('Link'));
      expect(tappedUrl, 'https://example.com');
    });

    testWidgets('should use custom style sheet', (tester) async {
      const customStyleSheet = MarkdownStyleSheet(
        h1Style: TextStyle(fontSize: 48),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '# Big Header',
            styleSheet: customStyleSheet,
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Big Header'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Big Header'));
      expect(textWidget.style?.fontSize, 48);
    });

    testWidgets('should use custom code builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SmoothMarkdown(
            data: '```dart\ncode\n```',
            useRepaintBoundary: false,
            enableCache: false,
            codeBuilder: (code, language) {
              return Text('Custom: $code ($language)');
            },
          ),
        ),
      );

      expect(find.textContaining('Custom: code'), findsOneWidget);
    });

    testWidgets('should use custom image builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SmoothMarkdown(
            data: '![Alt](image.png)',
            useRepaintBoundary: false,
            enableCache: false,
            imageBuilder: (url, alt, title) {
              return Text('Image: $url');
            },
          ),
        ),
      );

      expect(find.text('Image: image.png'), findsOneWidget);
    });

    testWidgets('should render complex markdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '''
# Title

This is a paragraph with **bold** and *italic* text.

## List

- Item 1
- Item 2

```dart
void main() {
  print('Hello');
}
```

> Quote
''',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('bold'), findsOneWidget);
      expect(find.text('italic'), findsOneWidget);
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Quote'), findsOneWidget);
    });

    testWidgets('should handle empty markdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      // Should not throw any errors
      expect(find.byType(SmoothMarkdown), findsOneWidget);
    });

    testWidgets('should handle whitespace-only markdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SmoothMarkdown(
            data: '   \n\n   ',
            useRepaintBoundary: false,
            enableCache: false,
          ),
        ),
      );

      // Should not throw any errors
      expect(find.byType(SmoothMarkdown), findsOneWidget);
    });
  });
}
