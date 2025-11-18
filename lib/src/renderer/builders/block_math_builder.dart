import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for block math nodes (display LaTeX formulas)
class BlockMathBuilder extends MarkdownWidgetBuilder {
  /// Creates a new block math builder
  const BlockMathBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is BlockMathNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final mathNode = node as BlockMathNode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Math.tex(
          mathNode.latex,
          textStyle: styleSheet.textStyle,
          mathStyle: MathStyle.display,
          options: MathOptions(
            fontSize: (styleSheet.textStyle?.fontSize ?? 16) * 1.25,
            color: styleSheet.textStyle?.color ?? const Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}
