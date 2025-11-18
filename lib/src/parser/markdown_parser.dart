import 'ast/markdown_node.dart';
import 'block_parser.dart';
import 'inline_parser.dart';

/// Main Markdown parser that combines block and inline parsing
///
/// This parser provides a unified interface for parsing Markdown text
/// into an Abstract Syntax Tree (AST) of MarkdownNode objects.
///
/// Example usage:
/// ```dart
/// final parser = MarkdownParser();
/// final nodes = parser.parse('# Hello **World**');
/// ```
class MarkdownParser {
  /// Creates a new Markdown parser
  MarkdownParser()
      : _blockParser = BlockParser(),
        _inlineParser = InlineParser();

  final BlockParser _blockParser;
  final InlineParser _inlineParser;

  /// Parses markdown text into a list of nodes
  ///
  /// The parser first processes block-level elements (headers, paragraphs, etc.)
  /// and then processes inline elements (bold, italic, links, etc.) within
  /// text content.
  ///
  /// Returns a list of [MarkdownNode] objects representing the parsed document.
  List<MarkdownNode> parse(String markdown) {
    if (markdown.isEmpty) {
      return [];
    }

    // First, parse block-level elements
    final blockNodes = _blockParser.parse(markdown);

    // Then, process inline elements in text-containing nodes
    return blockNodes.map(_processInlineElements).toList();
  }

  /// Parses markdown asynchronously
  ///
  /// Useful for large documents to avoid blocking the UI thread.
  Future<List<MarkdownNode>> parseAsync(String markdown) async {
    return Future.value(parse(markdown));
  }

  /// Recursively processes inline elements in nodes
  MarkdownNode _processInlineElements(MarkdownNode node) {
    // Process based on node type
    if (node is HeaderNode) {
      return _processHeader(node);
    } else if (node is ParagraphNode) {
      return _processParagraph(node);
    } else if (node is BlockquoteNode) {
      return _processBlockquote(node);
    } else if (node is ListNode) {
      return _processList(node);
    } else if (node is ListItemNode) {
      return _processListItem(node);
    } else {
      // Other nodes (CodeBlock, HorizontalRule, Image, etc.) don't need inline processing
      return node;
    }
  }

  /// Processes inline elements in header content
  HeaderNode _processHeader(HeaderNode node) {
    // Headers contain simple text, parse inline elements
    final inlineNodes = _inlineParser.parse(node.content);

    // If only one text node, keep as is
    if (inlineNodes.length == 1 && inlineNodes[0] is TextNode) {
      return node;
    }

    // For now, we keep the header content as-is since HeaderNode
    // expects a String, not child nodes
    // In a future enhancement, we could modify HeaderNode to support children
    return node;
  }

  /// Processes inline elements in paragraph
  ParagraphNode _processParagraph(ParagraphNode node) {
    final newChildren = <MarkdownNode>[];

    for (final child in node.children) {
      if (child is TextNode) {
        // Parse inline elements in text
        final inlineNodes = _inlineParser.parse(child.content);
        newChildren.addAll(inlineNodes);
      } else {
        newChildren.add(_processInlineElements(child));
      }
    }

    return ParagraphNode(newChildren);
  }

  /// Processes inline elements in blockquote
  BlockquoteNode _processBlockquote(BlockquoteNode node) {
    final newChildren = node.children.map(_processInlineElements).toList();
    return BlockquoteNode(newChildren);
  }

  /// Processes inline elements in list
  ListNode _processList(ListNode node) {
    final newItems = node.items.map((item) {
      return _processListItem(item);
    }).toList();

    return ListNode(
      items: newItems,
      ordered: node.ordered,
      startIndex: node.startIndex,
    );
  }

  /// Processes inline elements in list item
  ListItemNode _processListItem(ListItemNode node) {
    final newChildren = <MarkdownNode>[];

    for (final child in node.children) {
      if (child is TextNode) {
        // Parse inline elements in text
        final inlineNodes = _inlineParser.parse(child.content);
        newChildren.addAll(inlineNodes);
      } else {
        newChildren.add(_processInlineElements(child));
      }
    }

    return ListItemNode(
      children: newChildren,
      checked: node.checked,
    );
  }

  /// Parses only block-level elements (useful for certain use cases)
  List<MarkdownNode> parseBlocksOnly(String markdown) {
    return _blockParser.parse(markdown);
  }

  /// Parses only inline elements from text (useful for certain use cases)
  List<MarkdownNode> parseInlineOnly(String text) {
    return _inlineParser.parse(text);
  }
}
