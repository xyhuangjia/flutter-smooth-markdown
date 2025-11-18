import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for footnote reference nodes
///
/// Renders footnote references like [^1] as superscript text
class FootnoteReferenceBuilder extends MarkdownWidgetBuilder {
  /// Creates a new footnote reference builder
  const FootnoteReferenceBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is FootnoteReferenceNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final footnoteNode = node as FootnoteReferenceNode;

    // Render as superscript with the label in brackets
    return Text.rich(
      TextSpan(
        text: '[${footnoteNode.label}]',
        style: (styleSheet.textStyle ?? const TextStyle()).copyWith(
          fontSize: (styleSheet.textStyle?.fontSize ?? 16) * 0.75,
          // Use baseline offset to create superscript effect
          height: 0.5,
          color: styleSheet.linkStyle?.color ?? const Color(0xFF1976D2),
        ),
      ),
    );
  }
}
