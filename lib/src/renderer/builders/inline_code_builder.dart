import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for inline code nodes
class InlineCodeBuilder extends MarkdownWidgetBuilder {
  /// Creates a new inline code builder
  const InlineCodeBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is InlineCodeNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final codeNode = node as InlineCodeNode;

    return Text(
      codeNode.code,
      style: styleSheet.inlineCodeStyle,
    );
  }
}
