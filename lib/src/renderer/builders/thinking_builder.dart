import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../../parser/plugins/thinking_plugin.dart';
import '../widget_builder.dart';

/// Builder for AI thinking/reasoning blocks
///
/// Renders thinking content in a collapsible container with
/// a distinctive visual style to differentiate it from regular content.
class ThinkingBuilder extends MarkdownWidgetBuilder {
  /// Creates a new thinking builder
  const ThinkingBuilder({
    this.headerText = 'Thinking...',
    this.expandedHeaderText = 'Thinking',
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  /// Text displayed in header when collapsed
  final String headerText;

  /// Text displayed in header when expanded
  final String expandedHeaderText;

  /// Background color for the thinking block
  final Color? backgroundColor;

  /// Border color for the thinking block
  final Color? borderColor;

  /// Icon color
  final Color? iconColor;

  @override
  bool canBuild(MarkdownNode node) => node is ThinkingNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final thinkingNode = node as ThinkingNode;

    return _ThinkingWidget(
      content: thinkingNode.content,
      isCollapsed: thinkingNode.isCollapsed,
      styleSheet: styleSheet,
      headerText: headerText,
      expandedHeaderText: expandedHeaderText,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      iconColor: iconColor,
    );
  }
}

class _ThinkingWidget extends StatefulWidget {
  const _ThinkingWidget({
    required this.content,
    required this.styleSheet,
    this.isCollapsed = true,
    this.headerText = 'Thinking...',
    this.expandedHeaderText = 'Thinking',
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  final String content;
  final bool isCollapsed;
  final MarkdownStyleSheet styleSheet;
  final String headerText;
  final String expandedHeaderText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  @override
  State<_ThinkingWidget> createState() => _ThinkingWidgetState();
}

class _ThinkingWidgetState extends State<_ThinkingWidget>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.isCollapsed;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.backgroundColor ??
        (isDark
            ? const Color(0xFF2D2D3D)
            : const Color(0xFFF5F5F7));
    final borderClr = widget.borderColor ??
        (isDark
            ? const Color(0xFF4A4A5A)
            : const Color(0xFFE0E0E5));
    final iconClr = widget.iconColor ??
        (isDark
            ? const Color(0xFF9090A0)
            : const Color(0xFF606070));
    final textColor = widget.styleSheet.textStyle?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderClr),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 18,
                    color: iconClr,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isExpanded
                          ? widget.expandedHeaderText
                          : widget.headerText,
                      style: TextStyle(
                        color: iconClr,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: iconClr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SelectableText(
                widget.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
