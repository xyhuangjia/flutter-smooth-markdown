import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../../parser/plugins/artifact_plugin.dart';
import '../widget_builder.dart';

/// Builder for AI-generated artifact blocks
///
/// Renders artifacts with a header showing title/type, copy button,
/// and syntax-highlighted content for code artifacts.
class ArtifactBuilder extends MarkdownWidgetBuilder {
  /// Creates a new artifact builder
  const ArtifactBuilder({
    this.onArtifactTap,
    this.showCopyButton = true,
    this.showDownloadButton = false,
  });

  /// Callback when artifact is tapped
  final void Function(ArtifactNode artifact)? onArtifactTap;

  /// Whether to show copy button
  final bool showCopyButton;

  /// Whether to show download button
  final bool showDownloadButton;

  @override
  bool canBuild(MarkdownNode node) => node is ArtifactNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final artifactNode = node as ArtifactNode;

    return _ArtifactWidget(
      artifact: artifactNode,
      styleSheet: styleSheet,
      onTap: onArtifactTap,
      showCopyButton: showCopyButton,
      showDownloadButton: showDownloadButton,
    );
  }
}

class _ArtifactWidget extends StatefulWidget {
  const _ArtifactWidget({
    required this.artifact,
    required this.styleSheet,
    this.onTap,
    this.showCopyButton = true,
    this.showDownloadButton = false,
  });

  final ArtifactNode artifact;
  final MarkdownStyleSheet styleSheet;
  final void Function(ArtifactNode artifact)? onTap;
  final bool showCopyButton;
  final bool showDownloadButton;

  @override
  State<_ArtifactWidget> createState() => _ArtifactWidgetState();
}

class _ArtifactWidgetState extends State<_ArtifactWidget> {
  bool _isCopied = false;

  IconData _getArtifactIcon() {
    switch (widget.artifact.artifactType) {
      case ArtifactType.code:
        return Icons.code;
      case ArtifactType.document:
        return Icons.article_outlined;
      case ArtifactType.html:
        return Icons.html;
      case ArtifactType.svg:
        return Icons.image_outlined;
      case ArtifactType.component:
        return Icons.widgets_outlined;
      case ArtifactType.mermaid:
        return Icons.schema_outlined;
      case ArtifactType.custom:
        return Icons.extension_outlined;
    }
  }

  String _getTypeLabel() {
    switch (widget.artifact.artifactType) {
      case ArtifactType.code:
        return widget.artifact.language?.toUpperCase() ?? 'CODE';
      case ArtifactType.document:
        return 'DOCUMENT';
      case ArtifactType.html:
        return 'HTML';
      case ArtifactType.svg:
        return 'SVG';
      case ArtifactType.component:
        return 'COMPONENT';
      case ArtifactType.mermaid:
        return 'DIAGRAM';
      case ArtifactType.custom:
        return widget.artifact.customType?.toUpperCase() ?? 'ARTIFACT';
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.artifact.content));
    if (mounted) {
      setState(() {
        _isCopied = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerBgColor = isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFF8F9FA);
    final contentBgColor = isDark
        ? const Color(0xFF282838)
        : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF3E3E4E)
        : const Color(0xFFE5E7EB);
    final headerTextColor = isDark
        ? Colors.white70
        : const Color(0xFF374151);
    final labelColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
              border: Border(
                bottom: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getArtifactIcon(),
                  size: 16,
                  color: labelColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.artifact.title != null)
                        Text(
                          widget.artifact.title!,
                          style: TextStyle(
                            color: headerTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showCopyButton)
                  IconButton(
                    icon: Icon(
                      _isCopied ? Icons.check : Icons.copy_outlined,
                      size: 16,
                    ),
                    color: _isCopied ? Colors.green : headerTextColor,
                    onPressed: _copyToClipboard,
                    tooltip: _isCopied ? 'Copied!' : 'Copy',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                if (widget.showDownloadButton)
                  IconButton(
                    icon: const Icon(
                      Icons.download_outlined,
                      size: 16,
                    ),
                    color: headerTextColor,
                    onPressed: () {
                      // Download functionality would be implemented here
                    },
                    tooltip: 'Download',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          // Content
          GestureDetector(
            onTap: widget.onTap != null
                ? () => widget.onTap!(widget.artifact)
                : null,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: contentBgColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(7),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  widget.artifact.content,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
