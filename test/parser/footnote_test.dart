import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_smooth_markdown/src/parser/block_parser.dart';
import 'package:flutter_smooth_markdown/src/parser/inline_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Footnote Reference Tests (Inline)', () {
    late InlineParser parser;

    setUp(() {
      parser = InlineParser();
    });

    test('should parse simple footnote reference [^1]', () {
      final result = parser.parse('[^1]');
      expect(result.length, 1);
      expect(result[0], isA<FootnoteReferenceNode>());

      final footnote = result[0] as FootnoteReferenceNode;
      expect(footnote.label, '1');
      expect(footnote.type, 'footnote_reference');
    });

    test('should parse named footnote reference [^note]', () {
      final result = parser.parse('[^note]');
      expect(result.length, 1);
      expect(result[0], isA<FootnoteReferenceNode>());

      final footnote = result[0] as FootnoteReferenceNode;
      expect(footnote.label, 'note');
    });

    test('should parse footnote in text', () {
      final result = parser.parse('Some text[^1] more text');
      expect(result.length, 3);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'Some text');
      expect(result[1], isA<FootnoteReferenceNode>());
      expect((result[1] as FootnoteReferenceNode).label, '1');
      expect(result[2], isA<TextNode>());
      expect((result[2] as TextNode).content, ' more text');
    });

    test('should parse multiple footnotes in text', () {
      final result = parser.parse('Text[^1] and[^2]');
      expect(result.length, 4);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'Text');
      expect(result[1], isA<FootnoteReferenceNode>());
      expect((result[1] as FootnoteReferenceNode).label, '1');
      expect(result[2], isA<TextNode>());
      expect((result[2] as TextNode).content, ' and');
      expect(result[3], isA<FootnoteReferenceNode>());
      expect((result[3] as FootnoteReferenceNode).label, '2');
    });

    test('should not parse empty footnote [^]', () {
      final result = parser.parse('[^]');
      // Empty label should not be parsed as a footnote reference
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
    });

    test('should not parse unclosed footnote [^1', () {
      final result = parser.parse('[^1');
      // Unclosed bracket should not be parsed as a footnote reference
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
    });
  });

  group('Footnote Definition Tests (Block)', () {
    late BlockParser parser;

    setUp(() {
      parser = BlockParser();
    });

    test('should parse simple footnote definition', () {
      final result = parser.parse('[^1]: This is a footnote');
      expect(result.length, 1);
      expect(result[0], isA<FootnoteDefinitionNode>());

      final footnote = result[0] as FootnoteDefinitionNode;
      expect(footnote.label, '1');
      expect(footnote.type, 'footnote_definition');
      expect(footnote.children.length, 1);
      expect(footnote.children[0], isA<TextNode>());
      expect((footnote.children[0] as TextNode).content, 'This is a footnote');
    });

    test('should parse multi-line footnote definition with indented continuation', () {
      final result = parser.parse(
        '[^1]: First line\n'
        '    Second line\n'
        '    Third line',
      );
      expect(result.length, 1);
      expect(result[0], isA<FootnoteDefinitionNode>());

      final footnote = result[0] as FootnoteDefinitionNode;
      expect(footnote.label, '1');
      // Content should include all continuation lines
      expect(footnote.children, isNotEmpty);
      // The content is joined with newlines, then parsed as inline
      final fullText = footnote.children
          .whereType<TextNode>()
          .map((n) => n.content)
          .join();
      expect(fullText, contains('First line'));
      expect(fullText, contains('Second line'));
      expect(fullText, contains('Third line'));
    });

    test('should parse footnote definition with inline formatting', () {
      final result = parser.parse('[^1]: This is **bold** footnote');
      expect(result.length, 1);
      expect(result[0], isA<FootnoteDefinitionNode>());

      final footnote = result[0] as FootnoteDefinitionNode;
      expect(footnote.label, '1');
      // Children should contain text and bold nodes
      expect(footnote.children.length, 3);
      expect(footnote.children[0], isA<TextNode>());
      expect((footnote.children[0] as TextNode).content, 'This is ');
      expect(footnote.children[1], isA<BoldNode>());
      expect(footnote.children[2], isA<TextNode>());
      expect((footnote.children[2] as TextNode).content, ' footnote');
    });

    test('should parse named footnote definition', () {
      final result = parser.parse('[^note]: Named footnote content');
      expect(result.length, 1);
      expect(result[0], isA<FootnoteDefinitionNode>());

      final footnote = result[0] as FootnoteDefinitionNode;
      expect(footnote.label, 'note');
      expect(footnote.children.length, 1);
      expect(footnote.children[0], isA<TextNode>());
      expect(
        (footnote.children[0] as TextNode).content,
        'Named footnote content',
      );
    });
  });
}
