/// Configuration options for Markdown parsing and rendering
class MarkdownConfig {
  /// Creates a new Markdown configuration
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

// Placeholder type for Widget - will be replaced with actual import
typedef Widget = dynamic;
typedef BuildContext = dynamic;
