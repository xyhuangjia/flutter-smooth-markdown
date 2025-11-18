import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
import '../markdown_renderer.dart';
import '../widget_builder.dart';

/// Builder for table nodes
class TableBuilder extends MarkdownWidgetBuilder {
  /// Creates a new table builder
  const TableBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is TableNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final tableNode = node as TableNode;
    final renderer = MarkdownRenderer(styleSheet: styleSheet);

    // Build header row
    final headerRow = _buildRow(
      tableNode.headers,
      tableNode.alignments,
      styleSheet,
      renderer,
      context,
      isHeader: true,
    );

    // Build data rows
    final dataRows = tableNode.rows.map((row) {
      return _buildRow(
        row.cells,
        tableNode.alignments,
        styleSheet,
        renderer,
        context,
        isHeader: false,
      );
    }).toList();

    // Combine all rows
    final allRows = [headerRow, ...dataRows];

    return Table(
      border: styleSheet.tableBorder,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: _buildColumnWidths(tableNode.alignments),
      children: allRows,
    );
  }

  /// Builds a table row
  TableRow _buildRow(
    List<List<MarkdownNode>> cells,
    List<TableAlignment?> alignments,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderer renderer,
    MarkdownRenderContext context, {
    required bool isHeader,
  }) {
    final cellWidgets = <Widget>[];

    for (var i = 0; i < cells.length; i++) {
      final cellContent = cells[i];
      final alignment = i < alignments.length ? alignments[i] : null;

      cellWidgets.add(
        _buildCell(
          cellContent,
          alignment,
          styleSheet,
          renderer,
          context,
          isHeader: isHeader,
        ),
      );
    }

    return TableRow(
      decoration: isHeader ? styleSheet.tableHeaderDecoration : null,
      children: cellWidgets,
    );
  }

  /// Builds a table cell
  Widget _buildCell(
    List<MarkdownNode> content,
    TableAlignment? alignment,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderer renderer,
    MarkdownRenderContext context, {
    required bool isHeader,
  }) {
    final textStyle = isHeader
        ? styleSheet.tableHeaderStyle ?? styleSheet.textStyle
        : styleSheet.tableCellStyle ?? styleSheet.textStyle;

    final cellWidget = renderer.renderInline(
      content,
      textStyle,
      context,
    );

    final alignmentValue = _getAlignment(alignment);

    return Container(
      padding: styleSheet.tableCellPadding ?? const EdgeInsets.all(8),
      alignment: alignmentValue,
      child: cellWidget,
    );
  }

  /// Converts TableAlignment to Flutter Alignment
  Alignment _getAlignment(TableAlignment? alignment) {
    switch (alignment) {
      case TableAlignment.left:
        return Alignment.centerLeft;
      case TableAlignment.center:
        return Alignment.center;
      case TableAlignment.right:
        return Alignment.centerRight;
      case null:
        return Alignment.centerLeft; // Default to left
    }
  }

  /// Builds column widths based on alignments
  Map<int, TableColumnWidth> _buildColumnWidths(List<TableAlignment?> alignments) {
    // For now, use flexible columns for all
    // Could be enhanced to support fixed widths or intrinsic sizing
    return {};
  }
}
