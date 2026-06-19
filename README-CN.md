# Flutter Smooth Markdown

[![pub package](https://img.shields.io/pub/v/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown)
[![popularity](https://img.shields.io/pub/popularity/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)
[![likes](https://img.shields.io/pub/likes/flutter_smooth_markdown.svg)](https://pub.dev/packages/flutter_smooth_markdown/score)
[![GitHub stars](https://img.shields.io/github/stars/JackCaow/flutter-smooth-markdown?style=flat&logo=github)](https://github.com/JackCaow/flutter-smooth-markdown/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/JackCaow/flutter-smooth-markdown?style=flat&logo=github)](https://github.com/JackCaow/flutter-smooth-markdown/network/members)
[![GitHub issues](https://img.shields.io/github/issues/JackCaow/flutter-smooth-markdown)](https://github.com/JackCaow/flutter-smooth-markdown/issues)
[![GitHub license](https://img.shields.io/github/license/JackCaow/flutter-smooth-markdown)](https://github.com/JackCaow/flutter-smooth-markdown/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart)](https://dart.dev)

高性能 Flutter Markdown 渲染器，支持语法高亮、LaTeX 数学公式、表格、脚注、SVG 图片、Mermaid 图表和实时流式渲染。

**简体中文** | [English](README.md)

---

## 功能特性

| 类别 | 功能 |
|----------|----------|
| **渲染** | 基于 AST 的解析引擎、语法高亮、实时流式渲染、文本选择 |
| **Markdown** | 标题（支持内联格式）、列表、表格、代码块、引用块、链接、图片 |
| **数学与图表** | LaTeX 公式、Mermaid 图表（流程图、甘特图、看板、时间线、雷达图、XY 图表、饼图、序列图） |
| **扩展功能** | 脚注、SVG 支持、折叠区块、任务列表 |
| **主题** | 亮色/暗色模式、GitHub/VS Code 预设、自定义主题 |
| **插件** | @提及、#话题标签、:emoji: 表情、AI 对话区块（思考中、产物） |

## 演示

<table>
<tr>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/main.jpg" width="280" alt="主界面"></td>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/code.jpg" width="280" alt="代码块"></td>
<td><img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/latx.jpg" width="280" alt="LaTeX 数学公式"></td>
</tr>
<tr>
<td align="center">主界面</td>
<td align="center">代码高亮</td>
<td align="center">LaTeX 公式</td>
</tr>
</table>

<img src="https://raw.githubusercontent.com/JackCaow/flutter-smooth-markdown/main/screenshots/streaming.gif" width="600" alt="实时流式渲染">

> 运行示例应用：`cd example && flutter run`

---

## 快速开始

### 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_smooth_markdown: ^0.7.4
```

```bash
flutter pub get
```

### 基本用法

```dart
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

SmoothMarkdown(
  data: '# Hello Markdown\n\n这是 **粗体** 和 *斜体*。',
  styleSheet: MarkdownStyleSheet.light(),
  onTapLink: (url) => print('点击了链接: $url'),
)
```

### 可选中文本

```dart
SmoothMarkdown(
  data: markdownText,
  selectable: true,
  onTapImage: (url, alt, title) {
    showImagePreview(context, url);
  },
)
```

选择手柄支持跨文本和非文本块（如图片、表格）操作。复制的内容会自动清理格式。

### 程序化选择

当 `selectable: true` 时，内容会被包装在一个 `SmoothSelectionRegion`（一个轻量的 `SelectableRegion` 适配器）中。通过传递 `selectionController` 来程序化驱动选择：

```dart
final controller = SmoothSelectionController();

SmoothMarkdown(
  data: markdownText,
  selectable: true,
  selectionController: controller,
)

// 进入选择模式（显示手柄和工具栏）：
controller.selectAll(SelectionChangedCause.toolbar);

// 或选中某个位置附近的段落：
controller.selectParagraphAt(details.globalPosition);
```

选择策略由你的应用代码决定。例如，聊天气泡菜单可以选择段落选择，而编辑器工具栏则可以选择全选：

```dart
void handleSelectText(Offset pressPosition) {
  switch (selectionMode) {
    case SelectionMode.word:
      controller.selectWordAt(pressPosition);
      return;
    case SelectionMode.paragraph:
      controller.selectParagraphAt(pressPosition);
      return;
    case SelectionMode.message:
      controller.selectAll(SelectionChangedCause.toolbar);
      return;
  }
}
```

更底层的控制接口：

```dart
// 清除当前选择（隐藏手柄和工具栏）：
controller.clearSelection();

// 发送任意 SelectionEvent 到 SelectionContainer
//（分发给所有文本选区）。不会单独驱动覆盖层。
controller.dispatchEvent(const SelectAllSelectionEvent());

// 获取收集文本选区的 SelectionRegistrar。
final registrar = controller.registrar;
```

`contextMenuBuilder`（如果提供）现在接收一个 `SmoothSelectionRegionState`，让菜单可以访问 `dispatchEvent`、`registrar`、`contextMenuButtonItems` 和 `contextMenuAnchors`。

`selectableRegionKey` 仍然可用于需要直接访问 `SmoothSelectionRegionState` 的高级集成。

> **迁移说明（轻微破坏性）：** `selectableRegionKey` 的类型现为 `GlobalKey<SmoothSelectionRegionState>`（原为 `GlobalKey<SelectableRegionState>`），`contextMenuBuilder` 的第二个参数现为 `SmoothSelectionRegionState`。重命名类型后即可使用新增的方法；现有调用（`selectAll`、`contextMenuButtonItems`、`contextMenuAnchors`）无需修改即可工作。新代码应优先使用 `selectionController`。

### 流式渲染（实时）

```dart
StreamMarkdown(
  stream: yourMarkdownStream,
  styleSheet: MarkdownStyleSheet.dark(),
)
```

### 增强组件

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

---

## 主题

```dart
// 内置主题
MarkdownStyleSheet.light()          // 亮色模式
MarkdownStyleSheet.dark()           // 暗色模式
MarkdownStyleSheet.github(brightness: Brightness.light)   // GitHub 风格
MarkdownStyleSheet.vscode(brightness: Brightness.dark)    // VS Code 风格

// 从 Flutter Theme 创建
MarkdownStyleSheet.fromTheme(Theme.of(context))

// 自定义主题
MarkdownStyleSheet.light().copyWith(
  h1Style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  linkStyle: TextStyle(color: Colors.blue),
)
```

---

## 插件系统

```dart
// 自定义语法插件
final registry = ParserPluginRegistry();
registry.register(const MentionPlugin());    // @用户名
registry.register(const HashtagPlugin());    // #话题
registry.register(const EmojiPlugin());      // :smile:

final parser = MarkdownParser(plugins: registry);
```

### AI 聊天插件

```dart
registry.register(const ThinkingPlugin());   // <thinking>...</thinking>
registry.register(const ArtifactPlugin());   // <artifact>...</artifact>
registry.register(const ToolCallPlugin());   // <tool_use>...</tool_use>
```

---

## Mermaid 图表

```dart
MermaidDiagram(
  code: '''
  graph TD
    A[开始] --> B{判断}
    B -->|是| C[执行]
    B -->|否| D[结束]
  ''',
  style: MermaidStyle.dark(),
)
```

支持的图表类型：流程图、序列图、饼图、甘特图、看板、时间线图、雷达图、**XY 图表**

### XY 图表示例

```dart
MermaidDiagram(
  code: '''
  xychart-beta
    title "销售收入"
    x-axis [Q1, Q2, Q3, Q4]
    y-axis "收入" 0 --> 100
    bar [23, 45, 67, 89]
    line [20, 50, 60, 85]
  ''',
)
```

### 雷达图示例

```dart
MermaidDiagram(
  code: '''
  radar-beta
    title 技能评估
    axis 编程, 设计, 沟通, 管理, 创新
    curve Alice{5, 3, 4, 2, 4}
    curve Bob{3, 5, 3, 4, 3}
    showLegend true
    max 5
    graticule polygon
  ''',
)
```

---

## Markdown 语法

<details>
<summary><b>文本格式</b></summary>

<pre><code>**粗体** 或 __粗体__
*斜体* 或 _斜体_
~~删除线~~
`内联代码`</code></pre>

</details>

<details>
<summary><b>列表与任务</b></summary>

<pre><code>- 无序列表项
1. 有序列表项
- [ ] 未完成任务
- [x] 已完成任务</code></pre>

</details>

<details>
<summary><b>代码块</b></summary>

<pre><code>```dart
void main() {
  print('Hello, World!');
}
```</code></pre>

</details>

<details>
<summary><b>表格</b></summary>

<pre><code>| 表头 1 | 表头 2 |
|--------|--------|
| 单元格 1 | 单元格 2 |</code></pre>

</details>

<details>
<summary><b>数学公式（LaTeX）</b></summary>

<pre><code>行内公式：$E = mc^2$

块级公式：
$$
\int_{a}^{b} f(x) \, dx = F(b) - F(a)
$$</code></pre>

</details>

<details>
<summary><b>脚注</b></summary>

<pre><code>带脚注的文本[^1]。

[^1]: 脚注内容。</code></pre>

</details>

<details>
<summary><b>折叠区块</b></summary>

<pre><code>&lt;details&gt;
&lt;summary&gt;点击展开&lt;/summary&gt;
隐藏内容在这里。
&lt;/details&gt;</code></pre>

</details>

---

## 应用场景

- 文档类应用（含代码示例）
- 聊天应用（富文本消息）
- 笔记应用
- 教育平台（LaTeX 数学公式）
- AI 聊天界面（流式输出）

---

## 文档

| 文档 | 说明 |
|----------|-------------|
| [插件系统](doc/插件系统.md) | 自定义解析器插件 |
| [主题系统](doc/主题系统.md) | 主题配置指南 |
| [增强组件](doc/使用增强组件.md) | 丰富的 UI 组件 |
| [架构设计](doc/架构设计.md) | 系统架构说明 |

---

## 路线图

**已完成**：核心解析器、渲染器、主题、流式渲染、数学公式、表格、脚注、SVG、插件、Mermaid 图表、AI 聊天插件、国际化（6 种语言）

**进行中**：性能优化、API 文档完善

**计划中**：更多主题预设、高级表格功能、无障碍支持

---

## 贡献指南

欢迎贡献！请阅读我们的[贡献指南](CONTRIBUTING.md)后再提交 PR。

---

## 许可证

MIT License

---

## 链接

- [GitHub 仓库](https://github.com/JackCaow/flutter-smooth-markdown)
- [问题反馈](https://github.com/JackCaow/flutter-smooth-markdown/issues)
- [pub.dev 包页面](https://pub.dev/packages/flutter_smooth_markdown)

---

用 ❤️ 为 Flutter 社区打造
