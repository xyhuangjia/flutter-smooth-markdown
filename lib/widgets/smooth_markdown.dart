import 'package:flutter/widgets.dart';

import '../src/config/markdown_config.dart';
import '../src/config/style_sheet.dart';
import '../src/parser/markdown_parser.dart';
import '../src/renderer/builders/enhanced_blockquote_builder.dart';
import '../src/renderer/builders/enhanced_code_block_builder.dart';
import '../src/renderer/builders/enhanced_header_builder.dart';
import '../src/renderer/builders/enhanced_link_builder.dart';
import '../src/renderer/builders/horizontal_rule_builder.dart';
import '../src/renderer/builders/image_builder.dart';
import '../src/renderer/builders/inline_code_builder.dart';
import '../src/renderer/builders/list_builder.dart';
import '../src/renderer/builders/paragraph_builder.dart';
import '../src/renderer/builders/table_builder.dart';
import '../src/renderer/builders/text_builder.dart';
import '../src/renderer/builders/text_style_builder.dart';
import '../src/renderer/markdown_renderer.dart';
import '../src/renderer/widget_builder.dart';

/// A widget that renders Markdown content with high performance and customizable styling.
///
/// [SmoothMarkdown] is a stateless widget that parses and renders Markdown text using
/// an AST-based parser and a flexible widget builder system. It supports full CommonMark
/// syntax plus GitHub Flavored Markdown (GFM) extensions.
///
/// ## Basic Usage
///
/// ```dart
/// SmoothMarkdown(
///   data: '# Hello **World**\n\nThis is a *markdown* document.',
///   styleSheet: MarkdownStyleSheet.light(),
/// )
/// ```
///
/// ## Features
///
/// - **Full Markdown Support**: Headers, lists, code blocks, tables, links, images, and more
/// - **Customizable Styling**: Use built-in themes or create custom styles
/// - **Enhanced Components**: Optional beautiful UI components with animations and effects
/// - **Syntax Highlighting**: Code blocks with language-specific syntax highlighting
/// - **Image Support**: Network images with caching, plus SVG support
/// - **Math Formulas**: LaTeX rendering with `$...$` (inline) and `$$...$$` (block)
/// - **Extensible**: Custom widget builders for any markdown element
///
/// ## Using Themes
///
/// ```dart
/// // Built-in light theme
/// SmoothMarkdown(
///   data: markdownText,
///   styleSheet: MarkdownStyleSheet.light(),
/// )
///
/// // GitHub theme
/// SmoothMarkdown(
///   data: markdownText,
///   styleSheet: MarkdownStyleSheet.github(),
/// )
///
/// // VS Code dark theme
/// SmoothMarkdown(
///   data: markdownText,
///   styleSheet: MarkdownStyleSheet.vscode(brightness: Brightness.dark),
/// )
///
/// // Adapt to Flutter theme
/// SmoothMarkdown(
///   data: markdownText,
///   styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
/// )
/// ```
///
/// ## Enhanced Components
///
/// Enable enhanced UI components for a more polished appearance:
///
/// ```dart
/// SmoothMarkdown(
///   data: markdownText,
///   useEnhancedComponents: true,
///   styleSheet: MarkdownStyleSheet.light(),
/// )
/// ```
///
/// Enhanced components include:
/// - **Code blocks**: Copy button, language tags, hover effects, syntax highlighting
/// - **Blockquotes**: Quote icons, gradient backgrounds, shadows
/// - **Links**: Hover animations, external link indicators, smooth transitions
/// - **Headers**: Decorative accents, gradient borders, color markers for H1/H2
///
/// ## Handling Links
///
/// ```dart
/// SmoothMarkdown(
///   data: markdownText,
///   onTapLink: (url) {
///     // Handle link navigation
///     if (url.startsWith('http')) {
///       launchUrl(Uri.parse(url));
///     } else {
///       // Handle internal navigation
///       Navigator.pushNamed(context, url);
///     }
///   },
/// )
/// ```
///
/// ## Custom Image Builder
///
/// Provide a custom widget builder for images:
///
/// ```dart
/// SmoothMarkdown(
///   data: markdownText,
///   imageBuilder: (url, alt, title) {
///     return CachedNetworkImage(
///       imageUrl: url,
///       placeholder: (context, url) => CircularProgressIndicator(),
///       errorWidget: (context, url, error) => Icon(Icons.error),
///     );
///   },
/// )
/// ```
///
/// ## Custom Code Block Builder
///
/// Customize how code blocks are rendered:
///
/// ```dart
/// SmoothMarkdown(
///   data: markdownText,
///   codeBuilder: (code, language) {
///     return Container(
///       padding: EdgeInsets.all(12),
///       decoration: BoxDecoration(
///         color: Colors.grey[900],
///         borderRadius: BorderRadius.circular(8),
///       ),
///       child: Text(code, style: TextStyle(fontFamily: 'monospace')),
///     );
///   },
/// )
/// ```
///
/// ## Performance Considerations
///
/// - The widget uses an AST-based parser for efficient parsing
/// - Rendering is optimized to minimize widget rebuilds
/// - For real-time streaming content, use [StreamMarkdown] instead
/// - Large documents (10k+ lines) may benefit from lazy loading techniques
///
/// See also:
///
/// - [StreamMarkdown], for real-time streaming markdown rendering
/// - [MarkdownStyleSheet], for customizing the visual appearance
/// - [MarkdownConfig], for configuring parsing behavior
/// - [MarkdownRenderer], for advanced custom rendering
class SmoothMarkdown extends StatelessWidget {
  /// Creates a widget that renders Markdown content.
  ///
  /// The [data] parameter is required and contains the Markdown text to render.
  ///
  /// All other parameters are optional and provide customization options:
  ///
  /// - [styleSheet]: Controls the visual styling of markdown elements. Defaults to
  ///   [MarkdownStyleSheet.light] if not provided.
  /// - [config]: Configuration options for markdown parsing behavior. Most features
  ///   are enabled by default.
  /// - [onTapLink]: Callback function invoked when a link is tapped. Receives the
  ///   URL as a string parameter.
  /// - [imageBuilder]: Custom widget builder for rendering images. If not provided,
  ///   uses the default image renderer with network caching.
  /// - [codeBuilder]: Custom widget builder for rendering code blocks. If not provided,
  ///   uses the default code block renderer with syntax highlighting.
  /// - [useEnhancedComponents]: When `true`, uses enhanced UI components with additional
  ///   visual effects and interactions. Defaults to `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// SmoothMarkdown(
  ///   data: '# Title\n\nThis is **bold** text.',
  ///   styleSheet: MarkdownStyleSheet.github(),
  ///   useEnhancedComponents: true,
  ///   onTapLink: (url) => launchUrl(Uri.parse(url)),
  /// )
  /// ```
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

  /// The Markdown text to render.
  ///
  /// This string will be parsed and rendered according to CommonMark and GFM specifications.
  /// Supports all standard markdown syntax including headers, lists, code blocks, tables,
  /// links, images, and inline formatting (bold, italic, code, etc.).
  ///
  /// Example:
  ///
  /// ```dart
  /// data: '''
  /// # Hello World
  ///
  /// This is a paragraph with **bold** and *italic* text.
  ///
  /// - List item 1
  /// - List item 2
  /// '''
  /// ```
  final String data;

  /// The style sheet used to control the visual appearance of rendered markdown.
  ///
  /// If not provided, defaults to [MarkdownStyleSheet.light]. You can use one of the
  /// built-in factory constructors:
  ///
  /// - [MarkdownStyleSheet.light] - Clean light theme (default)
  /// - [MarkdownStyleSheet.dark] - Dark theme for dark mode apps
  /// - [MarkdownStyleSheet.github] - GitHub-style light or dark theme
  /// - [MarkdownStyleSheet.vscode] - VS Code editor-style theme
  /// - [MarkdownStyleSheet.fromTheme] - Adapts to Flutter's theme
  ///
  /// You can also create custom styles using [MarkdownStyleSheet.copyWith]:
  ///
  /// ```dart
  /// styleSheet: MarkdownStyleSheet.light().copyWith(
  ///   h1Style: TextStyle(fontSize: 40, color: Colors.purple),
  ///   codeBlockDecoration: BoxDecoration(
  ///     color: Colors.grey[100],
  ///     borderRadius: BorderRadius.circular(8),
  ///   ),
  /// )
  /// ```
  final MarkdownStyleSheet? styleSheet;

  /// Configuration options for Markdown parsing behavior.
  ///
  /// Controls which markdown features are enabled and how they are parsed.
  /// If not provided, uses default configuration with most features enabled.
  ///
  /// Example:
  ///
  /// ```dart
  /// config: MarkdownConfig(
  ///   enableCodeHighlight: true,
  ///   enableTables: true,
  ///   enableTaskLists: true,
  ///   enableLatex: true,
  ///   syntaxHighlightTheme: 'monokai',
  /// )
  /// ```
  ///
  /// See [MarkdownConfig] for all available options.
  final MarkdownConfig? config;

  /// Callback function invoked when a user taps on a link.
  ///
  /// The callback receives the URL string as a parameter. Use this to handle
  /// navigation to external URLs or internal routes.
  ///
  /// Example:
  ///
  /// ```dart
  /// onTapLink: (url) {
  ///   if (url.startsWith('http')) {
  ///     // Open external URL
  ///     launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  ///   } else if (url.startsWith('#')) {
  ///     // Handle anchor link
  ///     scrollToSection(url.substring(1));
  ///   } else {
  ///     // Handle internal navigation
  ///     Navigator.pushNamed(context, url);
  ///   }
  /// }
  /// ```
  ///
  /// If not provided, links will be rendered but tapping them will have no effect.
  final void Function(String url)? onTapLink;

  /// Custom widget builder for rendering images.
  ///
  /// This builder is called for each image in the markdown, receiving:
  /// - `url`: The image URL (can be network URL, asset path, or data URI)
  /// - `alt`: Alternative text for the image (null if not provided)
  /// - `title`: Image title attribute (null if not provided)
  ///
  /// If not provided, images are rendered using the default image builder which
  /// supports network images with caching (via `cached_network_image`) and SVG
  /// images (via `flutter_svg`).
  ///
  /// Example:
  ///
  /// ```dart
  /// imageBuilder: (url, alt, title) {
  ///   return GestureDetector(
  ///     onTap: () => showImageViewer(url),
  ///     child: CachedNetworkImage(
  ///       imageUrl: url,
  ///       placeholder: (context, url) => CircularProgressIndicator(),
  ///       errorWidget: (context, url, error) => Icon(Icons.broken_image),
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(String url, String? alt, String? title)? imageBuilder;

  /// Custom widget builder for rendering code blocks.
  ///
  /// This builder is called for each fenced code block in the markdown, receiving:
  /// - `code`: The code content as a string
  /// - `language`: The language identifier (e.g., 'dart', 'javascript'), or null if not specified
  ///
  /// If not provided, code blocks are rendered using the default builder which
  /// includes syntax highlighting via `flutter_highlight`.
  ///
  /// Example:
  ///
  /// ```dart
  /// codeBuilder: (code, language) {
  ///   return Container(
  ///     padding: EdgeInsets.all(16),
  ///     decoration: BoxDecoration(
  ///       color: Colors.black87,
  ///       borderRadius: BorderRadius.circular(8),
  ///     ),
  ///     child: SelectableText(
  ///       code,
  ///       style: TextStyle(
  ///         fontFamily: 'Courier New',
  ///         color: Colors.white,
  ///       ),
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(String code, String? language)? codeBuilder;

  /// Whether to use enhanced UI components with additional visual effects.
  ///
  /// When set to `true`, the widget uses enhanced builders that provide:
  ///
  /// **Enhanced Code Blocks** ([EnhancedCodeBlockBuilder]):
  /// - Copy-to-clipboard button (appears on hover or always visible on mobile)
  /// - Language tag display in top-right corner
  /// - Subtle shadow and border effects
  /// - Smooth hover animations
  ///
  /// **Enhanced Blockquotes** ([EnhancedBlockquoteBuilder]):
  /// - Quote icon (💭) at the start
  /// - Gradient background with theme-aware colors
  /// - Drop shadow for depth
  /// - Colored left border accent
  ///
  /// **Enhanced Links** ([EnhancedLinkBuilder]):
  /// - Smooth hover animations with scale effect
  /// - Animated underline on hover
  /// - External link indicator icon (🔗)
  /// - Color transitions
  ///
  /// **Enhanced Headers** ([EnhancedHeaderBuilder]):
  /// - Colored accent markers for H1 and H2
  /// - Gradient bottom border
  /// - Improved spacing and visual hierarchy
  ///
  /// Defaults to `false` for standard rendering.
  ///
  /// Example:
  ///
  /// ```dart
  /// // Standard rendering
  /// SmoothMarkdown(
  ///   data: markdownText,
  ///   useEnhancedComponents: false, // default
  /// )
  ///
  /// // Enhanced rendering with visual effects
  /// SmoothMarkdown(
  ///   data: markdownText,
  ///   useEnhancedComponents: true,
  /// )
  /// ```
  ///
  /// Note: Enhanced components may have slightly higher rendering cost due to
  /// additional decorations and animations. For maximum performance with large
  /// documents, keep this set to `false`.
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
        ..register('table', const TableBuilder())
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
