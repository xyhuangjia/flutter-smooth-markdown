import 'package:flutter/widgets.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
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
    final inlineRenderer = context.inlineRenderer;

    if (inlineRenderer != null) {
      return inlineRenderer(boldNode.children, styleSheet.boldStyle);
    }

    // Fallback
    return Text(_extractText(boldNode.children), style: styleSheet.boldStyle);
  }

  String _extractText(List<MarkdownNode> nodes) {
    return nodes.whereType<TextNode>().map((n) => n.content).join();
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
    final inlineRenderer = context.inlineRenderer;

    if (inlineRenderer != null) {
      return inlineRenderer(italicNode.children, styleSheet.italicStyle);
    }

    // Fallback
    return Text(_extractText(italicNode.children), style: styleSheet.italicStyle);
  }

  String _extractText(List<MarkdownNode> nodes) {
    return nodes.whereType<TextNode>().map((n) => n.content).join();
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
    final inlineRenderer = context.inlineRenderer;

    if (inlineRenderer != null) {
      return inlineRenderer(strikeNode.children, styleSheet.strikethroughStyle);
    }

    // Fallback
    return Text(_extractText(strikeNode.children), style: styleSheet.strikethroughStyle);
  }

  String _extractText(List<MarkdownNode> nodes) {
    return nodes.whereType<TextNode>().map((n) => n.content).join();
  }
}
