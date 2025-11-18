import 'package:flutter/material.dart';

/// Defines the visual styling for Markdown elements
class MarkdownStyleSheet {
  /// Creates a new Markdown style sheet
  const MarkdownStyleSheet({
    this.textStyle,
    this.h1Style,
    this.h2Style,
    this.h3Style,
    this.h4Style,
    this.h5Style,
    this.h6Style,
    this.paragraphStyle,
    this.blockquoteStyle,
    this.codeBlockStyle,
    this.inlineCodeStyle,
    this.linkStyle,
    this.boldStyle,
    this.italicStyle,
    this.strikethroughStyle,
    this.listBulletStyle,
    this.tableHeaderStyle,
    this.tableCellStyle,
    this.blockquoteDecoration,
    this.codeBlockDecoration,
    this.tableBorder,
    this.tableHeaderDecoration,
    this.tableOddRowDecoration,
    this.tableEvenRowDecoration,
    this.horizontalRuleColor,
    this.horizontalRuleThickness,
    this.blockSpacing,
    this.listIndent,
    this.blockquotePadding,
    this.codeBlockPadding,
    this.tableCellPadding,
  });

  /// Creates a default light theme style sheet
  factory MarkdownStyleSheet.light({TextStyle? baseStyle}) {
    final base = baseStyle ??
        const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        );

    return MarkdownStyleSheet(
      textStyle: base,
      h1Style: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2Style: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3Style: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      h4Style: base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      h5Style: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      h6Style: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      paragraphStyle: base,
      blockquoteStyle: base.copyWith(
        color: Colors.black54,
        fontStyle: FontStyle.italic,
      ),
      codeBlockStyle: base.copyWith(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Colors.black87,
      ),
      inlineCodeStyle: base.copyWith(
        fontFamily: 'monospace',
        fontSize: 14,
        backgroundColor: Colors.grey[200],
        color: Colors.red[700],
      ),
      linkStyle: base.copyWith(
        color: Colors.blue[700],
        decoration: TextDecoration.underline,
      ),
      boldStyle: base.copyWith(fontWeight: FontWeight.bold),
      italicStyle: base.copyWith(fontStyle: FontStyle.italic),
      strikethroughStyle: base.copyWith(
        decoration: TextDecoration.lineThrough,
      ),
      listBulletStyle: base,
      tableHeaderStyle: base.copyWith(fontWeight: FontWeight.bold),
      tableCellStyle: base,
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[400]!,
            width: 4,
          ),
        ),
        color: Colors.grey[50],
      ),
      codeBlockDecoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      tableBorder: TableBorder.all(
        color: Colors.grey[400]!,
        width: 1,
      ),
      tableHeaderDecoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      tableOddRowDecoration: BoxDecoration(
        color: Colors.white,
      ),
      tableEvenRowDecoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      horizontalRuleColor: Colors.grey[400],
      horizontalRuleThickness: 1,
      blockSpacing: 16,
      listIndent: 24,
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      codeBlockPadding: const EdgeInsets.all(12),
      tableCellPadding: const EdgeInsets.all(8),
    );
  }

  /// Creates a style sheet from Flutter's ThemeData
  ///
  /// Automatically adapts to the current brightness (light/dark mode)
  factory MarkdownStyleSheet.fromTheme(ThemeData theme) {
    final brightness = theme.brightness;
    final baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();

    return brightness == Brightness.dark
        ? MarkdownStyleSheet.dark(baseStyle: baseStyle)
        : MarkdownStyleSheet.light(baseStyle: baseStyle);
  }

  /// Creates a style sheet based on brightness
  factory MarkdownStyleSheet.fromBrightness(
    Brightness brightness, {
    TextStyle? baseStyle,
  }) {
    return brightness == Brightness.dark
        ? MarkdownStyleSheet.dark(baseStyle: baseStyle)
        : MarkdownStyleSheet.light(baseStyle: baseStyle);
  }

  /// Creates a GitHub-style theme
  factory MarkdownStyleSheet.github({Brightness brightness = Brightness.light}) {
    if (brightness == Brightness.dark) {
      return MarkdownStyleSheet.dark().copyWith(
        textStyle: const TextStyle(fontSize: 16, color: Color(0xFFE6EDF3)),
        codeBlockStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Color(0xFFE6EDF3),
        ),
        codeBlockDecoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(6),
        ),
        linkStyle: const TextStyle(
          color: Color(0xFF58A6FF),
          decoration: TextDecoration.underline,
        ),
      );
    }

    return MarkdownStyleSheet.light().copyWith(
      textStyle: const TextStyle(fontSize: 16, color: Color(0xFF24292F)),
      codeBlockStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Color(0xFF24292F),
      ),
      codeBlockDecoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(6),
      ),
      linkStyle: const TextStyle(
        color: Color(0xFF0969DA),
        decoration: TextDecoration.underline,
      ),
    );
  }

  /// Creates a VS Code-style theme
  factory MarkdownStyleSheet.vscode({Brightness brightness = Brightness.light}) {
    if (brightness == Brightness.dark) {
      return MarkdownStyleSheet.dark().copyWith(
        textStyle: const TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),
        codeBlockStyle: const TextStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
          color: Color(0xFFD4D4D4),
        ),
        codeBlockDecoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF404040)),
        ),
        linkStyle: const TextStyle(
          color: Color(0xFF4FC1FF),
          decoration: TextDecoration.underline,
        ),
      );
    }

    return MarkdownStyleSheet.light().copyWith(
      textStyle: const TextStyle(fontSize: 16, color: Color(0xFF1E1E1E)),
      codeBlockStyle: const TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        color: Color(0xFF1E1E1E),
      ),
      codeBlockDecoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      linkStyle: const TextStyle(
        color: Color(0xFF0066BF),
        decoration: TextDecoration.underline,
      ),
    );
  }

  /// Creates a default dark theme style sheet
  factory MarkdownStyleSheet.dark({TextStyle? baseStyle}) {
    final base = baseStyle ??
        const TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        );

    return MarkdownStyleSheet(
      textStyle: base,
      h1Style: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: Colors.white,
      ),
      h2Style: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: Colors.white,
      ),
      h3Style: base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white,
      ),
      h4Style: base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white,
      ),
      h5Style: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white,
      ),
      h6Style: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white,
      ),
      paragraphStyle: base,
      blockquoteStyle: base.copyWith(
        color: Colors.white60,
        fontStyle: FontStyle.italic,
      ),
      codeBlockStyle: base.copyWith(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Colors.white70,
      ),
      inlineCodeStyle: base.copyWith(
        fontFamily: 'monospace',
        fontSize: 14,
        backgroundColor: Colors.grey[800],
        color: Colors.red[300],
      ),
      linkStyle: base.copyWith(
        color: Colors.blue[300],
        decoration: TextDecoration.underline,
      ),
      boldStyle: base.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      italicStyle: base.copyWith(fontStyle: FontStyle.italic),
      strikethroughStyle: base.copyWith(
        decoration: TextDecoration.lineThrough,
      ),
      listBulletStyle: base,
      tableHeaderStyle: base.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      tableCellStyle: base,
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[600]!,
            width: 4,
          ),
        ),
        color: Colors.grey[900],
      ),
      codeBlockDecoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[700]!),
      ),
      tableBorder: TableBorder.all(
        color: Colors.grey[700]!,
        width: 1,
      ),
      tableHeaderDecoration: BoxDecoration(
        color: Colors.grey[850],
      ),
      tableOddRowDecoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      tableEvenRowDecoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      horizontalRuleColor: Colors.grey[700],
      horizontalRuleThickness: 1,
      blockSpacing: 16,
      listIndent: 24,
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      codeBlockPadding: const EdgeInsets.all(12),
      tableCellPadding: const EdgeInsets.all(8),
    );
  }

  /// Default text style
  final TextStyle? textStyle;

  /// H1 heading style
  final TextStyle? h1Style;

  /// H2 heading style
  final TextStyle? h2Style;

  /// H3 heading style
  final TextStyle? h3Style;

  /// H4 heading style
  final TextStyle? h4Style;

  /// H5 heading style
  final TextStyle? h5Style;

  /// H6 heading style
  final TextStyle? h6Style;

  /// Paragraph style
  final TextStyle? paragraphStyle;

  /// Blockquote text style
  final TextStyle? blockquoteStyle;

  /// Code block text style
  final TextStyle? codeBlockStyle;

  /// Inline code style
  final TextStyle? inlineCodeStyle;

  /// Link style
  final TextStyle? linkStyle;

  /// Bold text style
  final TextStyle? boldStyle;

  /// Italic text style
  final TextStyle? italicStyle;

  /// Strikethrough text style
  final TextStyle? strikethroughStyle;

  /// List bullet style
  final TextStyle? listBulletStyle;

  /// Table header style
  final TextStyle? tableHeaderStyle;

  /// Table cell style
  final TextStyle? tableCellStyle;

  /// Decoration for blockquotes
  final BoxDecoration? blockquoteDecoration;

  /// Decoration for code blocks
  final BoxDecoration? codeBlockDecoration;

  /// Border for tables
  final TableBorder? tableBorder;

  /// Decoration for table header row
  final BoxDecoration? tableHeaderDecoration;

  /// Decoration for odd table rows
  final BoxDecoration? tableOddRowDecoration;

  /// Decoration for even table rows
  final BoxDecoration? tableEvenRowDecoration;

  /// Color for horizontal rules
  final Color? horizontalRuleColor;

  /// Thickness of horizontal rules
  final double? horizontalRuleThickness;

  /// Spacing between block elements
  final double? blockSpacing;

  /// Indentation for lists
  final double? listIndent;

  /// Padding for blockquotes
  final EdgeInsets? blockquotePadding;

  /// Padding for code blocks
  final EdgeInsets? codeBlockPadding;

  /// Padding for table cells
  final EdgeInsets? tableCellPadding;

  /// Creates a copy of this style sheet with the given fields replaced
  MarkdownStyleSheet copyWith({
    TextStyle? textStyle,
    TextStyle? h1Style,
    TextStyle? h2Style,
    TextStyle? h3Style,
    TextStyle? h4Style,
    TextStyle? h5Style,
    TextStyle? h6Style,
    TextStyle? paragraphStyle,
    TextStyle? blockquoteStyle,
    TextStyle? codeBlockStyle,
    TextStyle? inlineCodeStyle,
    TextStyle? linkStyle,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? strikethroughStyle,
    TextStyle? listBulletStyle,
    TextStyle? tableHeaderStyle,
    TextStyle? tableCellStyle,
    BoxDecoration? blockquoteDecoration,
    BoxDecoration? codeBlockDecoration,
    TableBorder? tableBorder,
    BoxDecoration? tableHeaderDecoration,
    BoxDecoration? tableOddRowDecoration,
    BoxDecoration? tableEvenRowDecoration,
    Color? horizontalRuleColor,
    double? horizontalRuleThickness,
    double? blockSpacing,
    double? listIndent,
    EdgeInsets? blockquotePadding,
    EdgeInsets? codeBlockPadding,
    EdgeInsets? tableCellPadding,
  }) {
    return MarkdownStyleSheet(
      textStyle: textStyle ?? this.textStyle,
      h1Style: h1Style ?? this.h1Style,
      h2Style: h2Style ?? this.h2Style,
      h3Style: h3Style ?? this.h3Style,
      h4Style: h4Style ?? this.h4Style,
      h5Style: h5Style ?? this.h5Style,
      h6Style: h6Style ?? this.h6Style,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle,
      blockquoteStyle: blockquoteStyle ?? this.blockquoteStyle,
      codeBlockStyle: codeBlockStyle ?? this.codeBlockStyle,
      inlineCodeStyle: inlineCodeStyle ?? this.inlineCodeStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      boldStyle: boldStyle ?? this.boldStyle,
      italicStyle: italicStyle ?? this.italicStyle,
      strikethroughStyle: strikethroughStyle ?? this.strikethroughStyle,
      listBulletStyle: listBulletStyle ?? this.listBulletStyle,
      tableHeaderStyle: tableHeaderStyle ?? this.tableHeaderStyle,
      tableCellStyle: tableCellStyle ?? this.tableCellStyle,
      blockquoteDecoration: blockquoteDecoration ?? this.blockquoteDecoration,
      codeBlockDecoration: codeBlockDecoration ?? this.codeBlockDecoration,
      tableBorder: tableBorder ?? this.tableBorder,
      tableHeaderDecoration: tableHeaderDecoration ?? this.tableHeaderDecoration,
      tableOddRowDecoration: tableOddRowDecoration ?? this.tableOddRowDecoration,
      tableEvenRowDecoration: tableEvenRowDecoration ?? this.tableEvenRowDecoration,
      horizontalRuleColor: horizontalRuleColor ?? this.horizontalRuleColor,
      horizontalRuleThickness:
          horizontalRuleThickness ?? this.horizontalRuleThickness,
      blockSpacing: blockSpacing ?? this.blockSpacing,
      listIndent: listIndent ?? this.listIndent,
      blockquotePadding: blockquotePadding ?? this.blockquotePadding,
      codeBlockPadding: codeBlockPadding ?? this.codeBlockPadding,
      tableCellPadding: tableCellPadding ?? this.tableCellPadding,
    );
  }
}
