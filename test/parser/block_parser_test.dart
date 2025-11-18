import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_smooth_markdown/src/parser/block_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockParser Tests', () {
    late BlockParser parser;

    setUp(() {
      parser = BlockParser();
    });

    group('Header Parsing', () {
      test('should parse H1 header', () {
        final result = parser.parse('# Hello World');
        expect(result.length, 1);
        expect(result[0], isA<HeaderNode>());
        final header = result[0] as HeaderNode;
        expect(header.level, 1);
        expect(header.content, 'Hello World');
      });

      test('should parse H2-H6 headers', () {
        final markdown = '''
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header
''';
        final result = parser.parse(markdown);
        expect(result.length, 5);

        for (var i = 0; i < 5; i++) {
          expect(result[i], isA<HeaderNode>());
          final header = result[i] as HeaderNode;
          expect(header.level, i + 2);
        }
      });

      test('should require space after #', () {
        final result = parser.parse('#NoSpace');
        expect(result.length, 1);
        expect(result[0], isA<ParagraphNode>());
      });
    });

    group('Paragraph Parsing', () {
      test('should parse simple paragraph', () {
        final result = parser.parse('This is a paragraph.');
        expect(result.length, 1);
        expect(result[0], isA<ParagraphNode>());
        final para = result[0] as ParagraphNode;
        expect(para.children.length, 1);
        expect((para.children[0] as TextNode).content, 'This is a paragraph.');
      });

      test('should parse multi-line paragraph', () {
        final markdown = '''
This is line one.
This is line two.
This is line three.
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ParagraphNode>());
      });

      test('should split paragraphs on empty lines', () {
        final markdown = '''
First paragraph.

Second paragraph.
''';
        final result = parser.parse(markdown);
        expect(result.length, 2);
        expect(result[0], isA<ParagraphNode>());
        expect(result[1], isA<ParagraphNode>());
      });
    });

    group('Code Block Parsing', () {
      test('should parse code block without language', () {
        final markdown = '''
```
const x = 10;
console.log(x);
```
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<CodeBlockNode>());
        final codeBlock = result[0] as CodeBlockNode;
        expect(codeBlock.language, null);
        expect(codeBlock.code, 'const x = 10;\nconsole.log(x);');
      });

      test('should parse code block with language', () {
        final markdown = '''
```dart
void main() {
  print('Hello');
}
```
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<CodeBlockNode>());
        final codeBlock = result[0] as CodeBlockNode;
        expect(codeBlock.language, 'dart');
        expect(codeBlock.code, "void main() {\n  print('Hello');\n}");
      });

      test('should handle unclosed code block', () {
        final markdown = '''
```javascript
const x = 10;
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<CodeBlockNode>());
      });
    });

    group('Blockquote Parsing', () {
      test('should parse simple blockquote', () {
        final result = parser.parse('> This is a quote');
        expect(result.length, 1);
        expect(result[0], isA<BlockquoteNode>());
        final quote = result[0] as BlockquoteNode;
        expect(quote.children.length, 1);
      });

      test('should parse multi-line blockquote', () {
        final markdown = '''
> Line one
> Line two
> Line three
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<BlockquoteNode>());
      });

      test('should parse nested blockquote elements', () {
        final markdown = '''
> # Header in quote
>
> Paragraph in quote
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<BlockquoteNode>());
        final quote = result[0] as BlockquoteNode;
        expect(quote.children.length, 2);
        expect(quote.children[0], isA<HeaderNode>());
        expect(quote.children[1], isA<ParagraphNode>());
      });
    });

    group('List Parsing', () {
      test('should parse unordered list with -', () {
        final markdown = '''
- Item 1
- Item 2
- Item 3
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ListNode>());
        final list = result[0] as ListNode;
        expect(list.ordered, false);
        expect(list.items.length, 3);
      });

      test('should parse unordered list with *', () {
        final markdown = '''
* Item 1
* Item 2
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ListNode>());
        final list = result[0] as ListNode;
        expect(list.ordered, false);
      });

      test('should parse ordered list', () {
        final markdown = '''
1. First
2. Second
3. Third
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ListNode>());
        final list = result[0] as ListNode;
        expect(list.ordered, true);
        expect(list.items.length, 3);
        expect(list.startIndex, 1);
      });

      test('should parse task list', () {
        final markdown = '''
- [ ] Unchecked task
- [x] Checked task
- [X] Also checked
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ListNode>());
        final list = result[0] as ListNode;
        expect(list.items[0].checked, false);
        expect(list.items[1].checked, true);
        expect(list.items[2].checked, true);
      });

      test('should handle list with custom start index', () {
        final markdown = '''
5. Fifth item
6. Sixth item
''';
        final result = parser.parse(markdown);
        expect(result.length, 1);
        expect(result[0], isA<ListNode>());
        final list = result[0] as ListNode;
        expect(list.startIndex, 5);
      });
    });

    group('Horizontal Rule Parsing', () {
      test('should parse horizontal rule with ---', () {
        final result = parser.parse('---');
        expect(result.length, 1);
        expect(result[0], isA<HorizontalRuleNode>());
      });

      test('should parse horizontal rule with ***', () {
        final result = parser.parse('***');
        expect(result.length, 1);
        expect(result[0], isA<HorizontalRuleNode>());
      });

      test('should parse horizontal rule with ___', () {
        final result = parser.parse('___');
        expect(result.length, 1);
        expect(result[0], isA<HorizontalRuleNode>());
      });

      test('should require at least 3 characters', () {
        final result = parser.parse('--');
        expect(result.length, 1);
        expect(result[0], isA<ParagraphNode>());
      });
    });

    group('Mixed Content Parsing', () {
      test('should parse mixed block elements', () {
        final markdown = '''
# Title

This is a paragraph.

## Subtitle

- List item 1
- List item 2

> A quote

```dart
void main() {}
```

---

Final paragraph.
''';
        final result = parser.parse(markdown);
        expect(result.length, 8);
        expect(result[0], isA<HeaderNode>());
        expect(result[1], isA<ParagraphNode>());
        expect(result[2], isA<HeaderNode>());
        expect(result[3], isA<ListNode>());
        expect(result[4], isA<BlockquoteNode>());
        expect(result[5], isA<CodeBlockNode>());
        expect(result[6], isA<HorizontalRuleNode>());
        expect(result[7], isA<ParagraphNode>());
      });
    });

    group('Edge Cases', () {
      test('should handle empty input', () {
        final result = parser.parse('');
        expect(result, isEmpty);
      });

      test('should handle only whitespace', () {
        final result = parser.parse('   \n  \n  ');
        expect(result, isEmpty);
      });

      test('should handle single line', () {
        final result = parser.parse('Single line');
        expect(result.length, 1);
        expect(result[0], isA<ParagraphNode>());
      });
    });
  });
}
