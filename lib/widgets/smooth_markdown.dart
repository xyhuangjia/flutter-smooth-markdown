import 'package:flutter/widgets.dart';

import '../src/config/markdown_config.dart';
import '../src/config/style_sheet.dart';
import '../src/parser/markdown_parser.dart';
import '../src/renderer/markdown_renderer.dart';
import '../src/renderer/widget_builder.dart';

/// A widget that renders Markdown content
///
/// This widget parses and renders Markdown text using the provided
/// configuration and style sheet.
///
/// Example:
/// ```dart
/// SmoothMarkdown(
///   data: '# Hello **World**',
///   styleSheet: MarkdownStyleSheet.light(),
///   onTapLink: (url) => print('Tapped: $url'),
/// )
/// ```
class SmoothMarkdown extends StatelessWidget {
  /// Creates a new SmoothMarkdown widget
  const SmoothMarkdown({
    required this.data,
    super.key,
    this.styleSheet,
    this.config,
    this.onTapLink,
    this.imageBuilder,
    this.codeBuilder,
  });

  /// The Markdown text to render
  final String data;

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

  @override
  Widget build(BuildContext context) {
    // Parse markdown
    final parser = MarkdownParser();
    final nodes = parser.parse(data);

    // Render nodes
    final renderer = MarkdownRenderer(
      styleSheet: styleSheet ?? MarkdownStyleSheet.light(),
    );

    final renderContext = MarkdownRenderContext(
      onTapLink: onTapLink,
      imageBuilder: imageBuilder,
      codeBuilder: codeBuilder,
    );

    return renderer.render(nodes, context: renderContext);
  }
}
