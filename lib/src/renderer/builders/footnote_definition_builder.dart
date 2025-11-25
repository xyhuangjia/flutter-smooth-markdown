import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for footnote definition nodes
///
/// Renders footnote definitions like [^1]: content as a labeled paragraph
class FootnoteDefinitionBuilder extends MarkdownWidgetBuilder {
  /// Creates a new footnote definition builder
  const FootnoteDefinitionBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is FootnoteDefinitionNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final footnoteNode = node as FootnoteDefinitionNode;

    Widget content;
    final inlineRenderer = context.inlineRenderer;
    if (inlineRenderer != null) {
      content = inlineRenderer(footnoteNode.children, styleSheet.textStyle);
    } else {
      // Fallback: extract text
      final text = footnoteNode.children
          .whereType<TextNode>()
          .map((n) => n.content)
          .join();
      content = Text(text, style: styleSheet.textStyle);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            '[${footnoteNode.label}]: ',
            style: (styleSheet.textStyle ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              color: styleSheet.linkStyle?.color ?? const Color(0xFF1976D2),
            ),
          ),
          // Content
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
