import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
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
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    // Render link text with link style
    final linkWidget = renderer.renderInline(
      linkNode.children,
      styleSheet.linkStyle,
      context,
    );

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
