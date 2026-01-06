# Flutter Smooth Markdown

[![pub package](https://img.shields.io/pub/v/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown)
[![popularity](https://img.shields.io/pub/popularity/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)
[![likes](https://img.shields.io/pub/likes/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)

A high-performance Flutter markdown renderer with syntax highlighting, LaTeX math, tables, footnotes, SVG images, Mermaid diagrams, and real-time streaming support.

## Features

| Category | Features |
|----------|----------|
| **Rendering** | AST-based parsing, syntax highlighting, real-time streaming |
| **Markdown** | Headers, lists, tables, code blocks, blockquotes, links, images |
| **Math & Charts** | LaTeX formulas, Mermaid diagrams (flowcharts, Gantt, pie, sequence) |
| **Extras** | Footnotes, SVG support, collapsible sections, task lists |
| **Theming** | Light/dark modes, GitHub/VS Code presets, custom themes |
| **Plugins** | Mentions, hashtags, emojis, AI chat blocks (thinking, artifacts) |

## Demo

<table>
<tr>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/main.jpg" width="280" alt="Main Interface"></td>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/code.jpg" width="280" alt="Code Blocks"></td>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/latx.jpg" width="280" alt="LaTeX Math"></td>
</tr>
<tr>
<td align="center">Main Interface</td>
<td align="center">Code Blocks</td>
<td align="center">LaTeX Math</td>
</tr>
</table>

<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/streaming.gif" width="600" alt="Real-time Streaming">

> Run the example app: `cd example && flutter run`

## Quick Start

### Installation

```yaml
dependencies:
  flutter_smooth_markdown: ^0.5.2
```

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

SmoothMarkdown(
  data: '# Hello Markdown\n\nThis is **bold** and *italic*.',
  styleSheet: MarkdownStyleSheet.light(),
  onTapLink: (url) => print('Tapped: $url'),
)
```

### Streaming (Real-time)

```dart
StreamMarkdown(
  stream: yourMarkdownStream,
  styleSheet: MarkdownStyleSheet.dark(),
)
```

### Enhanced Components

```dart
final renderer = MarkdownRenderer(styleSheet: MarkdownStyleSheet.light());

renderer.builderRegistry
  ..register('code_block', const EnhancedCodeBlockBuilder())
  ..register('blockquote', const EnhancedBlockquoteBuilder())
  ..register('link', const EnhancedLinkBuilder())
  ..register('header', const EnhancedHeaderBuilder());

final nodes = MarkdownParser().parse(markdownText);
final widget = renderer.render(nodes);
```

## Theming

```dart
// Built-in themes
MarkdownStyleSheet.light()
MarkdownStyleSheet.dark()
MarkdownStyleSheet.github(brightness: Brightness.light)
MarkdownStyleSheet.vscode(brightness: Brightness.dark)

// From Flutter theme
MarkdownStyleSheet.fromTheme(Theme.of(context))

// Custom
MarkdownStyleSheet.light().copyWith(
  h1Style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  linkStyle: TextStyle(color: Colors.blue),
)
```

## Plugins

```dart
// Custom syntax plugins
final registry = ParserPluginRegistry();
registry.register(const MentionPlugin());    // @username
registry.register(const HashtagPlugin());    // #topic
registry.register(const EmojiPlugin());      // :smile:

final parser = MarkdownParser(plugins: registry);
```

### AI Chat Plugins

```dart
registry.register(const ThinkingPlugin());   // <thinking>...</thinking>
registry.register(const ArtifactPlugin());   // <artifact>...</artifact>
registry.register(const ToolCallPlugin());   // <tool_use>...</tool_use>
```

## Mermaid Diagrams

```dart
MermaidDiagram(
  code: '''
  graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action]
    B -->|No| D[End]
  ''',
  style: MermaidStyle.dark(),
)
```

Supports: Flowcharts, Sequence Diagrams, Pie Charts, Gantt Charts, Timeline Diagrams

## Markdown Syntax

<details>
<summary>Text Formatting</summary>

```markdown
**Bold** or __Bold__
*Italic* or _Italic_
~~Strikethrough~~
`Inline code`
```
</details>

<details>
<summary>Lists & Tasks</summary>

```markdown
- Unordered item
1. Ordered item
- [ ] Task
- [x] Completed task
```
</details>

<details>
<summary>Code Blocks</summary>

````markdown
```dart
void main() {
  print('Hello, World!');
}
```
````
</details>

<details>
<summary>Tables</summary>

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```
</details>

<details>
<summary>Math (LaTeX)</summary>

```markdown
Inline: $E = mc^2$

Block:
$$
\int_{a}^{b} f(x) dx = F(b) - F(a)
$$
```
</details>

<details>
<summary>Footnotes</summary>

```markdown
Text with footnote[^1].

[^1]: Footnote content.
```
</details>

<details>
<summary>Collapsible Sections</summary>

```markdown
<details>
<summary>Click to expand</summary>
Hidden content here.
</details>
```
</details>

## Use Cases

- Documentation apps with code examples
- Chat applications with rich text
- Note-taking apps
- Educational platforms with LaTeX
- AI chat interfaces with streaming

## Documentation

| Document | Description |
|----------|-------------|
| [Plugin System](doc/插件系统.md) | Custom parser plugins |
| [Theme System](doc/主题系统.md) | Theming guide |
| [Enhanced Components](doc/使用增强组件.md) | Rich UI components |
| [Architecture](doc/架构设计.md) | System architecture |

## Roadmap

**Completed**: Core parser, renderer, themes, streaming, math, tables, footnotes, SVG, plugins, Mermaid diagrams, AI chat plugins, i18n (6 languages)

**In Progress**: Performance optimization, API documentation

**Planned**: More themes, advanced tables, accessibility

## Contributing

Contributions welcome! Please read our guidelines before submitting PRs.

## License

MIT License

## Links

- [GitHub](https://github.com/JackCaow/flutter-smooth-markdown)
- [Issues](https://github.com/JackCaow/flutter-smooth-markdown/issues)
- [pub.dev](https://pub.dev/packages/flutter_smooth_markdown)

---

Made with love for the Flutter community.
