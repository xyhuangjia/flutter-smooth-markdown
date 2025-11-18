import 'package:flutter/widgets.dart';

import '../src/config/markdown_config.dart';
import '../src/config/style_sheet.dart';
import 'smooth_markdown.dart';

/// A widget that renders streaming Markdown content
///
/// This widget is designed for real-time Markdown rendering, such as
/// AI chat responses or live content updates. It accumulates text chunks
/// from a stream and renders them progressively.
///
/// Example:
/// ```dart
/// StreamMarkdown(
///   stream: chatResponseStream,
///   styleSheet: MarkdownStyleSheet.light(),
///   onTapLink: (url) => print('Tapped: $url'),
/// )
/// ```
class StreamMarkdown extends StatefulWidget {
  /// Creates a new StreamMarkdown widget
  const StreamMarkdown({
    required this.stream,
    super.key,
    this.styleSheet,
    this.config,
    this.onTapLink,
    this.imageBuilder,
    this.codeBuilder,
    this.useEnhancedComponents = false,
    this.loadingWidget,
    this.errorBuilder,
  });

  /// The stream of Markdown text chunks
  final Stream<String> stream;

  /// The style sheet to use for rendering
  ///
  /// If not provided, defaults to [MarkdownStyleSheet.light()]
  final MarkdownStyleSheet? styleSheet;

  /// Configuration for Markdown parsing
  final MarkdownConfig? config;

  /// Callback when a link is tapped
  final void Function(String url)? onTapLink;

  /// Custom image widget builder
  final Widget Function(String url, String? alt, String? title)? imageBuilder;

  /// Custom code block widget builder
  final Widget Function(String code, String? language)? codeBuilder;

  /// Whether to use enhanced UI components
  final bool useEnhancedComponents;

  /// Widget to show while waiting for the first chunk
  final Widget? loadingWidget;

  /// Builder for error display
  final Widget Function(Object error)? errorBuilder;

  @override
  State<StreamMarkdown> createState() => _StreamMarkdownState();
}

class _StreamMarkdownState extends State<StreamMarkdown> {
  final StringBuffer _buffer = StringBuffer();
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _listenToStream();
  }

  void _listenToStream() {
    widget.stream.listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _buffer.write(chunk);
            _currentText = _buffer.toString();
          });
        }
      },
      onError: (error) {
        // Error will be handled by StreamBuilder
      },
    );
  }

  @override
  void didUpdateWidget(StreamMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _buffer.clear();
      _currentText = '';
      _listenToStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentText.isEmpty) {
      return widget.loadingWidget ??
          const Center(
            child: SizedBox.shrink(),
          );
    }

    return SmoothMarkdown(
      data: _currentText,
      styleSheet: widget.styleSheet,
      config: widget.config,
      onTapLink: widget.onTapLink,
      imageBuilder: widget.imageBuilder,
      codeBuilder: widget.codeBuilder,
      useEnhancedComponents: widget.useEnhancedComponents,
    );
  }

  @override
  void dispose() {
    _buffer.clear();
    super.dispose();
  }
}
