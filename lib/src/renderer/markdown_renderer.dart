import 'package:flutter/widgets.dart';

import '../config/style_sheet.dart';
import '../parser/ast/markdown_node.dart';
import 'builders/block_math_builder.dart';
import 'builders/blockquote_builder.dart';
import 'builders/code_block_builder.dart';
import 'builders/header_builder.dart';
import 'builders/horizontal_rule_builder.dart';
import 'builders/image_builder.dart';
import 'builders/inline_code_builder.dart';
import 'builders/inline_math_builder.dart';
import 'builders/link_builder.dart';
import 'builders/list_builder.dart';
import 'builders/paragraph_builder.dart';
import 'builders/table_builder.dart';
import 'builders/text_builder.dart';
import 'builders/text_style_builder.dart';
import 'widget_builder.dart';

/// Main renderer that converts Markdown AST nodes to Flutter widgets
class MarkdownRenderer {
  /// Creates a new Markdown renderer
  MarkdownRenderer({
    MarkdownStyleSheet? styleSheet,
    BuilderRegistry? builderRegistry,
  })  : styleSheet = styleSheet ?? MarkdownStyleSheet.light(),
        _builderRegistry = builderRegistry ?? _createDefaultRegistry();

  /// The style sheet to use for rendering
  final MarkdownStyleSheet styleSheet;

  /// The builder registry
  final BuilderRegistry _builderRegistry;

  /// Creates the default builder registry
  static BuilderRegistry _createDefaultRegistry() {
    return BuilderRegistry()
      ..register('text', const TextBuilder())
      ..register('header', const HeaderBuilder())
      ..register('paragraph', const ParagraphBuilder())
      ..register('code_block', const CodeBlockBuilder())
      ..register('blockquote', const BlockquoteBuilder())
      ..register('list', const ListBuilder())
      ..register('table', const TableBuilder())
      ..register('horizontal_rule', const HorizontalRuleBuilder())
      ..register('inline_code', const InlineCodeBuilder())
      ..register('inline_math', const InlineMathBuilder())
      ..register('block_math', const BlockMathBuilder())
      ..register('bold', const BoldBuilder())
      ..register('italic', const ItalicBuilder())
      ..register('strikethrough', const StrikethroughBuilder())
      ..register('link', const LinkBuilder())
      ..register('image', const ImageBuilder());
  }

  /// Renders a list of Markdown nodes to a widget
  Widget render(
    List<MarkdownNode> nodes, {
    MarkdownRenderContext? context,
  }) {
    final renderContext = context ?? const MarkdownRenderContext();

    final widgets = nodes
        .map((node) => _renderNode(node, renderContext))
        .where((widget) => widget != null)
        .cast<Widget>()
        .toList();

    if (widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _addSpacing(widgets),
    );
  }

  /// Renders a single node
  Widget? _renderNode(MarkdownNode node, MarkdownRenderContext context) {
    final builder = _builderRegistry.findBuilder(node);

    if (builder == null) {
      // Fallback for unknown node types
      return Text('Unknown node type: ${node.type}');
    }

    return builder.build(node, styleSheet, context);
  }

  /// Renders inline nodes (used by builders)
  Widget renderInline(
    List<MarkdownNode> nodes,
    TextStyle? baseStyle,
    MarkdownRenderContext context,
  ) {
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final spans = nodes.map((node) {
      final builder = _builderRegistry.findBuilder(node);
      if (builder == null) {
        return TextSpan(text: 'Unknown: ${node.type}');
      }

      final widget = builder.build(node, styleSheet, context);

      // If it's a text-based node, extract the TextSpan
      if (widget is Text) {
        return widget.textSpan ?? TextSpan(text: widget.data);
      } else if (widget is RichText) {
        return widget.text;
      }

      // For non-text widgets (like images), wrap in WidgetSpan
      return WidgetSpan(child: widget);
    }).toList();

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }

  /// Adds spacing between block elements
  List<Widget> _addSpacing(List<Widget> widgets) {
    if (widgets.length <= 1) {
      return widgets;
    }

    final spacing = styleSheet.blockSpacing ?? 16.0;
    final result = <Widget>[];

    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);

      // Add spacing between blocks (but not after the last one)
      if (i < widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }

    return result;
  }

  /// Registers a custom builder
  void registerBuilder(String nodeType, MarkdownWidgetBuilder builder) {
    _builderRegistry.register(nodeType, builder);
  }

  /// Unregisters a builder
  void unregisterBuilder(String nodeType) {
    _builderRegistry.unregister(nodeType);
  }
}
