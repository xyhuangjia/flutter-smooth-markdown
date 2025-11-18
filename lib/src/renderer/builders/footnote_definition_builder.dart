import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
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

    // Create a temporary renderer to render inline content
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    final content = renderer.renderInline(
      footnoteNode.children,
      styleSheet.textStyle,
      context,
    );

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
