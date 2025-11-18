import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for horizontal rule nodes
class HorizontalRuleBuilder extends MarkdownWidgetBuilder {
  /// Creates a new horizontal rule builder
  const HorizontalRuleBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is HorizontalRuleNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    return Container(
      height: styleSheet.horizontalRuleThickness ?? 1.0,
      color: styleSheet.horizontalRuleColor ?? Colors.grey[400],
    );
  }
}
