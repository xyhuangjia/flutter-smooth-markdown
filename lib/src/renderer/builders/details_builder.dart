import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
import '../widget_builder.dart';

/// Builder for details/summary collapsible blocks
class DetailsBuilder extends MarkdownWidgetBuilder {
  /// Creates a new details builder
  const DetailsBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is DetailsNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final detailsNode = node as DetailsNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return _DetailsWidget(
      summary: renderer.render(detailsNode.summary, context: context),
      isOpen: detailsNode.isOpen,
      styleSheet: styleSheet,
      children: detailsNode.children.isEmpty
          ? null
          : renderer.render(detailsNode.children, context: context),
    );
  }
}

/// Stateful widget for rendering details/summary blocks
class _DetailsWidget extends StatefulWidget {
  const _DetailsWidget({
    required this.summary,
    required this.styleSheet,
    this.children,
    this.isOpen = false,
  });

  final Widget summary;
  final Widget? children;
  final bool isOpen;
  final MarkdownStyleSheet styleSheet;

  @override
  State<_DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<_DetailsWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isOpen;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.styleSheet.horizontalRuleColor ?? Colors.grey.shade300;
    final textColor = widget.styleSheet.textStyle?.color ?? Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary (clickable header)
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DefaultTextStyle(
                      style: widget.styleSheet.paragraphStyle ?? const TextStyle(),
                      child: widget.summary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (collapsible)
          if (_isExpanded && widget.children != null)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: borderColor,
                  ),
                ),
              ),
              child: widget.children,
            ),
        ],
      ),
    );
  }
}
