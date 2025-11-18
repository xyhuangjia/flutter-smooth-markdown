import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for inline math nodes (LaTeX formulas)
class InlineMathBuilder extends MarkdownWidgetBuilder {
  /// Creates a new inline math builder
  const InlineMathBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is InlineMathNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final mathNode = node as InlineMathNode;

    return Math.tex(
      mathNode.latex,
      textStyle: styleSheet.textStyle,
      mathStyle: MathStyle.text,
      options: MathOptions(
        fontSize: styleSheet.textStyle?.fontSize ?? 16,
        color: styleSheet.textStyle?.color ?? const Color(0xFF000000),
      ),
    );
  }
}
