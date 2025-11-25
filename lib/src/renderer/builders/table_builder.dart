import 'package:flutter/material.dart';

import '../../config/style_sheet.dart';
import '../../parser/ast/markdown_node.dart';
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

    // Determine the column count - use the maximum of headers, alignments, and all row cell counts
    var columnCount = tableNode.alignments.length;

    // Consider header length
    if (tableNode.headers.length > columnCount) {
      columnCount = tableNode.headers.length;
    }

    // Consider all data row lengths
    for (final row in tableNode.rows) {
      if (row.cells.length > columnCount) {
        columnCount = row.cells.length;
      }
    }

    // Ensure at least 1 column
    if (columnCount == 0) {
      columnCount = 1;
    }

    // Build header row
    final headerRow = _buildRow(
      tableNode.headers,
      tableNode.alignments,
      columnCount,
      styleSheet,
      context,
      isHeader: true,
    );

    // Build data rows
    final dataRows = tableNode.rows.map((row) {
      return _buildRow(
        row.cells,
        tableNode.alignments,
        columnCount,
        styleSheet,
        context,
        isHeader: false,
      );
    }).toList();

    // Combine all rows
    final allRows = [headerRow, ...dataRows];

    return Table(
      border: styleSheet.tableBorder,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: _buildColumnWidths(columnCount),
      children: allRows,
    );
  }

  /// Builds a table row
  TableRow _buildRow(
    List<List<MarkdownNode>> cells,
    List<TableAlignment?> alignments,
    int columnCount,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context, {
    required bool isHeader,
  }) {
    final cellWidgets = <Widget>[];

    for (var i = 0; i < columnCount; i++) {
      // Get cell content, or use empty list if this column doesn't exist in this row
      final cellContent = i < cells.length ? cells[i] : <MarkdownNode>[];
      final alignment = i < alignments.length ? alignments[i] : null;

      cellWidgets.add(
        _buildCell(
          cellContent,
          alignment,
          styleSheet,
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
    MarkdownRenderContext context, {
    required bool isHeader,
  }) {
    final textStyle = isHeader
        ? styleSheet.tableHeaderStyle ?? styleSheet.textStyle
        : styleSheet.tableCellStyle ?? styleSheet.textStyle;

    final inlineRenderer = context.inlineRenderer;
    Widget cellWidget;
    if (inlineRenderer != null) {
      cellWidget = inlineRenderer(content, textStyle);
    } else {
      // Fallback
      final text = content.whereType<TextNode>().map((n) => n.content).join();
      cellWidget = Text(text, style: textStyle);
    }

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

  /// Builds column widths based on column count
  Map<int, TableColumnWidth> _buildColumnWidths(int columnCount) {
    // For now, use flexible columns for all
    // Could be enhanced to support fixed widths or intrinsic sizing
    return {};
  }
}
