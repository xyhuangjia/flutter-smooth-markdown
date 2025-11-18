import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
import '../widget_builder.dart';

/// Enhanced builder for blockquote nodes with icon and gradient
class EnhancedBlockquoteBuilder extends MarkdownWidgetBuilder {
  /// Creates a new enhanced blockquote builder
  const EnhancedBlockquoteBuilder({
    this.showIcon = true,
  });

  final bool showIcon;

  @override
  bool canBuild(MarkdownNode node) => node is BlockquoteNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final blockquoteNode = node as BlockquoteNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return _EnhancedBlockquoteWidget(
      children: blockquoteNode.children,
      renderer: renderer,
      styleSheet: styleSheet,
      context: context,
      showIcon: showIcon,
    );
  }
}

class _EnhancedBlockquoteWidget extends StatelessWidget {
  const _EnhancedBlockquoteWidget({
    required this.children,
    required this.renderer,
    required this.styleSheet,
    required this.context,
    required this.showIcon,
  });

  final List<MarkdownNode> children;
  final MarkdownRenderer renderer;
  final MarkdownStyleSheet styleSheet;
  final MarkdownRenderContext context;
  final bool showIcon;

  @override
  Widget build(BuildContext buildContext) {
    final brightness = Theme.of(buildContext).brightness;
    final primaryColor = Theme.of(buildContext).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.grey[50]!, Colors.grey[100]!],
        ),
        border: Border(
          left: BorderSide(
            width: 4,
            color: primaryColor.withValues(alpha: 0.6),
          ),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: styleSheet.blockquotePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.format_quote,
              size: 24,
              color: primaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children
                  .map((child) => renderer.render([child], context: context))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
