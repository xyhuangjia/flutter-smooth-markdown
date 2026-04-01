import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Enhanced builder for link nodes with hover effects
class EnhancedLinkBuilder extends MarkdownWidgetBuilder {
  /// Creates a new enhanced link builder
  const EnhancedLinkBuilder({
    this.showExternalIcon = true,
  });

  final bool showExternalIcon;

  @override
  bool canBuild(MarkdownNode node) => node is LinkNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final linkNode = node as LinkNode;

    return _EnhancedLinkWidget(
      url: linkNode.url,
      children: linkNode.children,
      styleSheet: styleSheet,
      context: context,
      showExternalIcon: showExternalIcon,
    );
  }
}

class _EnhancedLinkWidget extends StatefulWidget {
  const _EnhancedLinkWidget({
    required this.url,
    required this.children,
    required this.styleSheet,
    required this.context,
    required this.showExternalIcon,
  });

  final String url;
  final List<MarkdownNode> children;
  final MarkdownStyleSheet styleSheet;
  final MarkdownRenderContext context;
  final bool showExternalIcon;

  @override
  State<_EnhancedLinkWidget> createState() => _EnhancedLinkWidgetState();
}

class _EnhancedLinkWidgetState extends State<_EnhancedLinkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isExternalLink() {
    return widget.url.startsWith('http://') ||
        widget.url.startsWith('https://');
  }

  Widget _renderLinkContent() {
    final inlineRenderer = widget.context.inlineRenderer;
    if (inlineRenderer != null) {
      return inlineRenderer(widget.children, widget.styleSheet.linkStyle);
    }
    // Fallback: extract text
    final text = widget.children
        .whereType<TextNode>()
        .map((n) => n.content)
        .join();
    return Text(text, style: widget.styleSheet.linkStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: widget.url,
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.context.onTapLink?.call(widget.url);
          },
          child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: (widget.styleSheet.linkStyle?.color ?? Colors.blue)
                        .withValues(alpha: 0.3 + (_animation.value * 0.7)),
                    width: 1 + (_animation.value * 1),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: _renderLinkContent(),
                  ),
                  if (widget.showExternalIcon && _isExternalLink())
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: widget.styleSheet.linkStyle?.color,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
