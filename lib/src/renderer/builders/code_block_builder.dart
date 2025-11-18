import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for code block nodes
class CodeBlockBuilder extends MarkdownWidgetBuilder {
  /// Creates a new code block builder
  const CodeBlockBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is CodeBlockNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final codeBlockNode = node as CodeBlockNode;

    // Use custom builder if provided
    if (context.codeBuilder != null) {
      return context.codeBuilder!(
        codeBlockNode.code,
        codeBlockNode.language,
      );
    }

    // Default rendering
    return Container(
      decoration: styleSheet.codeBlockDecoration,
      padding: styleSheet.codeBlockPadding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          codeBlockNode.code,
          style: styleSheet.codeBlockStyle,
        ),
      ),
    );
  }
}
