import 'package:flutter/material.dart';

import '../config/responsive_config.dart';
import '../layout/dagre_layout.dart';
import '../layout/layout_engine.dart';
import '../layout/sugiyama_layout.dart';
import '../models/diagram.dart';
import '../models/gantt.dart';
import '../models/pie_chart.dart';
import '../models/style.dart';
import '../painter/flowchart_painter.dart';
import '../painter/gantt_painter.dart';
import '../painter/pie_chart_painter.dart';
import '../painter/sequence_painter.dart';
import '../parser/mermaid_parser.dart';

/// A widget that renders Mermaid diagrams using pure Dart/Flutter
///
/// This widget parses Mermaid diagram syntax and renders it using
/// Flutter's CustomPainter, without any WebView or external dependencies.
///
/// Example usage:
/// ```dart
/// MermaidDiagram(
///   code: '''
///   graph TD
///     A[Start] --> B{Decision}
///     B -->|Yes| C[OK]
///     B -->|No| D[Cancel]
///   ''',
///   style: MermaidStyle.dark(),
/// )
/// ```
class MermaidDiagram extends StatefulWidget {
  /// Creates a Mermaid diagram widget
  const MermaidDiagram({
    super.key,
    required this.code,
    this.style,
    this.width,
    this.height,
    this.onNodeTap,
    this.onError,
    this.errorBuilder,
    this.loadingBuilder,
    this.responsiveConfig,
    this.enableResponsive = true,
  });

  /// The Mermaid diagram code
  final String code;

  /// Style configuration (defaults to light theme)
  final MermaidStyle? style;

  /// Fixed width (if not provided, uses available space)
  final double? width;

  /// Fixed height (if not provided, uses computed size)
  final double? height;

  /// Callback when a node is tapped
  final void Function(String nodeId)? onNodeTap;

  /// Callback when parsing fails
  final void Function(String error)? onError;

  /// Builder for error state
  final Widget Function(BuildContext context, String error)? errorBuilder;

  /// Builder for loading state
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Responsive configuration for different screen sizes
  final MermaidResponsiveConfig? responsiveConfig;

  /// Whether to enable responsive layout (defaults to true)
  final bool enableResponsive;

  @override
  State<MermaidDiagram> createState() => _MermaidDiagramState();
}

class _MermaidDiagramState extends State<MermaidDiagram> {
  MermaidDiagramData? _diagram;
  PieChartData? _pieChartData;
  GanttChartData? _ganttChartData;
  Size _computedSize = Size.zero;
  String? _error;
  bool _isLoading = true;
  MermaidDeviceConfig? _deviceConfig;
  double? _lastWidth;

  late MermaidStyle _style;

  @override
  void initState() {
    super.initState();
    _style = widget.style ?? const MermaidStyle();
  }

  @override
  void didUpdateWidget(MermaidDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code || oldWidget.style != widget.style) {
      _style = widget.style ?? const MermaidStyle();
      _lastWidth = null; // Force re-layout
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initial parse will happen in build when we have context
  }

  void _parseDiagram(double availableWidth) {
    // Get responsive config
    if (widget.enableResponsive) {
      final responsiveConfig = widget.responsiveConfig ?? const MermaidResponsiveConfig();
      _deviceConfig = responsiveConfig.getConfigForWidth(availableWidth);

      // Apply responsive settings to style
      _style = _applyResponsiveStyle(_style, _deviceConfig!);
    }

    try {
      final parser = const MermaidParser();
      final result = parser.parseWithData(widget.code);

      if (result == null) {
        throw Exception('Unable to parse diagram');
      }

      final diagram = result.diagram;
      Size size;

      // Compute layout based on diagram type
      if (diagram.type == DiagramType.pieChart && result.pieChartData != null) {
        // Use pie chart layout with responsive config
        final pieLayout = PieChartLayout(deviceConfig: _deviceConfig);
        size = pieLayout.computeLayout(
          result.pieChartData!,
          _style,
          Size(widget.width ?? availableWidth, widget.height ?? 600),
        );
      } else if (diagram.type == DiagramType.ganttChart && result.ganttChartData != null) {
        // Use Gantt chart layout with responsive config
        final ganttLayout = GanttChartLayout(deviceConfig: _deviceConfig);
        size = ganttLayout.computeLayout(
          result.ganttChartData!,
          _style,
          Size(widget.width ?? availableWidth, widget.height ?? 600),
        );
      } else {
        final layoutEngine = _getLayoutEngine(diagram.type);
        size = layoutEngine.computeLayout(
          diagram,
          _style,
          Size(widget.width ?? availableWidth, widget.height ?? 600),
        );
      }

      _diagram = diagram;
      _pieChartData = result.pieChartData;
      _ganttChartData = result.ganttChartData;
      _computedSize = size;
      _error = null;
      _isLoading = false;
    } catch (e) {
      final errorMsg = e.toString();
      _error = errorMsg;
      _isLoading = false;
      widget.onError?.call(errorMsg);
    }
  }

  MermaidStyle _applyResponsiveStyle(MermaidStyle style, MermaidDeviceConfig config) {
    return style.copyWith(
      padding: config.padding,
      nodeSpacingX: config.nodeSpacingX,
      nodeSpacingY: config.nodeSpacingY,
      defaultNodeStyle: style.defaultNodeStyle.copyWith(
        fontSize: config.fontSize,
      ),
    );
  }

  LayoutEngine _getLayoutEngine(DiagramType type) {
    switch (type) {
      case DiagramType.flowchart:
        return DagreLayout(deviceConfig: _deviceConfig);
      case DiagramType.sequence:
        return SequenceLayout(deviceConfig: _deviceConfig);
      default:
        return const SimpleLayoutEngine();
    }
  }

  CustomPainter _getPainter(MermaidDiagramData diagram) {
    switch (diagram.type) {
      case DiagramType.flowchart:
        return FlowchartPainter(
          diagram: diagram,
          style: _style,
          deviceConfig: _deviceConfig,
        );
      case DiagramType.sequence:
        return SequencePainter(
          diagram: diagram,
          style: _style,
          deviceConfig: _deviceConfig,
        );
      case DiagramType.pieChart:
        if (_pieChartData != null) {
          return PieChartPainter(
            pieData: _pieChartData!,
            style: _style,
            deviceConfig: _deviceConfig,
          );
        }
        return FlowchartPainter(diagram: diagram, style: _style);
      case DiagramType.ganttChart:
        if (_ganttChartData != null) {
          return GanttPainter(
            ganttData: _ganttChartData!,
            style: _style,
            deviceConfig: _deviceConfig,
          );
        }
        return FlowchartPainter(diagram: diagram, style: _style);
      default:
        return FlowchartPainter(diagram: diagram, style: _style);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Re-parse if width changed significantly or first time
        if (_lastWidth == null ||
            (availableWidth - _lastWidth!).abs() > 50 ||
            _isLoading) {
          _lastWidth = availableWidth;
          _parseDiagram(availableWidth);
        }

        if (_isLoading) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return widget.errorBuilder?.call(context, _error!) ??
              _buildErrorWidget(_error!);
        }

        if (_diagram == null) {
          return const SizedBox.shrink();
        }

        final painter = _getPainter(_diagram!);

        // Calculate display size with responsive constraints
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _computedSize.width;

        final displayWidth = widget.width != null
            ? (_computedSize.width > widget.width!
                ? _computedSize.width
                : widget.width!)
            : _computedSize.width.clamp(0.0, maxWidth);

        final displayHeight = widget.height != null
            ? (_computedSize.height > widget.height!
                ? _computedSize.height
                : widget.height!)
            : _computedSize.height;

        // For mobile, wrap in horizontal scroll if needed
        Widget diagramWidget = Container(
          width: displayWidth,
          height: displayHeight,
          color: Color(_style.backgroundColor),
          child: CustomPaint(
            painter: painter,
            size: _computedSize,
          ),
        );

        // Enable horizontal scrolling on mobile if diagram is wider than screen
        if (_deviceConfig?.deviceType == DeviceType.mobile &&
            _computedSize.width > availableWidth) {
          diagramWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: diagramWidget,
          );
        }

        return GestureDetector(
          onTapDown: widget.onNodeTap != null ? _handleTap : null,
          child: diagramWidget,
        );
      },
    );
  }

  void _handleTap(TapDownDetails details) {
    if (_diagram == null || widget.onNodeTap == null) return;

    final localPosition = details.localPosition;

    for (final node in _diagram!.nodes) {
      final nodeRect = Rect.fromLTWH(
        node.x,
        node.y,
        node.width,
        node.height,
      );

      if (nodeRect.contains(localPosition)) {
        widget.onNodeTap!(node.id);
        break;
      }
    }
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Mermaid Parse Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.red.shade900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An interactive Mermaid diagram with pan and zoom support
class InteractiveMermaidDiagram extends StatefulWidget {
  /// Creates an interactive Mermaid diagram
  const InteractiveMermaidDiagram({
    super.key,
    required this.code,
    this.style,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.onNodeTap,
  });

  /// The Mermaid diagram code
  final String code;

  /// Style configuration
  final MermaidStyle? style;

  /// Minimum zoom scale
  final double minScale;

  /// Maximum zoom scale
  final double maxScale;

  /// Callback when a node is tapped
  final void Function(String nodeId)? onNodeTap;

  @override
  State<InteractiveMermaidDiagram> createState() =>
      _InteractiveMermaidDiagramState();
}

class _InteractiveMermaidDiagramState extends State<InteractiveMermaidDiagram> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用实际可用空间来计算布局
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 800.0;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 600.0;

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          constrained: false,
          child: MermaidDiagram(
            code: widget.code,
            style: widget.style,
            width: availableWidth,
            height: availableHeight,
            onNodeTap: widget.onNodeTap,
          ),
        );
      },
    );
  }
}
