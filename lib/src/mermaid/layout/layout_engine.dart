import 'dart:math' as math;
import 'dart:ui';

import '../config/responsive_config.dart';
import '../models/diagram.dart';
import '../models/node.dart';
import '../models/timeline.dart';
import '../models/style.dart';

/// Abstract base class for layout engines
abstract class LayoutEngine {
  /// Creates a layout engine
  const LayoutEngine();

  /// Computes layout for the given diagram
  ///
  /// Returns the total size required to render the diagram
  Size computeLayout(
    MermaidDiagramData diagram,
    MermaidStyle style,
    Size availableSize,
  );

  /// Measures the size of a node
  Size measureNode(MermaidNode node, MermaidStyle style) {
    final nodeStyle = style.getNodeStyle(node.className);

    // Calculate text size
    final fontSize = nodeStyle.fontSize;
    final textWidth = node.label.length * fontSize * 0.6;
    final textHeight = fontSize * 1.4;

    // Add padding based on shape
    double horizontalPadding = 24.0;
    double verticalPadding = 16.0;

    switch (node.shape) {
      case NodeShape.circle:
      case NodeShape.doubleCircle:
        // Circle needs equal dimensions
        final diameter = math.max(textWidth, textHeight) + 32;
        return Size(diameter, diameter);

      case NodeShape.diamond:
      case NodeShape.hexagon:
        // These shapes need more horizontal space
        horizontalPadding = 40.0;
        verticalPadding = 24.0;
        break;

      case NodeShape.stadium:
        // Stadium is wider
        horizontalPadding = 32.0;
        break;

      case NodeShape.cylinder:
        // Cylinder needs extra height for the 3D effect
        verticalPadding = 28.0;
        break;

      default:
        break;
    }

    return Size(
      textWidth + horizontalPadding,
      textHeight + verticalPadding,
    );
  }
}

/// Simple layout engine that arranges nodes in a grid-like pattern
///
/// This is a basic fallback layout when more sophisticated algorithms
/// aren't needed or available.
class SimpleLayoutEngine extends LayoutEngine {
  /// Creates a simple layout engine
  const SimpleLayoutEngine();

  @override
  Size computeLayout(
    MermaidDiagramData diagram,
    MermaidStyle style,
    Size availableSize,
  ) {
    if (diagram.nodes.isEmpty) return Size.zero;

    // Measure all nodes first
    for (final node in diagram.nodes) {
      final size = measureNode(node, style);
      node.width = size.width;
      node.height = size.height;
    }

    final isHorizontal = diagram.direction == DiagramDirection.leftToRight ||
        diagram.direction == DiagramDirection.rightToLeft;

    // Simple row/column layout
    double x = style.padding;
    double y = style.padding;
    double maxRowHeight = 0;
    double maxWidth = 0;
    double maxHeight = 0;

    final nodesPerRow = isHorizontal
        ? diagram.nodes.length
        : math.sqrt(diagram.nodes.length).ceil();

    for (var i = 0; i < diagram.nodes.length; i++) {
      final node = diagram.nodes[i];

      if (!isHorizontal && i > 0 && i % nodesPerRow == 0) {
        // Move to next row
        x = style.padding;
        y += maxRowHeight + style.nodeSpacingY;
        maxRowHeight = 0;
      }

      node.x = x;
      node.y = y;

      x += node.width + style.nodeSpacingX;
      maxRowHeight = math.max(maxRowHeight, node.height);
      maxWidth = math.max(maxWidth, x);
      maxHeight = math.max(maxHeight, y + node.height);
    }

    return Size(
      maxWidth + style.padding,
      maxHeight + style.padding,
    );
  }
}

/// Layout engine for timeline diagrams
class TimelineChartLayout {
  /// Creates a timeline chart layout engine
  const TimelineChartLayout({this.deviceConfig});

  /// Responsive device configuration
  final MermaidDeviceConfig? deviceConfig;

  /// Computes the layout size for a timeline chart
  Size computeLayout(
    TimelineChartData timelineData,
    MermaidStyle style,
    Size availableSize,
  ) {
    if (timelineData.sections.isEmpty) return Size.zero;

    final padding = style.padding;
    final titleHeight = timelineData.title != null ? 60.0 : 20.0;

    // Calculate maximum events in any section
    var maxEvents = 0;
    for (final section in timelineData.sections) {
      if (section.events.length > maxEvents) {
        maxEvents = section.events.length;
      }
    }

    // Layout constants
    final isMobile = deviceConfig?.deviceType == DeviceType.mobile;
    final eventHeight = isMobile ? 50.0 : 60.0;
    final verticalSpacing = isMobile ? 30.0 : 40.0;
    final timelineMargin = 20.0;

    // Calculate total height
    // Structure: padding + title + spacing + period labels + timeline + spacing + events + padding
    final totalHeight = padding +
        titleHeight +
        verticalSpacing +  // Space for period labels above timeline
        timelineMargin +   // Space around timeline
        verticalSpacing +  // Space before events
        (maxEvents * eventHeight) +
        padding;

    // Width should be based on available space
    final totalWidth = availableSize.width;

    return Size(totalWidth, totalHeight);
  }
}
