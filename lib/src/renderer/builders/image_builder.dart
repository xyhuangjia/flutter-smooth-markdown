import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../widget_builder.dart';

/// Builder for image nodes
class ImageBuilder extends MarkdownWidgetBuilder {
  /// Creates a new image builder
  const ImageBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is ImageNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final imageNode = node as ImageNode;

    // Use custom builder if provided
    if (context.imageBuilder != null) {
      return context.imageBuilder!(
        imageNode.url,
        imageNode.alt,
        imageNode.title,
      );
    }

    // Default rendering with caching
    if (imageNode.url.startsWith('http://') ||
        imageNode.url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageNode.url,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }

    // Local image
    return Image.asset(
      imageNode.url,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image);
      },
    );
  }
}
