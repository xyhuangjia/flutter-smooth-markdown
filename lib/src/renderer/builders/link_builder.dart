import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for link nodes
class LinkBuilder extends MarkdownWidgetBuilder {
  /// Creates a new link builder
  const LinkBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is LinkNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final linkNode = node as LinkNode;
    final inlineRenderer = context.inlineRenderer;

    // Render link text with link style
    Widget linkWidget;
    if (inlineRenderer != null) {
      linkWidget = inlineRenderer(linkNode.children, styleSheet.linkStyle);
    } else {
      // Fallback
      final text = linkNode.children.whereType<TextNode>().map((n) => n.content).join();
      linkWidget = Text(text, style: styleSheet.linkStyle);
    }

    // Wrap in GestureDetector for tap handling
    return GestureDetector(
      onTap: () {
        context.onTapLink?.call(linkNode.url);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: linkWidget,
      ),
    );
  }
}
