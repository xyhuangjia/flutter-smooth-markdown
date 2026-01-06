import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for header nodes (H1-H6)
class HeaderBuilder extends MarkdownWidgetBuilder {
  /// Creates a new header builder
  const HeaderBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is HeaderNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final headerNode = node as HeaderNode;

    final style = _getHeaderStyle(headerNode.level, styleSheet);

    // If header has parsed inline children, use inlineRenderer to support formatting
    if (headerNode.children != null && headerNode.children!.isNotEmpty) {
      final inlineRenderer = context.inlineRenderer;
      if (inlineRenderer != null) {
        return inlineRenderer(headerNode.children!, style);
      }
    }

    // Fallback: render as plain text
    return Text(
      headerNode.content,
      style: style,
    );
  }

  TextStyle? _getHeaderStyle(int level, MarkdownStyleSheet styleSheet) {
    switch (level) {
      case 1:
        return styleSheet.h1Style;
      case 2:
        return styleSheet.h2Style;
      case 3:
        return styleSheet.h3Style;
      case 4:
        return styleSheet.h4Style;
      case 5:
        return styleSheet.h5Style;
      case 6:
        return styleSheet.h6Style;
      default:
        return styleSheet.textStyle;
    }
  }
}
