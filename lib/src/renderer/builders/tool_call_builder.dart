import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../../parser/plugins/tool_call_plugin.dart';
import '../widget_builder.dart';

/// Builder for AI tool/function call blocks
///
/// Renders tool calls with status indicators, tool name,
/// parameters, and results in a distinctive container.
class ToolCallBuilder extends MarkdownWidgetBuilder {
  /// Creates a new tool call builder
  const ToolCallBuilder({
    this.onToolCallTap,
    this.showParameters = true,
    this.showResult = true,
  });

  /// Callback when tool call is tapped
  final void Function(ToolCallNode toolCall)? onToolCallTap;

  /// Whether to show parameters
  final bool showParameters;

  /// Whether to show result
  final bool showResult;

  @override
  bool canBuild(MarkdownNode node) => node is ToolCallNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final toolCallNode = node as ToolCallNode;

    return _ToolCallWidget(
      toolCall: toolCallNode,
      styleSheet: styleSheet,
      onTap: onToolCallTap,
      showParameters: showParameters,
      showResult: showResult,
      selectable: context.selectable,
    );
  }
}

class _ToolCallWidget extends StatefulWidget {
  const _ToolCallWidget({
    required this.toolCall,
    required this.styleSheet,
    this.onTap,
    this.showParameters = true,
    this.showResult = true,
    this.selectable = false,
  });

  final ToolCallNode toolCall;
  final MarkdownStyleSheet styleSheet;
  final void Function(ToolCallNode toolCall)? onTap;
  final bool showParameters;
  final bool showResult;
  final bool selectable;

  @override
  State<_ToolCallWidget> createState() => _ToolCallWidgetState();
}

class _ToolCallWidgetState extends State<_ToolCallWidget> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    switch (widget.toolCall.status) {
      case ToolCallStatus.running:
        return const Color(0xFFF59E0B); // Amber
      case ToolCallStatus.completed:
        return const Color(0xFF10B981); // Green
      case ToolCallStatus.failed:
        return const Color(0xFFEF4444); // Red
      case ToolCallStatus.cancelled:
        return const Color(0xFF6B7280); // Gray
      case ToolCallStatus.pending:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData _getStatusIcon() {
    switch (widget.toolCall.status) {
      case ToolCallStatus.running:
        return Icons.sync;
      case ToolCallStatus.completed:
        return Icons.check_circle_outline;
      case ToolCallStatus.failed:
        return Icons.error_outline;
      case ToolCallStatus.cancelled:
        return Icons.cancel_outlined;
      case ToolCallStatus.pending:
        return Icons.schedule;
    }
  }

  String _getStatusText() {
    switch (widget.toolCall.status) {
      case ToolCallStatus.running:
        return 'Running';
      case ToolCallStatus.completed:
        return 'Completed';
      case ToolCallStatus.failed:
        return 'Failed';
      case ToolCallStatus.cancelled:
        return 'Cancelled';
      case ToolCallStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFFAFAFC);
    final borderColor = isDark
        ? const Color(0xFF3E3E4E)
        : const Color(0xFFE5E7EB);
    final textColor = isDark
        ? Colors.white70
        : const Color(0xFF374151);
    final secondaryTextColor = isDark
        ? Colors.white54
        : const Color(0xFF6B7280);

    final statusColor = _getStatusColor();
    final hasDetails = (widget.showParameters &&
            widget.toolCall.parameters != null) ||
        (widget.showResult && widget.toolCall.result != null) ||
        widget.toolCall.errorMessage != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: hasDetails
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            borderRadius: BorderRadius.circular(7),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tool icon
                  Icon(
                    Icons.build_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  // Tool name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.toolCall.toolName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (widget.toolCall.toolId != null)
                          Text(
                            'ID: ${widget.toolCall.toolId}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.toolCall.status == ToolCallStatus.running)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          )
                        else
                          Icon(
                            _getStatusIcon(),
                            size: 12,
                            color: statusColor,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasDetails) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Parameters
                  if (widget.showParameters &&
                      widget.toolCall.parameters != null)
                    _buildSection(
                      'Parameters',
                      widget.toolCall.parameters.toString(),
                      textColor,
                      secondaryTextColor,
                      borderColor,
                    ),
                  // Result
                  if (widget.showResult && widget.toolCall.result != null)
                    _buildSection(
                      'Result',
                      widget.toolCall.result!,
                      textColor,
                      secondaryTextColor,
                      borderColor,
                    ),
                  // Error
                  if (widget.toolCall.errorMessage != null)
                    _buildSection(
                      'Error',
                      widget.toolCall.errorMessage!,
                      const Color(0xFFEF4444),
                      secondaryTextColor,
                      borderColor,
                      isError: true,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor, {
    bool isError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isError ? textColor : secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          widget.selectable
              ? Text(
                  content,
                  style: TextStyle(
                    color: isError ? textColor : textColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                )
              : SelectableText(
                  content,
                  style: TextStyle(
                    color: isError ? textColor : textColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
        ],
      ),
    );
  }
}
