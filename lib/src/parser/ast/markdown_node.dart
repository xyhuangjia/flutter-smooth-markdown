/// Base class for all Markdown AST nodes
///
/// This abstract class defines the common interface for all nodes
/// in the Markdown Abstract Syntax Tree.
abstract class MarkdownNode {
  /// Creates a new Markdown node
  const MarkdownNode();

  /// The type identifier for this node
  String get type;

  /// Converts this node to a JSON representation
  Map<String, dynamic> toJson();

  /// Creates a copy of this node
  MarkdownNode copyWith();

  @override
  String toString() => 'MarkdownNode(type: $type)';
}

/// Represents a text node in the AST
class TextNode extends MarkdownNode {
  /// Creates a new text node
  const TextNode(this.content);

  /// The text content
  final String content;

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
      };

  @override
  TextNode copyWith({String? content}) {
    return TextNode(content ?? this.content);
  }

  @override
  String toString() => 'TextNode(content: $content)';
}

/// Represents a header node (H1-H6)
class HeaderNode extends MarkdownNode {
  /// Creates a new header node
  const HeaderNode({
    required this.level,
    required this.content,
  }) : assert(level >= 1 && level <= 6, 'Header level must be between 1 and 6');

  /// The header level (1-6)
  final int level;

  /// The header content
  final String content;

  @override
  String get type => 'header';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'level': level,
        'content': content,
      };

  @override
  HeaderNode copyWith({int? level, String? content}) {
    return HeaderNode(
      level: level ?? this.level,
      content: content ?? this.content,
    );
  }

  @override
  String toString() => 'HeaderNode(level: $level, content: $content)';
}

/// Represents a paragraph node
class ParagraphNode extends MarkdownNode {
  /// Creates a new paragraph node
  const ParagraphNode(this.children);

  /// The child nodes
  final List<MarkdownNode> children;

  @override
  String get type => 'paragraph';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
      };

  @override
  ParagraphNode copyWith({List<MarkdownNode>? children}) {
    return ParagraphNode(children ?? this.children);
  }

  @override
  String toString() => 'ParagraphNode(children: ${children.length})';
}

/// Represents a code block node
class CodeBlockNode extends MarkdownNode {
  /// Creates a new code block node
  const CodeBlockNode({
    required this.code,
    this.language,
  });

  /// The code content
  final String code;

  /// The programming language (optional)
  final String? language;

  @override
  String get type => 'code_block';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        if (language != null) 'language': language,
      };

  @override
  CodeBlockNode copyWith({String? code, String? language}) {
    return CodeBlockNode(
      code: code ?? this.code,
      language: language ?? this.language,
    );
  }

  @override
  String toString() =>
      'CodeBlockNode(language: $language, code: ${code.substring(0, code.length > 20 ? 20 : code.length)}...)';
}

/// Represents a list node (ordered or unordered)
class ListNode extends MarkdownNode {
  /// Creates a new list node
  const ListNode({
    required this.items,
    this.ordered = false,
    this.startIndex = 1,
  });

  /// The list items
  final List<ListItemNode> items;

  /// Whether this is an ordered list
  final bool ordered;

  /// The starting index for ordered lists
  final int startIndex;

  @override
  String get type => 'list';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ordered': ordered,
        'startIndex': startIndex,
        'items': items.map((item) => item.toJson()).toList(),
      };

  @override
  ListNode copyWith({
    List<ListItemNode>? items,
    bool? ordered,
    int? startIndex,
  }) {
    return ListNode(
      items: items ?? this.items,
      ordered: ordered ?? this.ordered,
      startIndex: startIndex ?? this.startIndex,
    );
  }

  @override
  String toString() =>
      'ListNode(ordered: $ordered, items: ${items.length})';
}

/// Represents a list item node
class ListItemNode extends MarkdownNode {
  /// Creates a new list item node
  const ListItemNode({
    required this.children,
    this.checked,
  });

  /// The child nodes
  final List<MarkdownNode> children;

  /// For task lists, whether the item is checked
  final bool? checked;

  @override
  String get type => 'list_item';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
        if (checked != null) 'checked': checked,
      };

  @override
  ListItemNode copyWith({
    List<MarkdownNode>? children,
    bool? checked,
  }) {
    return ListItemNode(
      children: children ?? this.children,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toString() => 'ListItemNode(checked: $checked, children: ${children.length})';
}

/// Represents a blockquote node
class BlockquoteNode extends MarkdownNode {
  /// Creates a new blockquote node
  const BlockquoteNode(this.children);

  /// The child nodes
  final List<MarkdownNode> children;

  @override
  String get type => 'blockquote';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
      };

  @override
  BlockquoteNode copyWith({List<MarkdownNode>? children}) {
    return BlockquoteNode(children ?? this.children);
  }

  @override
  String toString() => 'BlockquoteNode(children: ${children.length})';
}

/// Represents a horizontal rule (divider)
class HorizontalRuleNode extends MarkdownNode {
  /// Creates a new horizontal rule node
  const HorizontalRuleNode();

  @override
  String get type => 'horizontal_rule';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  HorizontalRuleNode copyWith() => const HorizontalRuleNode();

  @override
  String toString() => 'HorizontalRuleNode()';
}

/// Represents an inline code node
class InlineCodeNode extends MarkdownNode {
  /// Creates a new inline code node
  const InlineCodeNode(this.code);

  /// The code content
  final String code;

  @override
  String get type => 'inline_code';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
      };

  @override
  InlineCodeNode copyWith({String? code}) {
    return InlineCodeNode(code ?? this.code);
  }

  @override
  String toString() => 'InlineCodeNode(code: $code)';
}

/// Represents a bold (strong) text node
class BoldNode extends MarkdownNode {
  /// Creates a new bold node
  const BoldNode(this.children);

  /// The child nodes
  final List<MarkdownNode> children;

  @override
  String get type => 'bold';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
      };

  @override
  BoldNode copyWith({List<MarkdownNode>? children}) {
    return BoldNode(children ?? this.children);
  }

  @override
  String toString() => 'BoldNode(children: ${children.length})';
}

/// Represents an italic (emphasis) text node
class ItalicNode extends MarkdownNode {
  /// Creates a new italic node
  const ItalicNode(this.children);

  /// The child nodes
  final List<MarkdownNode> children;

  @override
  String get type => 'italic';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
      };

  @override
  ItalicNode copyWith({List<MarkdownNode>? children}) {
    return ItalicNode(children ?? this.children);
  }

  @override
  String toString() => 'ItalicNode(children: ${children.length})';
}

/// Represents a strikethrough text node
class StrikethroughNode extends MarkdownNode {
  /// Creates a new strikethrough node
  const StrikethroughNode(this.children);

  /// The child nodes
  final List<MarkdownNode> children;

  @override
  String get type => 'strikethrough';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((child) => child.toJson()).toList(),
      };

  @override
  StrikethroughNode copyWith({List<MarkdownNode>? children}) {
    return StrikethroughNode(children ?? this.children);
  }

  @override
  String toString() => 'StrikethroughNode(children: ${children.length})';
}

/// Represents a link node
class LinkNode extends MarkdownNode {
  /// Creates a new link node
  const LinkNode({
    required this.url,
    required this.children,
    this.title,
  });

  /// The URL
  final String url;

  /// The link text as child nodes
  final List<MarkdownNode> children;

  /// Optional title attribute
  final String? title;

  @override
  String get type => 'link';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        'children': children.map((child) => child.toJson()).toList(),
        if (title != null) 'title': title,
      };

  @override
  LinkNode copyWith({
    String? url,
    List<MarkdownNode>? children,
    String? title,
  }) {
    return LinkNode(
      url: url ?? this.url,
      children: children ?? this.children,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'LinkNode(url: $url, title: $title)';
}

/// Represents an image node
class ImageNode extends MarkdownNode {
  /// Creates a new image node
  const ImageNode({
    required this.url,
    required this.alt,
    this.title,
  });

  /// The image URL
  final String url;

  /// The alt text
  final String alt;

  /// Optional title attribute
  final String? title;

  @override
  String get type => 'image';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        'alt': alt,
        if (title != null) 'title': title,
      };

  @override
  ImageNode copyWith({String? url, String? alt, String? title}) {
    return ImageNode(
      url: url ?? this.url,
      alt: alt ?? this.alt,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'ImageNode(url: $url, alt: $alt)';
}
