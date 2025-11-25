import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// 插件系统演示页面
///
/// 展示 @提及、#标签、:emoji: 和警告框等自定义语法
class PluginDemo extends StatefulWidget {
  const PluginDemo({
    super.key,
    required this.styleSheet,
  });

  final MarkdownStyleSheet styleSheet;

  @override
  State<PluginDemo> createState() => _PluginDemoState();
}

class _PluginDemoState extends State<PluginDemo> {
  late final ParserPluginRegistry _registry;

  @override
  void initState() {
    super.initState();
    _setupPlugins();
  }

  void _setupPlugins() {
    // 创建插件注册表
    _registry = ParserPluginRegistry()
      ..register(const MentionPlugin())
      ..register(const HashtagPlugin())
      ..register(const EmojiPlugin())
      ..register(const AdmonitionPlugin());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.styleSheet.textStyle?.color?.computeLuminance() != null &&
        widget.styleSheet.textStyle!.color!.computeLuminance() > 0.5;

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF161B22) : null,
          foregroundColor: isDark ? Colors.white : null,
          title: const Text('Plugin System Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                title: '插件系统演示',
                description: '展示 Flutter Smooth Markdown 的插件系统功能',
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              _buildPluginDemo(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildPluginDemo(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          // Markdown 内容展示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: SmoothMarkdown(
              data: _demoMarkdown,
              styleSheet: widget.styleSheet,
              plugins: _registry,
              builderRegistry: _createCustomBuilders(context, isDark),
            ),
          ),
          // 分隔线
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF30363D) : Colors.grey[300],
          ),
          // 原始 Markdown 源码
          ExpansionTile(
            title: Text(
              '查看 Markdown 源码',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            iconColor: isDark ? Colors.white70 : null,
            collapsedIconColor: isDark ? Colors.white70 : null,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: isDark ? const Color(0xFF0D1117) : Colors.grey[100],
                child: SelectableText(
                  _demoMarkdown,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BuilderRegistry _createCustomBuilders(BuildContext context, bool isDark) {
    return BuilderRegistry()
      ..register('mention', MentionBuilder(
        onTap: (username) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('点击了用户: @$username'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ))
      ..register('hashtag', HashtagBuilder(
        onTap: (tag) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('点击了标签: #$tag'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ))
      ..register('emoji', const EmojiBuilder())
      ..register('admonition', AdmonitionBuilder(isDark: isDark));
  }

  static const String _demoMarkdown = '''
# 插件系统功能展示

欢迎体验 **Flutter Smooth Markdown** 的插件系统！

## @提及功能

你可以在文本中 @john 和 @jane_doe 来提及用户。试试点击它们！

支持的用户名格式：
- @alice - 简单用户名
- @bob123 - 带数字
- @charlie_smith - 带下划线
- @david-test - 带连字符

## #标签功能

使用 #flutter 和 #dart 标签来分类内容。

热门标签：
- #programming
- #mobile_dev
- #open_source

## :emoji: 表情

使用表情让内容更生动！

常用表情：
- :smile: :wave: :heart: - 基础表情
- :thumbsup: :clap: :fire: - 手势和符号
- :rocket: :star: :sparkles: - 特效
- :coffee: :pizza: :cake: - 食物

组合使用：Hello :wave: 你好 :smile:

## 警告框 (Admonition)

::: note 备注
这是一个备注框，用于显示一般信息。
:::

::: tip 小技巧
插件系统让你可以轻松扩展 Markdown 语法！
:::

::: warning 注意
警告框可以帮助用户注意重要信息。
:::

::: danger 危险
这是一个危险警告，用于强调关键风险。
:::

::: important 重要
重要信息应该使用这个类型的警告框。
:::

## 组合使用

你可以在同一段落中组合使用这些功能：

Hey @flutter_dev :wave: 看看这个 #awesome 项目！它真的很 :fire:

---

**提示**: 所有这些功能都是通过插件系统实现的，你也可以创建自己的插件！
''';
}

/// 提及节点的自定义 Builder
class MentionBuilder extends MarkdownWidgetBuilder {
  const MentionBuilder({this.onTap});

  final void Function(String username)? onTap;

  @override
  bool canBuild(MarkdownNode node) => node is MentionNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final mentionNode = node as MentionNode;
    return _MentionWidget(username: mentionNode.username, onTap: onTap);
  }
}

class _MentionWidget extends StatefulWidget {
  const _MentionWidget({required this.username, this.onTap});

  final String username;
  final void Function(String username)? onTap;

  @override
  State<_MentionWidget> createState() => _MentionWidgetState();
}

class _MentionWidgetState extends State<_MentionWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.username),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '@${widget.username}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 标签节点的自定义 Builder
class HashtagBuilder extends MarkdownWidgetBuilder {
  const HashtagBuilder({this.onTap});

  final void Function(String tag)? onTap;

  @override
  bool canBuild(MarkdownNode node) => node is HashtagNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final hashtagNode = node as HashtagNode;
    return _HashtagWidget(tag: hashtagNode.tag, onTap: onTap);
  }
}

class _HashtagWidget extends StatefulWidget {
  const _HashtagWidget({required this.tag, this.onTap});

  final String tag;
  final void Function(String tag)? onTap;

  @override
  State<_HashtagWidget> createState() => _HashtagWidgetState();
}

class _HashtagWidgetState extends State<_HashtagWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.tag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.purple.withValues(alpha: 0.2)
                : Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#${widget.tag}',
            style: TextStyle(
              color: Colors.purple[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Emoji 节点的自定义 Builder
class EmojiBuilder extends MarkdownWidgetBuilder {
  const EmojiBuilder();

  @override
  bool canBuild(MarkdownNode node) => node is EmojiNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final emojiNode = node as EmojiNode;
    return Tooltip(
      message: ':${emojiNode.shortcode}:',
      child: Text(emojiNode.emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

/// Admonition 节点的自定义 Builder
class AdmonitionBuilder extends MarkdownWidgetBuilder {
  const AdmonitionBuilder({this.isDark = false});

  final bool isDark;

  @override
  bool canBuild(MarkdownNode node) => node is AdmonitionNode;

  @override
  Widget build(
    MarkdownNode node,
    MarkdownStyleSheet styleSheet,
    MarkdownRenderContext context,
  ) {
    final admonitionNode = node as AdmonitionNode;
    final (icon, color, defaultTitle) = _getAdmonitionStyle(admonitionNode.admonitionType);
    final displayTitle = admonitionNode.title.isNotEmpty ? admonitionNode.title : defaultTitle;

    // 获取内容文本
    final contentText = StringBuffer();
    for (final child in admonitionNode.children) {
      if (child is ParagraphNode) {
        for (final c in child.children) {
          if (c is TextNode) {
            contentText.write(c.content);
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              contentText.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _getAdmonitionStyle(AdmonitionType type) {
    switch (type) {
      case AdmonitionType.note:
        return (Icons.info_outline, Colors.blue, 'Note');
      case AdmonitionType.tip:
        return (Icons.lightbulb_outline, Colors.green, 'Tip');
      case AdmonitionType.warning:
        return (Icons.warning_amber, Colors.orange, 'Warning');
      case AdmonitionType.danger:
        return (Icons.dangerous, Colors.red, 'Danger');
      case AdmonitionType.important:
        return (Icons.priority_high, Colors.purple, 'Important');
      case AdmonitionType.custom:
        return (Icons.article, Colors.grey, 'Note');
    }
  }
}
