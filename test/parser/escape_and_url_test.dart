import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_smooth_markdown/src/parser/inline_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backslash Escape Tests', () {
    late InlineParser parser;

    setUp(() {
      parser = InlineParser();
    });

    test('should escape asterisks', () {
      final result = parser.parse(r'This is \*not bold\* text');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'This is *not bold* text');
    });

    test('should escape square brackets', () {
      final result = parser.parse(r'This is \[not a link\]');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'This is [not a link]');
    });

    test('should escape backticks', () {
      final result = parser.parse(r'This is \`not code\`');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'This is `not code`');
    });

    test('should escape underscores', () {
      final result = parser.parse(r'This is \_not italic\_');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, 'This is _not italic_');
    });

    test('should escape tildes', () {
      final result = parser.parse(r'This is \~\~not strikethrough\~\~');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect(
          (result[0] as TextNode).content, 'This is ~~not strikethrough~~');
    });

    test('should escape exclamation mark', () {
      final result = parser.parse(r'This is \![not an image](url)');
      // The \! should become plain !, then [not an image](url) is a link
      expect(result.length, 2);
      expect((result[0] as TextNode).content, 'This is !');
      expect(result[1], isA<LinkNode>());
    });

    test('should escape dollar sign', () {
      final result = parser.parse(r'Price is \$100');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, contains('\$100'));
    });

    test('should escape backslash itself', () {
      final result = parser.parse(r'A \\ backslash');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      expect((result[0] as TextNode).content, r'A \ backslash');
    });

    test('should not escape non-special characters', () {
      final result = parser.parse(r'This is \a normal');
      expect(result.length, 1);
      expect(result[0], isA<TextNode>());
      // \a is not a special escape, so backslash stays
      expect((result[0] as TextNode).content, contains(r'\'));
    });

    test('should mix escaped and non-escaped formatting', () {
      final result = parser.parse(r'This is \*escaped\* and **bold** end');
      // "This is " + "*" + "escaped" + "*" + " and " are merged into one TextNode
      // then BoldNode("bold"), then TextNode(" end")
      expect(result.length, 3);
      expect(result[0], isA<TextNode>());
      expect(
          (result[0] as TextNode).content, 'This is *escaped* and ');
      expect(result[1], isA<BoldNode>());
      expect(result[2], isA<TextNode>());
    });
  });

  group('URL Parentheses Nesting Tests', () {
    late InlineParser parser;

    setUp(() {
      parser = InlineParser();
    });

    test('should parse link with parentheses in URL', () {
      final result =
          parser.parse('[wiki](https://en.wikipedia.org/wiki/Dart_(language))');
      expect(result.length, 1);
      expect(result[0], isA<LinkNode>());
      final link = result[0] as LinkNode;
      expect(link.url, 'https://en.wikipedia.org/wiki/Dart_(language)');
    });

    test('should parse image with parentheses in URL', () {
      final result =
          parser.parse('![alt](https://example.com/image_(1).png)');
      expect(result.length, 1);
      expect(result[0], isA<ImageNode>());
      final image = result[0] as ImageNode;
      expect(image.url, 'https://example.com/image_(1).png');
    });

    test('should parse link with simple URL (no parens)', () {
      final result = parser.parse('[text](https://example.com)');
      expect(result.length, 1);
      expect(result[0], isA<LinkNode>());
      final link = result[0] as LinkNode;
      expect(link.url, 'https://example.com');
    });

    test('should parse link with multiple nested parens', () {
      final result =
          parser.parse('[text](https://example.com/a(b(c)))');
      expect(result.length, 1);
      expect(result[0], isA<LinkNode>());
      final link = result[0] as LinkNode;
      expect(link.url, 'https://example.com/a(b(c))');
    });
  });

  group('Recursion Depth Limit Tests', () {
    late InlineParser parser;

    setUp(() {
      parser = InlineParser();
    });

    test('should handle deeply nested bold without stack overflow', () {
      // Build deeply nested bold: ****...**text**..****
      var input = 'text';
      for (var i = 0; i < 20; i++) {
        input = '**$input**';
      }
      // Should not throw - returns plain text at max depth
      final result = parser.parse(input);
      expect(result, isNotEmpty);
    });
  });
}
