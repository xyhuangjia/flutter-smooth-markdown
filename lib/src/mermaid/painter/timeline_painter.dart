import 'package:flutter/material.dart';

import '../config/responsive_config.dart';
import '../models/timeline.dart';
import '../models/style.dart';

/// Painter for Timeline diagrams
class TimelinePainter extends CustomPainter {
  /// Creates a timeline painter
  const TimelinePainter({
    required this.timelineData,
    required this.style,
    this.deviceConfig,
  });

  /// The timeline data to render
  final TimelineChartData timelineData;

  /// Style configuration
  final MermaidStyle style;

  /// Responsive device configuration
  final MermaidDeviceConfig? deviceConfig;

  @override
  void paint(Canvas canvas, Size size) {
    if (timelineData.sections.isEmpty) return;

    final padding = style.padding;
    final isMobile = deviceConfig?.deviceType == DeviceType.mobile;
    final eventRadius = isMobile ? 6.0 : 8.0;
    final verticalSpacing = isMobile ? 30.0 : 40.0;

    // Calculate positions
    var currentY = padding;

    // Draw title if present
    if (timelineData.title != null) {
      _drawTitle(canvas, timelineData.title!, size.width / 2, currentY);
      currentY += 40.0;
    }

    // Timeline Y position
    final timelineY = currentY + verticalSpacing + 20;

    // Calculate layout
    final totalSections = timelineData.sections.length;
    final sectionWidth = (size.width - padding * 2) / totalSections;

    // Draw timeline line
    _drawTimelineLine(canvas, padding, size.width - padding, timelineY);

    // Draw sections and events
    for (var i = 0; i < totalSections; i++) {
      final section = timelineData.sections[i];
      final sectionX = padding + sectionWidth * i + sectionWidth / 2;
      final color = TimelineChartColors.getColorForSection(i);

      // Draw section marker (circle on timeline)
      _drawSectionMarker(canvas, sectionX, timelineY, eventRadius, color);

      // Draw section title ABOVE timeline
      _drawSectionTitle(
        canvas,
        section.title,
        sectionX,
        timelineY - verticalSpacing,
        color,
      );

      // Draw events BELOW timeline
      _drawEvents(
        canvas,
        section.events,
        sectionX,
        timelineY + verticalSpacing,
        sectionWidth * 0.9,
        color,
      );

      // Draw connector line from timeline to title (upward)
      _drawConnectorLine(
        canvas,
        sectionX,
        timelineY - eventRadius,
        timelineY - verticalSpacing + 15,
        color,
      );
    }
  }

  /// Draws the title
  void _drawTitle(Canvas canvas, String title, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: deviceConfig?.fontSize ?? 16.0,
          fontWeight: FontWeight.bold,
          color: Color(style.defaultNodeStyle.textColor ?? TimelineChartColors.textColor),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  /// Draws the horizontal timeline line
  void _drawTimelineLine(Canvas canvas, double startX, double endX, double y) {
    final paint = Paint()
      ..color = Color(TimelineChartColors.primaryColor)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  }

  /// Draws a section marker on the timeline
  void _drawSectionMarker(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int color,
  ) {
    // Draw outer circle
    final outerPaint = Paint()
      ..color = Color(color)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, outerPaint);

    // Draw inner circle (white)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius * 0.5, innerPaint);
  }

  /// Draws the section title
  void _drawSectionTitle(
    Canvas canvas,
    String title,
    double x,
    double y,
    int color,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: (deviceConfig?.fontSize ?? 12.0) + 2,
          fontWeight: FontWeight.bold,
          color: Color(color),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  /// Draws events for a section (below timeline)
  void _drawEvents(
    Canvas canvas,
    List<TimelineEvent> events,
    double centerX,
    double startY,
    double maxWidth,
    int color,
  ) {
    var currentY = startY;
    final eventSpacing = 15.0;
    final fontSize = deviceConfig?.fontSize ?? 11.0;
    final boxPadding = 8.0;

    for (var i = 0; i < events.length; i++) {
      final event = events[i];

      // Draw event box background
      final titlePainter = TextPainter(
        text: TextSpan(
          text: event.title,
          style: TextStyle(
            fontSize: fontSize,
            color: Color(TimelineChartColors.textColor),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 3,
        textAlign: TextAlign.center,
      );
      titlePainter.layout(maxWidth: maxWidth);

      // Draw rounded rectangle background
      final boxRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, currentY + titlePainter.height / 2),
          width: titlePainter.width + boxPadding * 2,
          height: titlePainter.height + boxPadding,
        ),
        const Radius.circular(6),
      );

      final boxPaint = Paint()
        ..color = Color(color).withOpacity(0.15)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(boxRect, boxPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Color(color).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(boxRect, borderPaint);

      // Draw event title
      titlePainter.paint(
        canvas,
        Offset(centerX - titlePainter.width / 2, currentY),
      );

      currentY += titlePainter.height + boxPadding + eventSpacing;

      // Draw event description if present
      if (event.description != null && event.description!.isNotEmpty) {
        final descPainter = TextPainter(
          text: TextSpan(
            text: event.description,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: Color(TimelineChartColors.textColor).withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 2,
          textAlign: TextAlign.center,
        );
        descPainter.layout(maxWidth: maxWidth);
        descPainter.paint(
          canvas,
          Offset(centerX - descPainter.width / 2, currentY),
        );
        currentY += descPainter.height + 5;
      }
    }
  }

  /// Draws a connector line from timeline to section title (upward)
  void _drawConnectorLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    int color,
  ) {
    final paint = Paint()
      ..color = Color(color).withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, startY),
      Offset(x, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.timelineData != timelineData ||
        oldDelegate.style != style ||
        oldDelegate.deviceConfig != deviceConfig;
  }
}
