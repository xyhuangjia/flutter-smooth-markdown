# Flutter Smooth Markdown

[![pub package](https://img.shields.io/pub/v/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown)
[![popularity](https://img.shields.io/pub/popularity/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)
[![likes](https://img.shields.io/pub/likes/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)

A high-performance Flutter markdown renderer with syntax highlighting, LaTeX math formulas, tables, footnotes, SVG images, and real-time streaming support. Beautiful, customizable UI components for modern Flutter apps.

## ✨ Features

- 🚀 **High Performance** - AST-based parsing with optimized rendering
- 📝 **Full Markdown Support** - Headers, paragraphs, lists, code blocks, blockquotes, links, tables, and more
- 🎨 **Customizable Styling** - Easy theming with light/dark mode support and preset themes
- ✨ **Enhanced UI Components** - Beautiful code blocks with copy buttons, animated links, gradient blockquotes
- 🎯 **Extensible Builder System** - Custom widget builders for any markdown element
- 💻 **Code Blocks** - Syntax highlighting with language tags and copy functionality
- 🔗 **Links** - Hover animations and external link indicators
- 📐 **Flexible Theme System** - Multiple built-in themes (Default, GitHub, VS Code) with light/dark variants
- 📊 **Table Support** - Beautiful table rendering with proper styling and borders
- 🧮 **Math Formulas** - LaTeX equation rendering with flutter_math_fork
- 📎 **Footnotes** - Reference and definition support for academic writing
- 🖼️ **SVG Images** - Native SVG rendering support with flutter_svg
- 📋 **Details & Summary** - Collapsible content sections with interactive expand/collapse
- 🌐 **Internationalization** - Multi-language example app (6 languages supported)
- 🎬 **Streaming Support** - Real-time markdown rendering with StreamMarkdown widget
- 🔌 **Plugin System** - Extensible parser plugins for custom syntax (Mention, Hashtag, Emoji, AI blocks)
- 🤖 **AI Chat Support** - Built-in plugins for AI responses (Thinking, Artifact, Tool Call blocks)
- 📊 **Mermaid Diagrams** - Native rendering of flowcharts, sequence diagrams, pie charts, and Gantt charts

## 📺 Demo

### Main Interface
<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/main.jpg" width="600" alt="Main Interface">

### Code Blocks with Syntax Highlighting
<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/code.jpg" width="600" alt="Enhanced Code Blocks">

### Math Formula Rendering (LaTeX)
<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/latx.jpg" width="600" alt="LaTeX Math Formulas">

### Streaming Support
<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/streaming.gif" width="600" alt="Real-time Streaming">

> **Note**: Run the example app to see all features in action: `cd example && flutter run`

## 🚀 Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_smooth_markdown: ^0.5.1
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

See [使用增强组件.md](doc/使用增强组件.md) for detailed usage.

## 📚 Documentation

For detailed documentation, see:

- [Core Requirements](doc/核心需求文档.md) - Project requirements and specifications
- [Development Plan](doc/开发计划.md) - Development roadmap and phases
- [UI Optimization Guide](doc/UI优化方案.md) - UI enhancement strategies
- [Using Enhanced Components](doc/使用增强组件.md) - Guide to enhanced UI components
- [Theme System](doc/主题系统.md) - Theming and customization guide
- [Phase 2 Summary](doc/Phase2完成总结.md) - Parser implementation details

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
![Flutter Logo](https://storage.googleapis.com/cms-storage-bucket/4fd0db61df0567c0f352.png)
```

### Tables
```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

### Math Formulas
```markdown
Inline math: $E = mc^2$

Block math:
$$
\int_{a}^{b} f(x) dx = F(b) - F(a)
$$
```

### Footnotes
```markdown
This text has a footnote[^1].

[^1]: This is the footnote content.
```

### SVG Images
```markdown
![Flutter Icon](https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/flutter.svg)
```

### Details & Summary (Collapsible Sections)
```markdown
<details>
<summary>Click to expand</summary>
This content is hidden by default and will only show when the user clicks the summary.
</details>

<details open>
<summary>Expanded by default</summary>
This section is expanded by default using the `open` attribute.
</details>
```

### Plugin System (Custom Syntax)
```dart
// Register custom parser plugins
final registry = ParserPluginRegistry();
registry.register(const MentionPlugin());    // @username
registry.register(const HashtagPlugin());    // #topic
registry.register(const EmojiPlugin());      // :smile:

// Use with parser
final parser = MarkdownParser(plugins: registry);
final nodes = parser.parse('@john mentioned #flutter :rocket:');
```

### AI Chat Plugins
```dart
// Built-in AI response plugins
final registry = ParserPluginRegistry();
registry.register(const ThinkingPlugin());   // <thinking>...</thinking>
registry.register(const ArtifactPlugin());   // <artifact>...</artifact>
registry.register(const ToolCallPlugin());   // <tool_use>...</tool_use>

// Render AI responses with thinking process
SmoothMarkdown(
  data: aiResponse,
  plugins: registry,
)
```

### Mermaid Diagrams (Flowcharts, Gantt Charts, etc.)
```dart
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

// Render Mermaid diagrams natively
MermaidDiagram(
  code: '''
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD

    section Planning
        Requirements :done, req, 2024-01-01, 14d
        Design :done, des, after req, 10d

    section Development
        Frontend :active, front, 2024-01-25, 30d
        Backend :crit, back, 2024-01-20, 35d

    section Release
        Testing :test, 2024-02-25, 10d
        Launch :milestone, launch, 2024-03-07, 0d
  ''',
  style: MermaidStyle.dark(),
)
```

Supported diagram types:
- **Flowcharts** - `graph TD/LR/BT/RL` with various node shapes
- **Sequence Diagrams** - Message flows between participants
- **Pie Charts** - Data visualization with labels and percentages
- **Gantt Charts** - Project timelines with tasks, sections, dependencies, and milestones
- **Interactive Mode** - Pan/zoom support with adaptive height for diagram containers

## 💡 Use Cases

Perfect for building:
- 📱 **Documentation Apps** - Technical documentation with code examples
- 💬 **Chat Applications** - Rich text messaging with markdown support
- 📝 **Note-Taking Apps** - Markdown editors and viewers
- 🎓 **Educational Platforms** - Content with LaTeX formulas and code
- 📰 **Content Management** - Blog posts and articles with formatting
- 🤖 **AI Chat Interfaces** - Real-time streaming markdown responses

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

## 🔍 Keywords

`flutter markdown` `markdown renderer` `markdown widget` `syntax highlighting` `code highlighting` `latex math` `math formulas` `markdown parser` `markdown viewer` `rich text` `streaming markdown` `real-time rendering` `flutter ui` `markdown editor` `documentation` `note taking` `chat app` `ai chat` `markdown to widget`

## 🔗 Links

- [GitHub Repository](https://github.com/JackCaow/flutter-smooth-markdown)
- [Issue Tracker](https://github.com/JackCaow/flutter-smooth-markdown/issues)

## 📝 Roadmap

### Completed
- [x] Phase 1: Core project structure and AST node definitions
- [x] Phase 2: Markdown parser implementation (87+ tests passing)
- [x] Phase 3: Renderer implementation with widget builder system
- [x] Enhanced UI components (code blocks, blockquotes, links, headers)
- [x] Theme system with multiple presets (Default, GitHub, VS Code)
- [x] Example application with theme showcase
- [x] Syntax highlighting for code blocks with flutter_highlight
- [x] Table support with proper styling
- [x] Image rendering with caching (cached_network_image)
- [x] SVG image support (flutter_svg)
- [x] Math formula rendering (LaTeX with flutter_math_fork)
- [x] Footnote support (references and definitions)
- [x] Multi-language internationalization (Chinese, English, Japanese, Spanish, French, Korean)
- [x] Phase 4: Stream support for real-time rendering with StreamMarkdown widget
- [x] Streaming demo in example app
- [x] Details & Summary support for collapsible content sections
- [x] Plugin system for custom parsers (MentionPlugin, HashtagPlugin, EmojiPlugin, AdmonitionPlugin)
- [x] AI Chat plugins (ThinkingPlugin, ArtifactPlugin, ToolCallPlugin)
- [x] AI Chat Demo with Qwen3 Max integration and thinking mode
- [x] Mermaid diagram support (Flowcharts, Sequence, Pie Charts, Gantt Charts)

### In Progress
- [ ] Performance optimization and benchmarking
- [ ] API documentation and code comments

### Planned
- [ ] More theme presets
- [ ] Advanced table features (sorting, filtering)
- [ ] Accessibility improvements (screen reader support)

---

Made with ❤️ for the Flutter community
