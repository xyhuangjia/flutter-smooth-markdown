import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Header Inline Rendering', () {
    testWidgets('should render bold text in header', (WidgetTester tester) async {
      const markdown = '## 📝 **我的建议**';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      // The widget should render successfully
      expect(find.byType(SmoothMarkdown), findsOneWidget);

      // Print the widget tree for debugging
      debugDumpApp();
    });

    testWidgets('should render multiple inline formats in header', (WidgetTester tester) async {
      const markdown = '### **Bold** and *italic* and `code`';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      expect(find.byType(SmoothMarkdown), findsOneWidget);
    });

    testWidgets('should render link in header', (WidgetTester tester) async {
      const markdown = '# Header with [link](https://example.com)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMarkdown(
              data: markdown,
            ),
          ),
        ),
      );

      expect(find.byType(SmoothMarkdown), findsOneWidget);
    });
  });
}
