import 'package:flutter_smooth_markdown/src/parser/ast/markdown_node.dart';
import 'package:flutter_smooth_markdown/src/parser/block_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Header Inline Formatting', () {
    final parser = BlockParser();

    test('should parse bold text in H2 header', () {
      const markdown = '## 📝 **我的建议**';
      final nodes = parser.parse(markdown);

      expect(nodes, hasLength(1));
      expect(nodes[0], isA<HeaderNode>());

      final header = nodes[0] as HeaderNode;
      expect(header.level, 2);
      expect(header.content, '📝 **我的建议**');
      expect(header.children, isNotNull);
      expect(header.children, isNotEmpty);

      // Check that children contain TextNode and BoldNode
      final children = header.children!;
      expect(children.length, greaterThan(0));

      // Should have: TextNode("📝 ") + BoldNode("我的建议")
      var hasBoldNode = false;
      for (final child in children) {
        if (child is BoldNode) {
          hasBoldNode = true;
          expect(child.children, isNotEmpty);
          final boldText = child.children.first as TextNode;
          expect(boldText.content, '我的建议');
        }
      }
      expect(hasBoldNode, isTrue, reason: 'Header should contain a BoldNode');
    });

    test('should parse italic text in header', () {
      const markdown = '### This is *italic* text';
      final nodes = parser.parse(markdown);

      final header = nodes[0] as HeaderNode;
      expect(header.level, 3);
      expect(header.children, isNotNull);

      var hasItalicNode = false;
      for (final child in header.children!) {
        if (child is ItalicNode) {
          hasItalicNode = true;
        }
      }
      expect(hasItalicNode, isTrue);
    });

    test('should parse multiple inline formats in header', () {
      const markdown = '## **Bold** and *italic* and `code`';
      final nodes = parser.parse(markdown);

      final header = nodes[0] as HeaderNode;
      expect(header.children, isNotNull);

      var hasBold = false;
      var hasItalic = false;
      var hasCode = false;

      for (final child in header.children!) {
        if (child is BoldNode) hasBold = true;
        if (child is ItalicNode) hasItalic = true;
        if (child is InlineCodeNode) hasCode = true;
      }

      expect(hasBold, isTrue);
      expect(hasItalic, isTrue);
      expect(hasCode, isTrue);
    });

    test('should parse links in header', () {
      const markdown = '# Header with [link](https://example.com)';
      final nodes = parser.parse(markdown);

      final header = nodes[0] as HeaderNode;
      expect(header.children, isNotNull);

      var hasLink = false;
      for (final child in header.children!) {
        if (child is LinkNode) {
          hasLink = true;
          expect(child.url, 'https://example.com');
        }
      }
      expect(hasLink, isTrue);
    });

    test('should handle plain text header without formatting', () {
      const markdown = '## Plain Text Header';
      final nodes = parser.parse(markdown);

      final header = nodes[0] as HeaderNode;
      expect(header.content, 'Plain Text Header');
      expect(header.children, isNotNull);
      expect(header.children!.length, 1);
      expect(header.children![0], isA<TextNode>());
    });

    test('should handle emoji with bold text', () {
      const markdown = '## 🎉 **Celebration** 🎊';
      final nodes = parser.parse(markdown);

      final header = nodes[0] as HeaderNode;
      expect(header.children, isNotNull);

      var hasBold = false;
      for (final child in header.children!) {
        if (child is BoldNode) {
          hasBold = true;
        }
      }
      expect(hasBold, isTrue);
    });
  });
}
