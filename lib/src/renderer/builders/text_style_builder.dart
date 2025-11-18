import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
import '../widget_builder.dart';

/// Builder for bold text nodes
class BoldBuilder extends MarkdownWidgetBuilder {
  /// Creates a new bold builder
  const BoldBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is BoldNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final boldNode = node as BoldNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return renderer.renderInline(
      boldNode.children,
      styleSheet.boldStyle,
      context,
    );
  }
}

/// Builder for italic text nodes
class ItalicBuilder extends MarkdownWidgetBuilder {
  /// Creates a new italic builder
  const ItalicBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is ItalicNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final italicNode = node as ItalicNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return renderer.renderInline(
      italicNode.children,
      styleSheet.italicStyle,
      context,
    );
  }
}

/// Builder for strikethrough text nodes
class StrikethroughBuilder extends MarkdownWidgetBuilder {
  /// Creates a new strikethrough builder
  const StrikethroughBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is StrikethroughNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final strikeNode = node as StrikethroughNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    return renderer.renderInline(
      strikeNode.children,
      styleSheet.strikethroughStyle,
      context,
    );
  }
}
