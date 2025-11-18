import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
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
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return Container(
      decoration: styleSheet.blockquoteDecoration,
      padding: styleSheet.blockquotePadding,
      child: renderer.render(quoteNode.children, context: context),
    );
  }
}
