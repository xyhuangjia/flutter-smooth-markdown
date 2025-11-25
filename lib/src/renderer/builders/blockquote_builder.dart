import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for blockquote nodes
class BlockquoteBuilder extends MarkdownWidgetBuilder {
  /// Creates a new blockquote builder
  const BlockquoteBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is BlockquoteNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final quoteNode = node as BlockquoteNode;
    final blockRenderer = context.blockRenderer;

    Widget content;
    if (blockRenderer != null) {
      content = blockRenderer(quoteNode.children);
    } else {
      // Fallback: extract text
      content = Text(_extractText(quoteNode.children));
    }

    return Container(
      decoration: styleSheet.blockquoteDecoration,
      padding: styleSheet.blockquotePadding,
      child: content,
    );
  }

  String _extractText(List<MarkdownNode> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is ParagraphNode) {
        for (final child in node.children) {
          if (child is TextNode) {
            buffer.write(child.content);
          }
        }
        buffer.write('\n');
      }
    }
    return buffer.toString().trim();
  }
}
