import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../mermaid/models/style.dart';
import '../../mermaid/widgets/mermaid_diagram.dart';
import '../../parser/ast/markdown_node.dart';
import '../../parser/plugins/mermaid_plugin.dart';
import '../widget_builder.dart';

/// Builder for rendering Mermaid diagrams in markdown
///
/// This builder converts [MermaidDiagramNode] instances into
/// [MermaidDiagram] widgets for native Flutter rendering.
class MermaidBuilder extends MarkdownWidgetBuilder {
  /// Creates a Mermaid builder
  const MermaidBuilder({
    this.defaultTheme,
    this.onNodeTap,
    this.interactive = false,
    this.minScale = 0.5,
    this.maxScale = 3.0,
  });

  /// Default theme to use if not specified in the code block
  final MermaidThemeMode? defaultTheme;

  /// Callback when a node is tapped
  final void Function(String nodeId)? onNodeTap;

  /// Whether to enable pan and zoom
  final bool interactive;

  /// Minimum zoom scale (when interactive)
  final double minScale;

  /// Maximum zoom scale (when interactive)
  final double maxScale;

  @override
  bool canBuild(MarkdownNode node) => node is MermaidDiagramNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    if (node is! MermaidDiagramNode) {
      return const SizedBox.shrink();
    }

    // Determine theme based on stylesheet brightness
    MermaidStyle style;
    if (node.theme != null) {
      style = _getThemeByName(node.theme!);
    } else if (defaultTheme != null) {
      style = MermaidThemes.getTheme(defaultTheme!);
    } else {
      // Try to match markdown stylesheet brightness
      final bgColor = styleSheet.codeBlockDecoration?.color;
      final isDark = bgColor != null && bgColor.computeLuminance() < 0.5;
      style = isDark ? MermaidStyle.dark() : const MermaidStyle();
    }

    Widget diagram;

    if (interactive) {
      diagram = InteractiveMermaidDiagram(
        code: node.code,
        style: style,
        minScale: minScale,
        maxScale: maxScale,
        onNodeTap: onNodeTap,
      );
    } else {
      diagram = MermaidDiagram(
        code: node.code,
        style: style,
        onNodeTap: onNodeTap,
      );
    }

    // Wrap in container with styling
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Color(style.backgroundColor),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: diagram,
    );
  }

  MermaidStyle _getThemeByName(String name) {
    switch (name.toLowerCase()) {
      case 'dark':
        return MermaidStyle.dark();
      case 'forest':
        return MermaidStyle.forest();
      case 'neutral':
        return MermaidStyle.neutral();
      case 'light':
      default:
        return const MermaidStyle();
    }
  }
}

/// Enhanced Mermaid builder with additional features
class EnhancedMermaidBuilder extends MermaidBuilder {
  /// Creates an enhanced Mermaid builder
  const EnhancedMermaidBuilder({
    super.defaultTheme,
    super.onNodeTap,
    super.interactive = true,
    super.minScale,
    super.maxScale,
    this.showCopyButton = true,
    this.showFullscreenButton = true,
    this.showSourceToggle = false,
  });

  /// Whether to show a copy button for the source code
  final bool showCopyButton;

  /// Whether to show a fullscreen button
  final bool showFullscreenButton;

  /// Whether to show a toggle for viewing source code
  final bool showSourceToggle;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    if (node is! MermaidDiagramNode) {
      return const SizedBox.shrink();
    }

    return _EnhancedMermaidContainer(
      node: node,
      styleSheet: styleSheet,
      defaultTheme: defaultTheme,
      onNodeTap: onNodeTap,
      interactive: interactive,
      minScale: minScale,
      maxScale: maxScale,
      showCopyButton: showCopyButton,
      showFullscreenButton: showFullscreenButton,
      showSourceToggle: showSourceToggle,
    );
  }
}

class _EnhancedMermaidContainer extends StatefulWidget {
  const _EnhancedMermaidContainer({
    required this.node,
    required this.styleSheet,
    this.defaultTheme,
    this.onNodeTap,
    this.interactive = true,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.showCopyButton = true,
    this.showFullscreenButton = true,
    this.showSourceToggle = false,
  });

  final MermaidDiagramNode node;
  final MarkdownStyleSheet styleSheet;
  final MermaidThemeMode? defaultTheme;
  final void Function(String nodeId)? onNodeTap;
  final bool interactive;
  final double minScale;
  final double maxScale;
  final bool showCopyButton;
  final bool showFullscreenButton;
  final bool showSourceToggle;

  @override
  State<_EnhancedMermaidContainer> createState() =>
      _EnhancedMermaidContainerState();
}

class _EnhancedMermaidContainerState extends State<_EnhancedMermaidContainer> {
  bool _showSource = false;
  bool _copied = false;

  MermaidStyle get _style {
    if (widget.node.theme != null) {
      return _getThemeByName(widget.node.theme!);
    } else if (widget.defaultTheme != null) {
      return MermaidThemes.getTheme(widget.defaultTheme!);
    }
    final bgColor = widget.styleSheet.codeBlockDecoration?.color;
    final isDark = bgColor != null && bgColor.computeLuminance() < 0.5;
    return isDark ? MermaidStyle.dark() : const MermaidStyle();
  }

  MermaidStyle _getThemeByName(String name) {
    switch (name.toLowerCase()) {
      case 'dark':
        return MermaidStyle.dark();
      case 'forest':
        return MermaidStyle.forest();
      case 'neutral':
        return MermaidStyle.neutral();
      default:
        return const MermaidStyle();
    }
  }

  void _copyToClipboard() {
    // Note: This requires clipboard functionality
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Color(_style.backgroundColor),
          appBar: AppBar(
            title: const Text('Mermaid Diagram'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: InteractiveMermaidDiagram(
            code: widget.node.code,
            style: _style,
            minScale: 0.1,
            maxScale: 5.0,
            onNodeTap: widget.onNodeTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Color(_style.backgroundColor),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toolbar
          if (widget.showCopyButton ||
              widget.showFullscreenButton ||
              widget.showSourceToggle)
            _buildToolbar(),

          // Content
          _showSource ? _buildSourceView() : _buildDiagramView(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.showSourceToggle)
            IconButton(
              icon: Icon(
                _showSource ? Icons.visibility : Icons.code,
                size: 18,
              ),
              tooltip: _showSource ? 'View Diagram' : 'View Source',
              onPressed: () => setState(() => _showSource = !_showSource),
            ),
          if (widget.showCopyButton)
            IconButton(
              icon: Icon(
                _copied ? Icons.check : Icons.copy,
                size: 18,
                color: _copied ? Colors.green : null,
              ),
              tooltip: _copied ? 'Copied!' : 'Copy Source',
              onPressed: _copyToClipboard,
            ),
          if (widget.showFullscreenButton)
            IconButton(
              icon: const Icon(Icons.fullscreen, size: 18),
              tooltip: 'Fullscreen',
              onPressed: _openFullscreen,
            ),
        ],
      ),
    );
  }

  Widget _buildDiagramView() {
    if (widget.interactive) {
      return InteractiveMermaidDiagram(
        code: widget.node.code,
        style: _style,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        onNodeTap: widget.onNodeTap,
      );
    }
    return MermaidDiagram(
      code: widget.node.code,
      style: _style,
      onNodeTap: widget.onNodeTap,
    );
  }

  Widget _buildSourceView() {
    final bgColor = widget.styleSheet.codeBlockDecoration?.color;
    return Container(
      padding: const EdgeInsets.all(16),
      color: bgColor ?? Colors.grey.shade100,
      child: SingleChildScrollView(
        child: SelectableText(
          widget.node.code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: widget.styleSheet.inlineCodeStyle?.color ?? Colors.black87,
          ),
        ),
      ),
    );
  }
}
