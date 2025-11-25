import 'package:flutter/widgets.dart';

import '../config/style_sheet.dart';
import '../parser/ast/markdown_node.dart';

// Forward declaration to avoid circular imports
typedef InlineRenderer = Widget Function(
  List<MarkdownNode> nodes,
  TextStyle? baseStyle,
);

/// Function type for rendering block-level nodes
typedef BlockRenderer = Widget Function(
  List<MarkdownNode> nodes,
);

/// Base class for building widgets from Markdown nodes
///
/// Each type of Markdown element (header, paragraph, list, etc.)
/// has its own builder that extends this class.
abstract class MarkdownWidgetBuilder {
  /// Creates a new widget builder
  const MarkdownWidgetBuilder();

  /// Builds a widget from a Markdown node
  ///
  /// [node] - The Markdown node to render
  /// [styleSheet] - The style sheet to apply
  /// [context] - Additional rendering context
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  );

  /// Checks if this builder can handle the given node type
  bool canBuild(MarkdownNode node);
}

/// Context passed to builders during rendering
///
/// Contains information needed during the rendering process,
/// including references to renderers for nested content.
class MarkdownRenderContext {
  /// Creates a new render context
  const MarkdownRenderContext({
    this.onTapLink,
    this.imageBuilder,
    this.codeBuilder,
    this.listLevel = 0,
    this.inlineRenderer,
    this.blockRenderer,
    this.styleSheet,
  });

  /// Callback for link taps
  final void Function(String url)? onTapLink;

  /// Custom image widget builder
  final Widget Function(String url, String? alt, String? title)? imageBuilder;

  /// Custom code block widget builder
  final Widget Function(String code, String? language)? codeBuilder;

  /// Current list nesting level (for indentation)
  final int listLevel;

  /// Inline renderer function for rendering inline child nodes
  ///
  /// This allows builders to render inline content using the same
  /// renderer instance, preserving custom builder registrations.
  final InlineRenderer? inlineRenderer;

  /// Block renderer function for rendering block-level child nodes
  ///
  /// This allows builders to render block content (like blockquote children)
  /// using the same renderer instance, preserving custom builder registrations.
  final BlockRenderer? blockRenderer;

  /// The style sheet being used for rendering
  final MarkdownStyleSheet? styleSheet;

  /// Creates a copy with updated fields
  MarkdownRenderContext copyWith({
    void Function(String url)? onTapLink,
    Widget Function(String url, String? alt, String? title)? imageBuilder,
    Widget Function(String code, String? language)? codeBuilder,
    int? listLevel,
    InlineRenderer? inlineRenderer,
    BlockRenderer? blockRenderer,
    MarkdownStyleSheet? styleSheet,
  }) {
    return MarkdownRenderContext(
      onTapLink: onTapLink ?? this.onTapLink,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      codeBuilder: codeBuilder ?? this.codeBuilder,
      listLevel: listLevel ?? this.listLevel,
      inlineRenderer: inlineRenderer ?? this.inlineRenderer,
      blockRenderer: blockRenderer ?? this.blockRenderer,
      styleSheet: styleSheet ?? this.styleSheet,
    );
  }
}

/// Registry for Markdown widget builders
class BuilderRegistry {
  /// Creates a new builder registry
  BuilderRegistry() : _builders = {};

  /// Creates a registry with default builders
  factory BuilderRegistry.defaults() {
    final registry = BuilderRegistry();
    // Default builders will be registered here
    return registry;
  }

  final Map<String, MarkdownWidgetBuilder> _builders;

  /// Returns an iterable of all registered builder entries.
  ///
  /// Useful for merging registries or iterating over all builders.
  Iterable<MapEntry<String, MarkdownWidgetBuilder>> get entries =>
      _builders.entries;

  /// Registers a builder for a specific node type
  void register(String nodeType, MarkdownWidgetBuilder builder) {
    _builders[nodeType] = builder;
  }

  /// Gets the builder for a node type
  MarkdownWidgetBuilder? getBuilder(String nodeType) {
    return _builders[nodeType];
  }

  /// Finds a builder that can handle the given node
  MarkdownWidgetBuilder? findBuilder(MarkdownNode node) {
    // First try exact type match
    final exactBuilder = _builders[node.type];
    if (exactBuilder != null && exactBuilder.canBuild(node)) {
      return exactBuilder;
    }

    // Then try all builders
    for (final builder in _builders.values) {
      if (builder.canBuild(node)) {
        return builder;
      }
    }

    return null;
  }

  /// Checks if a builder exists for a node type
  bool hasBuilder(String nodeType) {
    return _builders.containsKey(nodeType);
  }

  /// Removes a builder
  void unregister(String nodeType) {
    _builders.remove(nodeType);
  }

  /// Clears all builders
  void clear() {
    _builders.clear();
  }
}
