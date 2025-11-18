import 'package:flutter/widgets.dart';

/// Configuration options for Markdown parsing and rendering behavior.
///
/// [MarkdownConfig] controls which markdown features are enabled and how
/// they are parsed and rendered. Most features are enabled by default,
/// following CommonMark and GitHub Flavored Markdown (GFM) specifications.
///
/// ## Basic Usage
///
/// ```dart
/// SmoothMarkdown(
///   data: markdownText,
///   config: MarkdownConfig(
///     enableCodeHighlight: true,
///     enableTables: true,
///     enableTaskLists: true,
///   ),
/// )
/// ```
///
/// ## Feature Categories
///
/// **Extended Markdown Syntax**:
/// - Task lists (`- [ ]` and `- [x]`)
/// - Tables (GFM-style)
/// - Strikethrough (`~~text~~`)
/// - Auto-linking URLs
/// - Emoji shortcodes (`:smile:`)
///
/// **Advanced Features**:
/// - LaTeX math formulas (`$...$` and `$$...$$`)
/// - Syntax highlighting for code blocks
/// - HTML inline tags (disabled by default for security)
///
/// **Image Handling**:
/// - Image caching via `cached_network_image`
/// - Custom error widgets for failed image loads
/// - Custom placeholder widgets for loading images
///
/// ## Security Considerations
///
/// **HTML Support**: By default, HTML tags are disabled ([enableHtml] = false)
/// for security reasons. When enabled, HTML is sanitized to prevent XSS attacks,
/// but it's recommended to only enable this for trusted content.
///
/// ```dart
/// // Only enable for trusted content
/// MarkdownConfig(
///   enableHtml: true, // Use with caution
/// )
/// ```
///
/// ## Performance Options
///
/// **Code Highlighting**: Syntax highlighting adds visual appeal but has a
/// small performance cost. For very large documents with many code blocks,
/// you may want to disable it:
///
/// ```dart
/// MarkdownConfig(
///   enableCodeHighlight: false, // Faster rendering
/// )
/// ```
///
/// **Image Caching**: Image caching improves performance for repeated image
/// loads but uses device storage. Disable if storage is a concern:
///
/// ```dart
/// MarkdownConfig(
///   enableImageCache: false,
/// )
/// ```
///
/// ## Example Configurations
///
/// **Minimal markdown** (basic formatting only):
/// ```dart
/// MarkdownConfig(
///   enableHtml: false,
///   enableCodeHighlight: false,
///   enableImageCache: false,
///   enableTaskLists: false,
///   enableTables: false,
///   enableLatex: false,
/// )
/// ```
///
/// **Full-featured** (all extensions enabled):
/// ```dart
/// MarkdownConfig(
///   enableCodeHighlight: true,
///   enableTables: true,
///   enableTaskLists: true,
///   enableLatex: true,
///   enableEmoji: true,
///   syntaxHighlightTheme: 'monokai',
/// )
/// ```
///
/// **Academic/scientific** (emphasizing math and code):
/// ```dart
/// MarkdownConfig(
///   enableLatex: true,
///   enableCodeHighlight: true,
///   syntaxHighlightTheme: 'github',
///   enableTables: true,
/// )
/// ```
///
/// See also:
///
/// - [MarkdownStyleSheet], for controlling visual appearance
/// - [SmoothMarkdown], which uses this configuration
class MarkdownConfig {
  /// Creates a new Markdown configuration with the specified options.
  ///
  /// All parameters are optional and default to sensible values:
  /// - Most markdown features are enabled by default
  /// - HTML is disabled by default for security
  /// - GitHub syntax highlighting theme is used by default
  ///
  /// Example:
  ///
  /// ```dart
  /// const config = MarkdownConfig(
  ///   enableCodeHighlight: true,
  ///   enableLatex: true,
  ///   syntaxHighlightTheme: 'monokai',
  ///   enableTables: true,
  /// );
  /// ```
  const MarkdownConfig({
    this.enableHtml = false,
    this.enableCodeHighlight = true,
    this.enableImageCache = true,
    this.enableTaskLists = true,
    this.enableStrikethrough = true,
    this.enableTables = true,
    this.enableAutoLinks = true,
    this.enableEmoji = false,
    this.enableLatex = false,
    this.syntaxHighlightTheme = 'github',
    this.imageErrorBuilder,
    this.imagePlaceholderBuilder,
  });

  /// Whether to allow inline HTML tags
  ///
  /// For security reasons, this is disabled by default.
  /// When enabled, HTML will be sanitized to prevent XSS attacks.
  final bool enableHtml;

  /// Whether to enable syntax highlighting for code blocks
  final bool enableCodeHighlight;

  /// Whether to enable image caching
  final bool enableImageCache;

  /// Whether to enable task lists (GFM)
  ///
  /// Example: `- [ ] Task` and `- [x] Completed task`
  final bool enableTaskLists;

  /// Whether to enable strikethrough text
  ///
  /// Example: `~~strikethrough~~`
  final bool enableStrikethrough;

  /// Whether to enable tables (GFM)
  final bool enableTables;

  /// Whether to automatically convert URLs to links
  final bool enableAutoLinks;

  /// Whether to enable emoji shortcodes
  ///
  /// Example: `:smile:` → 😊
  final bool enableEmoji;

  /// Whether to enable LaTeX math formula rendering
  ///
  /// Supports inline `$...$` and block `$$...$$` formulas
  final bool enableLatex;

  /// The syntax highlighting theme name
  ///
  /// Common themes: 'github', 'monokai', 'darcula', 'vs', etc.
  final String syntaxHighlightTheme;

  /// Custom error widget builder for failed image loads
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)?
      imageErrorBuilder;

  /// Custom placeholder widget builder for loading images
  final Widget Function(BuildContext context)? imagePlaceholderBuilder;

  /// Creates a copy of this configuration with the given fields replaced
  MarkdownConfig copyWith({
    bool? enableHtml,
    bool? enableCodeHighlight,
    bool? enableImageCache,
    bool? enableTaskLists,
    bool? enableStrikethrough,
    bool? enableTables,
    bool? enableAutoLinks,
    bool? enableEmoji,
    bool? enableLatex,
    String? syntaxHighlightTheme,
    Widget Function(BuildContext, Object, StackTrace?)? imageErrorBuilder,
    Widget Function(BuildContext)? imagePlaceholderBuilder,
  }) {
    return MarkdownConfig(
      enableHtml: enableHtml ?? this.enableHtml,
      enableCodeHighlight: enableCodeHighlight ?? this.enableCodeHighlight,
      enableImageCache: enableImageCache ?? this.enableImageCache,
      enableTaskLists: enableTaskLists ?? this.enableTaskLists,
      enableStrikethrough: enableStrikethrough ?? this.enableStrikethrough,
      enableTables: enableTables ?? this.enableTables,
      enableAutoLinks: enableAutoLinks ?? this.enableAutoLinks,
      enableEmoji: enableEmoji ?? this.enableEmoji,
      enableLatex: enableLatex ?? this.enableLatex,
      syntaxHighlightTheme: syntaxHighlightTheme ?? this.syntaxHighlightTheme,
      imageErrorBuilder: imageErrorBuilder ?? this.imageErrorBuilder,
      imagePlaceholderBuilder:
          imagePlaceholderBuilder ?? this.imagePlaceholderBuilder,
    );
  }

  @override
  String toString() => 'MarkdownConfig('
      'enableHtml: $enableHtml, '
      'enableCodeHighlight: $enableCodeHighlight, '
      'enableImageCache: $enableImageCache, '
      'enableTaskLists: $enableTaskLists, '
      'enableStrikethrough: $enableStrikethrough, '
      'enableTables: $enableTables, '
      'enableAutoLinks: $enableAutoLinks, '
      'enableEmoji: $enableEmoji, '
      'enableLatex: $enableLatex, '
      'syntaxHighlightTheme: $syntaxHighlightTheme)';
}
