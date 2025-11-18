/// A high-performance Flutter package for smooth markdown rendering with streaming support
library;

// Export configuration
export 'src/config/markdown_config.dart';
export 'src/config/style_sheet.dart';

// Export AST nodes
export 'src/parser/ast/markdown_node.dart';

// Export parser
export 'src/parser/markdown_parser.dart';

// Export renderer
export 'src/renderer/markdown_renderer.dart';
export 'src/renderer/widget_builder.dart';

// Export enhanced builders
export 'src/renderer/builders/enhanced_blockquote_builder.dart';
export 'src/renderer/builders/enhanced_code_block_builder.dart';
export 'src/renderer/builders/enhanced_header_builder.dart';
export 'src/renderer/builders/enhanced_link_builder.dart';

// Export widgets
export 'widgets/smooth_markdown.dart';

// TODO: Export streaming widget when implemented
// export 'widgets/smooth_markdown_stream.dart';
