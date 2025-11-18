import 'package:flutter/widgets.dart';

import '../src/config/markdown_config.dart';
import '../src/config/style_sheet.dart';
import '../src/parser/markdown_parser.dart';
import '../src/renderer/builders/blockquote_builder.dart';
import '../src/renderer/builders/code_block_builder.dart';
import '../src/renderer/builders/enhanced_blockquote_builder.dart';
import '../src/renderer/builders/enhanced_code_block_builder.dart';
import '../src/renderer/builders/enhanced_header_builder.dart';
import '../src/renderer/builders/enhanced_link_builder.dart';
import '../src/renderer/builders/header_builder.dart';
import '../src/renderer/builders/horizontal_rule_builder.dart';
import '../src/renderer/builders/image_builder.dart';
import '../src/renderer/builders/inline_code_builder.dart';
import '../src/renderer/builders/link_builder.dart';
import '../src/renderer/builders/list_builder.dart';
import '../src/renderer/builders/paragraph_builder.dart';
import '../src/renderer/builders/text_builder.dart';
import '../src/renderer/builders/text_style_builder.dart';
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
    this.useEnhancedComponents = false,
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

  /// Whether to use enhanced UI components
  ///
  /// When enabled, uses enhanced builders for code blocks, links,
  /// blockquotes, and headers with additional visual effects.
  /// Enhanced components include:
  /// - Code blocks with copy button and language tags
  /// - Links with hover animations and external link icons
  /// - Blockquotes with quote icons and gradient backgrounds
  /// - Headers with decorative accents and borders
  final bool useEnhancedComponents;

  @override
  Widget build(BuildContext context) {
    // Parse markdown
    final parser = MarkdownParser();
    final nodes = parser.parse(data);

    // Create custom registry if enhanced components are enabled
    BuilderRegistry? customRegistry;
    if (useEnhancedComponents) {
      customRegistry = BuilderRegistry()
        // Standard builders
        ..register('text', const TextBuilder())
        ..register('paragraph', const ParagraphBuilder())
        ..register('list', const ListBuilder())
        ..register('horizontal_rule', const HorizontalRuleBuilder())
        ..register('inline_code', const InlineCodeBuilder())
        ..register('bold', const BoldBuilder())
        ..register('italic', const ItalicBuilder())
        ..register('strikethrough', const StrikethroughBuilder())
        ..register('image', const ImageBuilder())
        // Enhanced builders (override standard ones)
        ..register('code_block', const EnhancedCodeBlockBuilder())
        ..register('blockquote', const EnhancedBlockquoteBuilder())
        ..register('link', const EnhancedLinkBuilder())
        ..register('header', const EnhancedHeaderBuilder());
    }

    // Render nodes
    final renderer = MarkdownRenderer(
      styleSheet: styleSheet ?? MarkdownStyleSheet.light(),
      builderRegistry: customRegistry,
    );

    final renderContext = MarkdownRenderContext(
      onTapLink: onTapLink,
      imageBuilder: imageBuilder,
      codeBuilder: codeBuilder,
    );

    return renderer.render(nodes, context: renderContext);
  }
}
