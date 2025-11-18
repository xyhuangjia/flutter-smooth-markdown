import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Enhanced builder for header nodes with decorative elements
class EnhancedHeaderBuilder extends MarkdownWidgetBuilder {
  /// Creates a new enhanced header builder
  const EnhancedHeaderBuilder({
    this.showBottomBorder = true,
  });

  final bool showBottomBorder;

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

    return _EnhancedHeaderWidget(
      level: headerNode.level,
      content: headerNode.content,
      style: style,
      showBottomBorder: showBottomBorder,
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

class _EnhancedHeaderWidget extends StatelessWidget {
  const _EnhancedHeaderWidget({
    required this.level,
    required this.content,
    required this.style,
    required this.showBottomBorder,
  });

  final int level;
  final String content;
  final TextStyle? style;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final showBorder = showBottomBorder && level <= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (level <= 2)
                Container(
                  width: 4,
                  height: style?.fontSize ?? 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Expanded(
                child: Text(
                  content,
                  style: style,
                ),
              ),
            ],
          ),
        ),
        if (showBorder)
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
