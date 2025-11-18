# Flutter Smooth Markdown

A high-performance Flutter package for smooth markdown rendering with beautiful enhanced UI components.

## ✨ Features

- 🚀 **High Performance** - AST-based parsing with optimized rendering
- 📝 **Full Markdown Support** - Headers, paragraphs, lists, code blocks, blockquotes, links, and more
- 🎨 **Customizable Styling** - Easy theming with light/dark mode support and preset themes
- ✨ **Enhanced UI Components** - Beautiful code blocks with copy buttons, animated links, gradient blockquotes
- 🎯 **Extensible Builder System** - Custom widget builders for any markdown element
- 💻 **Code Blocks** - Syntax highlighting with language tags and copy functionality
- 🔗 **Links** - Hover animations and external link indicators
- 📐 **Flexible Theme System** - Multiple built-in themes (Default, GitHub, VS Code) with light/dark variants

## 🚀 Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_smooth_markdown: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

// Simple markdown rendering
SmoothMarkdown(
  data: '# Hello Markdown\n\nThis is **bold** and this is *italic*.',
  styleSheet: MarkdownStyleSheet.light(),
  onTapLink: (url) {
    // Handle link tap
    print('Tapped: $url');
  },
)
```

### Using Enhanced Components

Get beautiful UI with enhanced components for code blocks, links, blockquotes, and headers:

```dart
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

// Create custom renderer with enhanced components
final customRenderer = MarkdownRenderer(
  styleSheet: MarkdownStyleSheet.light(),
);

// Register enhanced builders
customRenderer.builderRegistry
  ..register('code_block', const EnhancedCodeBlockBuilder())
  ..register('blockquote', const EnhancedBlockquoteBuilder())
  ..register('link', const EnhancedLinkBuilder())
  ..register('header', const EnhancedHeaderBuilder());

// Render markdown
final nodes = MarkdownParser().parse(markdownText);
final widget = customRenderer.render(nodes);
```

Enhanced components include:
- **Code blocks** with copy button, language tags, and hover effects
- **Blockquotes** with quote icons, gradient backgrounds, and shadows
- **Links** with hover animations and external link indicators
- **Headers** with decorative accents and gradient borders

See [使用增强组件.md](docs/使用增强组件.md) for detailed usage.

## 📚 Documentation

For detailed documentation, see:

- [Core Requirements](docs/核心需求文档.md) - Project requirements and specifications
- [Development Plan](docs/开发计划.md) - Development roadmap and phases
- [UI Optimization Guide](docs/UI优化方案.md) - UI enhancement strategies
- [Using Enhanced Components](docs/使用增强组件.md) - Guide to enhanced UI components
- [Theme System](docs/主题系统.md) - Theming and customization guide
- [Phase 2 Summary](docs/Phase2完成总结.md) - Parser implementation details

## 🎯 Supported Markdown Syntax

### Text Formatting
- **Bold**: `**text**` or `__text__`
- *Italic*: `*text*` or `_text_`
- ~~Strikethrough~~: `~~text~~`
- `Inline code`: `` `code` ``

### Headers
```markdown
# H1
## H2
### H3
```

### Lists
```markdown
- Unordered list
1. Ordered list
- [ ] Task list
- [x] Completed task
```

### Code Blocks
````markdown
```dart
void main() {
  print('Hello, World!');
}
```
````

### Links and Images
```markdown
[Link text](https://example.com)
![Alt text](https://example.com/image.png)
```

### Tables
```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

## 🎨 Theming

The package includes multiple built-in themes with light and dark variants:

```dart
// Default themes
SmoothMarkdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet.light(), // or .dark()
)

// GitHub theme
SmoothMarkdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet.github(brightness: Brightness.light),
)

// VS Code theme
SmoothMarkdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet.vscode(brightness: Brightness.dark),
)

// Adapt to Flutter theme automatically
SmoothMarkdown(
  data: markdownText,
  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
)

// Custom theme
final customTheme = MarkdownStyleSheet.light().copyWith(
  h1Style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  linkStyle: TextStyle(color: Colors.blue),
  codeBlockDecoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(8),
  ),
);
```

See [主题系统.md](docs/主题系统.md) for complete theming guide.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## 📄 License

This project is licensed under the MIT License.

## 🔗 Links

- [GitHub Repository](https://github.com/JackCaow/flutter-smooth-markdown)
- [Issue Tracker](https://github.com/JackCaow/flutter-smooth-markdown/issues)

## 📝 Roadmap

### Completed
- [x] Phase 1: Core project structure and AST node definitions
- [x] Phase 2: Markdown parser implementation (87 tests passing)
- [x] Phase 3: Renderer implementation with widget builder system
- [x] Enhanced UI components (code blocks, blockquotes, links, headers)
- [x] Theme system with multiple presets (Default, GitHub, VS Code)
- [x] Example application with theme showcase

### In Progress
- [ ] Phase 4: Stream support for real-time rendering
- [ ] Syntax highlighting for code blocks
- [ ] Table support
- [ ] Image rendering with caching

### Planned
- [ ] Advanced features (footnotes, math equations)
- [ ] Performance optimization and benchmarking
- [ ] More theme presets
- [ ] Plugin system for custom parsers

---

Made with ❤️ for the Flutter community
