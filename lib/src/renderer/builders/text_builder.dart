import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for text nodes
class TextBuilder extends MarkdownWidgetBuilder {
  /// Creates a new text builder
  const TextBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is TextNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final textNode = node as TextNode;

    return Text(
      textNode.content,
      style: styleSheet.textStyle,
    );
  }
}
