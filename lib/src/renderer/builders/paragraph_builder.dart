import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
import '../widget_builder.dart';

/// Builder for paragraph nodes
class ParagraphBuilder extends MarkdownWidgetBuilder {
  /// Creates a new paragraph builder
  const ParagraphBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is ParagraphNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final paragraphNode = node as ParagraphNode;

    // Create a temporary renderer to render inline content
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return renderer.renderInline(
      paragraphNode.children,
      styleSheet.paragraphStyle,
      context,
    );
  }
}
