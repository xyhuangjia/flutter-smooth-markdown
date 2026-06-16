import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

// ─── Shared widget builders ───

Widget _buildAvatar(Conversation conv, bool isDark, {double size = 52}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [conv.avatarColor, conv.avatarColor.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size / 2),
    ),
    alignment: Alignment.center,
    child: Text(
      conv.avatar,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ─── Shared context menu ───

class _MenuAction {
  const _MenuAction({
    this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final void Function(BuildContext dialogContext) onTap;
}

/// Show a positioned context menu near the finger, with fade+scale animation.
void _showMessageContextMenu({
  required BuildContext context,
  required bool isDark,
  required Offset longPressPosition,
  required String content,
  List<_MenuAction> extraActions = const [],
  VoidCallback? onSelectText,
}) {
  HapticFeedback.mediumImpact();

  final screenSize = MediaQuery.of(context).size;
  // Determine menu width based on number of items
  final totalActions = 2 + extraActions.length; // 复制 + 选择文字 + extras
  const itemWidth = 64.0;
  final menuWidth = (totalActions * itemWidth + 24).clamp(220.0, 360.0);
  const menuHeight = 110.0;

  double left = longPressPosition.dx - menuWidth / 2;
  if (left < 12) left = 12;
  if (left + menuWidth > screenSize.width - 12) {
    left = screenSize.width - menuWidth - 12;
  }

  double top = longPressPosition.dy - menuHeight - 28;
  if (top < kToolbarHeight + 8) {
    top = longPressPosition.dy + 28;
  }

  final iconColor = isDark ? Colors.white70 : const Color(0xFF1A3352);
  final textColor = isDark ? Colors.white70 : const Color(0xFF1A3352);
  final bgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.08),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                  alignment: Alignment.center,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: menuWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMenuActionWidget(
                            dialogContext,
                            Icons.content_copy_outlined,
                            '复制',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: content));
                              Navigator.pop(dialogContext);
                              _showSnack(context, '已复制');
                            },
                          ),
                          _buildMenuActionWidget(
                            dialogContext,
                            null,
                            '选择文字',
                            isSelectText: true,
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              Navigator.pop(dialogContext);
                              // Timing (dismiss-then-summon) is handled by a
                              // single post-frame in the caller's
                              // onSelectText; no extra frames needed here.
                              onSelectText?.call();
                            },
                          ),
                          ...extraActions.map((a) => _buildMenuActionWidget(
                                dialogContext,
                                a.icon,
                                a.label,
                                iconColor: iconColor,
                                textColor: textColor,
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  a.onTap(dialogContext);
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuActionWidget(
  BuildContext dialogContext,
  IconData? icon,
  String label, {
  bool isSelectText = false,
  Color? iconColor,
  Color? textColor,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap ?? () => Navigator.pop(dialogContext),
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: isSelectText
                ? _buildSelectTextIcon(iconColor ?? const Color(0xFF1A3352))
                : Icon(icon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: (textColor ?? const Color(0xFF1A3352)).withOpacity(0.75),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSelectTextIcon(Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        'T',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: color,
          height: 1,
        ),
      ),
      const SizedBox(width: 4),
      Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    ],
  );
}

void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
  );
}

/// Conversation List Demo
///
/// A simple conversation list showcasing:
/// - Long-press context menu on conversation items
/// - Copy text from last message
/// - Text selection on rendered markdown content
/// - Dark/light theme switching
class ConversationListDemo extends StatefulWidget {
  const ConversationListDemo({super.key});

  @override
  State<ConversationListDemo> createState() => _ConversationListDemoState();
}

class _ConversationListDemoState extends State<ConversationListDemo> {
  final List<Conversation> _conversations = _sampleConversations;
  final ScrollController _scrollController = ScrollController();
  bool _isDarkMode = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '会话列表',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              tooltip: '切换主题',
            ),
          ],
        ),
        body: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final conv = _conversations[index];
            return _ConversationListTile(
              key: ValueKey(conv.id),
              conversation: conv,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ConversationDetailPage(
                      conversation: conv,
                      isDark: _isDarkMode,
                    ),
                  ),
                );
              },
              // onLongPressStart: (details) =>
              //     _showContextMenu(context, conv, details.globalPosition),
            );
          },
        ),
      ),
    );
  }

  // ─── Static sample data ───

  static final List<Conversation> _sampleConversations = [
    _makeConv(
      id: '1',
      name: 'Flutter Dev Team',
      avatar: 'F',
      avatarColor: const Color(0xFF0553B1),
      unreadCount: 5,
      lastMsg: '@alice `SmoothMarkdown` 缓存策略更新了吗？性能提升了 **32倍** 🚀',
      msgs: [
        ChatMsg(
            content: '@alice `SmoothMarkdown` 缓存策略更新了吗？性能提升了 **32倍** 🚀',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
        ChatMsg(
            content:
                '更新了！现在使用 **LRU 缓存**，命中率达到 99.5%。\n\n```dart\nfinal cache = ParseCache(maxSize: 500);\nfinal result = cache.getOrParse(markdown);\n```',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1))),
      ],
    ),
    _makeConv(
      id: '2',
      name: 'Alice Chen',
      avatar: 'A',
      avatarColor: const Color(0xFFE91E63),
      unreadCount: 2,
      lastMsg: '已经提交了 PR，包含了新的 streaming 功能和完整测试',
      msgs: [
        ChatMsg(
            content:
                'Hey! 新的 **streaming** 功能 PR 已经提交了 ✅\n\n包含了：\n- ✅ 流式 Markdown 解析\n- ✅ 增量渲染\n- ✅ 性能优化\n\n帮我 review 一下？',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
        ChatMsg(
            content:
                '好的，我来看看。\n\n几个建议：\n1. 流式解析时注意内存管理\n2. 增量渲染要用 `RepaintBoundary`\n3. 加一些边界情况的测试',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 20))),
        ChatMsg(
            content:
                '已经提交了 PR，包含了新的 **streaming** 功能和完整的测试覆盖。\n\n```dart\n// 新增的 API\nStreamMarkdown(\n  stream: responseStream,\n  plugins: aiPlugins,\n)\n```',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
      ],
    ),
    _makeConv(
      id: '3',
      name: 'Bob Wang',
      avatar: 'B',
      avatarColor: const Color(0xFF4CAF50),
      lastMsg: '对比了几个方案的数据，看看这个表格',
      msgs: [
        ChatMsg(
            content:
                '对比了几个方案的数据，你帮我看看选哪个？\n\n| 方案 | 性能 | 内存 | 包大小 |\n|------|:----:|:----:|:------:|\n| A | ⭐⭐⭐⭐⭐ | 低 | 小 |\n| B | ⭐⭐⭐ | 中 | 中 |\n| C | ⭐⭐⭐⭐ | 低 | 大 |',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 2))),
        ChatMsg(
            content:
                '方案 A 看起来最好！\n\n性能和内存都是最优的，包大小也是最小的。\n\n不过我建议再看一下 **长期维护成本**。',
            isMe: true,
            timestamp:
                DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
        ChatMsg(
            content:
                '有道理，我再调研一下各个方案的社区活跃度和更新频率。\n\n> "选型不只是看当下，更要看未来。"\n\n谢谢你的建议！👍',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 1))),
      ],
    ),
    _makeConv(
      id: '4',
      name: 'Open Source Community',
      avatar: 'O',
      avatarColor: const Color(0xFFFF9800),
      unreadCount: 99,
      lastMsg: '新版本发布啦！🎉 Markdown 渲染性能提升 32x',
      msgs: [
        ChatMsg(
            content:
                '# 🎉 v0.8.0 发布通知\n\n各位社区成员，新版本发布啦！\n\n## 主要更新\n- ✅ Markdown 渲染性能提升 **32x**\n- ✅ 新增 Mermaid 图表支持\n- ✅ 流式渲染优化\n- ✅ 插件系统重构\n\n大家快来试试！',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 3))),
        ChatMsg(
            content: '太棒了！已经升级了，性能提升非常明显 👍',
            isMe: true,
            timestamp:
                DateTime.now().subtract(const Duration(hours: 2, minutes: 50))),
        ChatMsg(
            content:
                'Mermaid 图表功能特别好用，给你们看一个效果：\n\n```mermaid\ngraph LR\n    A[Markdown] --> B[Parser]\n    B --> C[AST]\n    C --> D[Renderer]\n    D --> E[Widget]\n```',
            isMe: true,
            timestamp:
                DateTime.now().subtract(const Duration(hours: 2, minutes: 45))),
      ],
    ),
    _makeConv(
      id: '5',
      name: 'Design Team',
      avatar: 'D',
      avatarColor: const Color(0xFF9C27B0),
      lastMsg: '新的设计稿 📐 暗色主题 + 8dp 网格系统',
      msgs: [
        ChatMsg(
            content:
                '新的设计稿 📐\n\n主要改动：\n1. **颜色系统** - 增加了暗色主题支持\n2. **间距规范** - 统一了 8dp 网格系统\n3. **字体层级** - 新增了 `monospace` 选项',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 6))),
        ChatMsg(
            content: '暗色主题看起来很好！\n\n不过间距能不能用 4dp 的倍数？这样更灵活一些。',
            isMe: true,
            timestamp:
                DateTime.now().subtract(const Duration(hours: 5, minutes: 30))),
        ChatMsg(
            content:
                '好的，我们改成 4dp 基础单位。\n\n<details>\n<summary>更新后的字体层级</summary>\n\n- H1: 28sp, Bold\n- H2: 24sp, SemiBold\n- H3: 20sp, Medium\n- Body: 16sp, Regular\n- Caption: 12sp, Regular\n\n</details>',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 5))),
      ],
    ),
    _makeConv(
      id: '6',
      name: 'Charlie Li',
      avatar: 'C',
      avatarColor: const Color(0xFF00BCD4),
      unreadCount: 3,
      lastMsg: 'Euler formula: e^{iπ} + 1 = 0 渲染完美！',
      msgs: [
        ChatMsg(
            content:
                '看看这个数学公式渲染效果：\n\nEuler\'s formula: \$e^{i\\pi} + 1 = 0\$\n\n还有矩阵：\n\n\$\$\n\\\\begin{bmatrix}\na & b \\\\\\\\\nc & d\n\\\\end{bmatrix}\n\$\$',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 1))),
        ChatMsg(
            content: '渲染效果完美！✨\n\nMatrix 也显示正确，LaTeX 支持很到位。',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 1))),
      ],
    ),
    _makeConv(
      id: '7',
      name: 'Diana Park',
      avatar: 'D',
      avatarColor: const Color(0xFF795548),
      lastMsg: 'Mermaid 图表功能太棒了！',
      msgs: [
        ChatMsg(
            content:
                '你看了新的 Mermaid 图表功能吗？\n\n```mermaid\ngraph TD\n    A[请求] --> B{鉴权}\n    B -->|通过| C[处理]\n    B -->|拒绝| D[返回401]\n```\n\n太棒了！',
            isMe: false,
            timestamp:
                DateTime.now().subtract(const Duration(days: 1, hours: 5))),
        ChatMsg(
            content:
                '看到了！确实很强大。\n\n而且支持多种图表类型：\n- ✅ Flowchart\n- ✅ Sequence Diagram\n- ✅ Pie Chart\n- ✅ Gantt Chart',
            isMe: true,
            timestamp:
                DateTime.now().subtract(const Duration(days: 1, hours: 4))),
      ],
    ),
    _makeConv(
      id: '8',
      name: 'Evan Zhou',
      avatar: 'E',
      avatarColor: const Color(0xFF3F51B5),
      unreadCount: 1,
      lastMsg: 'Bug report: iOS 17.5 上 StreamMarkdown 偶现闪烁',
      msgs: [
        ChatMsg(
            content:
                'Bug report: iOS 17.5 上 `StreamMarkdown` 偶现闪烁。\n\n**复现步骤：**\n1. 快速连续发送多条消息\n2. 滚动到顶部再回来\n3. 观察到短暂的白屏闪烁',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 2))),
        ChatMsg(
            content: '收到，我来排查一下。\n\n你方便提供一下设备型号和 Flutter 版本吗？',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 2))),
      ],
    ),
    _makeConv(
      id: '9',
      name: 'Team Announcements',
      avatar: '📢',
      avatarColor: const Color(0xFFF44336),
      lastMsg: '📢 本周五 Sprint Review，下午3点',
      msgs: [
        ChatMsg(
            content:
                '# 📢 团队通知\n\n本周五下午 3 点举行 **Sprint Review**。\n\n**议程：**\n1. 上周工作总结\n2. Q2 目标回顾\n3. 技术分享：Flutter 性能优化\n4. Q&A\n\n请大家准时参加！🎯',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 3))),
        ChatMsg(
            content: '收到！我会准备性能优化的分享内容。',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 3))),
      ],
    ),
    _makeConv(
      id: '10',
      name: 'Fiona Wu',
      avatar: 'F',
      avatarColor: const Color(0xFF009688),
      lastMsg: '按照你的建议改了缓存策略，效果非常好！',
      msgs: [
        ChatMsg(
            content:
                '谢谢你之前的帮助！🙏\n\n按照你的建议，我改了缓存策略以后：\n- 首屏渲染从 **3.6ms** 降到 **0.11ms**\n- 滚动帧率稳定在 **60fps**\n- 内存占用减少 **30%**',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 5))),
        ChatMsg(
            content: '不客气！缓存策略确实是性能优化的关键。\n\n你用的什么缓存算法？LRU 还是 LFU？',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 5))),
        ChatMsg(
            content: '用的 **LRU**，maxSize 设了 500。\n\n经过压测，命中率稳定在 99% 以上。',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 5))),
      ],
    ),
    _makeConv(
      id: '11',
      name: 'George Liu',
      avatar: 'G',
      avatarColor: const Color(0xFFE64A19),
      lastMsg: '新项目用 Flutter 还是 React Native？',
      msgs: [
        ChatMsg(
            content:
                '新项目在技术选型，在纠结用 **Flutter** 还是 **React Native**。\n\n你有什么建议？',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 7))),
        ChatMsg(
            content:
                '看你们团队背景：\n\n| 条件 | Flutter | React Native |\n|------|:-------:|:------------:|\n| 团队有 Dart 经验 | ✅ | - |\n| 团队有 React 经验 | - | ✅ |\n| 需要复杂动画 | ✅ | ⚠️ |\n| 需要 Web 端 | ⚠️ | ✅ |\n\n如果主要做移动端且追求性能，我推荐 Flutter。',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 7))),
      ],
    ),
    _makeConv(
      id: '12',
      name: 'Helen Yang',
      avatar: 'H',
      avatarColor: const Color(0xFF7B1FA2),
      lastMsg: '有没有好的 Markdown 编辑器推荐？',
      msgs: [
        ChatMsg(
            content:
                '有没有好的 Markdown 编辑器推荐？\n\n需要支持：\n- [x] 实时预览\n- [x] 语法高亮\n- [x] 暗色主题\n- [ ] 导出 PDF',
            isMe: false,
            timestamp: DateTime.now().subtract(const Duration(days: 10))),
        ChatMsg(
            content:
                '推荐几个：\n\n1. **VS Code** - 免费 + 强大的插件生态\n2. **Typora** - 所见即所得的体验\n3. **Obsidian** - 笔记 + 知识图谱\n\n如果是 Flutter 内嵌的话，可以直接用 `SmoothMarkdown` 自己搭一个！',
            isMe: true,
            timestamp: DateTime.now().subtract(const Duration(days: 10))),
      ],
    ),
  ];

  static Conversation _makeConv({
    required String id,
    required String name,
    required String avatar,
    required Color avatarColor,
    required String lastMsg,
    required List<ChatMsg> msgs,
    int unreadCount = 0,
  }) {
    return Conversation(
      id: id,
      name: name,
      avatar: avatar,
      avatarColor: avatarColor,
      lastMessage: lastMsg,
      timestamp: msgs.last.timestamp,
      messages: msgs,
      unreadCount: unreadCount,
    );
  }
}

// ─── Conversation List Tile ───

class _ConversationListTile extends StatelessWidget {
  const _ConversationListTile({
    required this.conversation,
    required this.isDark,
    required this.onTap,
    // required this.onLongPressStart,
    super.key,
  });

  final Conversation conversation;
  final bool isDark;
  final VoidCallback onTap;
  // final void Function(LongPressStartDetails) onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final conv = conversation;

    return GestureDetector(
      onTap: onTap,
      // onLongPressStart: onLongPressStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                  : Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(conv, isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conv.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: conv.unreadCount > 0
                              ? const Color(0xFF007AFF)
                              : (isDark ? Colors.grey[500] : Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _stripMarkdownForPreview(conv.lastMessage),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (conv.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: conv.unreadCount > 99 ? 6 : 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conv.unreadCount > 99
                                ? '99+'
                                : '${conv.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}/${time.day}';
  }

  String _stripMarkdownForPreview(String md) {
    return md
        .replaceAll(RegExp(r'```[\s\S]*?```'), '[代码]')
        .replaceAll(RegExp(r'`[^`]+`'), '')
        .replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), '[公式]')
        .replaceAll(RegExp(r'\$[^$]+\$'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\!\[.*?\]\(.*?\)'), '[图片]')
        .replaceAll(RegExp(r'\[([^\]]*)\]\(.*?\)'), r'$1')
        .replaceAll(RegExp(r'[#*>|\\-]'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }
}

// ─── Conversation Detail Page ───

/// A chat-style detail page showing all messages with text selection enabled.
class _ConversationDetailPage extends StatelessWidget {
  _ConversationDetailPage({
    required this.conversation,
    required this.isDark,
  });

  final Conversation conversation;
  final bool isDark;

  /// Per-message keys for accessing [SmoothSelectionRegionState] to
  /// programmatically trigger text selection.
  final Map<int, GlobalKey<SmoothSelectionRegionState>> _selectionKeys = {};

  GlobalKey<SmoothSelectionRegionState> _getKey(int index) => _selectionKeys
      .putIfAbsent(index, () => GlobalKey<SmoothSelectionRegionState>());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              _buildAvatar(conversation, isDark, size: 32),
              const SizedBox(width: 10),
              Text(
                conversation.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: '复制全部文本',
              onPressed: () {
                final allText = conversation.messages
                    .map((m) => m.content)
                    .join('\n\n---\n\n');
                Clipboard.setData(ClipboardData(text: allText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: conversation.messages.length,
          itemBuilder: (context, index) {
            final msg = conversation.messages[index];
            return _buildBubble(context, msg, isDark, index);
          },
        ),
      ),
    );
  }

  /// Triggers selection of all text within the [SmoothSelectionRegion].
  ///
  /// Uses `SelectionChangedCause.toolbar` so the framework shows both the
  /// selection handles and the context toolbar (other causes only update the
  /// selection without summoning the toolbar). This replaces the old
  /// double-post-frame + context-menu-button workaround, which was a no-op when
  /// there was no prior selection (the built-in selectAll button only exists
  /// once a selection has started).
  void _triggerSelectAll(SmoothSelectionRegionState state) {
    state.selectAll(SelectionChangedCause.toolbar);
  }

  Widget _buildBubble(
      BuildContext context, ChatMsg msg, bool isDark, int index) {
    final selectableKey = _getKey(index);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            _buildAvatar(conversation, isDark, size: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: RawGestureDetector(
              // Use a dedicated LongPressGestureRecognizer with a deadline
              // shorter than SelectableRegion's default 500ms so the OUTER
              // long-press wins the gesture arena and opens the custom menu,
              // instead of the inner SelectableRegion starting native word
              // selection. Tap/drag recognizers of SelectableRegion are
              // unaffected, so link taps etc. still work.
              behavior: HitTestBehavior.opaque,
              gestures: <Type, GestureRecognizerFactory>{
                LongPressGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer(
                    duration: const Duration(milliseconds: 350),
                  ),
                  (LongPressGestureRecognizer instance) {
                    instance.onLongPressStart = (details) {
                      _showMessageContextMenu(
                        context: context,
                        isDark: isDark,
                        longPressPosition: details.globalPosition,
                        content: msg.content,
                        onSelectText: () {
                          // Defer one frame so the long-press menu overlay can
                          // dismiss before we summon the selection overlay.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final state = selectableKey.currentState;
                            if (state != null) {
                              // Select the paragraph under the press point
                              // (not the whole message) — mirrors a native
                              // long-press "select text" action.
                              state.selectParagraphAt(details.globalPosition);
                            }
                          });
                        },
                      );
                    };
                  },
                ),
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? (isDark
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFF007AFF))
                      : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmoothMarkdown(
                      data: msg.content,
                      enableCache: true,
                      useRepaintBoundary: true,
                      useEnhancedComponents: true,
                      selectable: true,
                      selectableRegionKey: selectableKey,
                      contextMenuBuilder: (context, selectableRegionState) {
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: selectableRegionState.contextMenuAnchors,
                          buttonItems: [
                            // 复制 — copies selected text only (standard behavior)
                            ...selectableRegionState.contextMenuButtonItems
                                .where((item) =>
                                    item.type == ContextMenuButtonType.copy),
                            // 选择文字 — triggers full-text selection with handles
                            ContextMenuButtonItem(
                              label: '选择文字',
                              onPressed: () {
                                _triggerSelectAll(selectableRegionState);
                              },
                            ),
                          ],
                        );
                      },
                      styleSheet: msg.isMe
                          ? MarkdownStyleSheet(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              paragraphStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              h1Style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h2Style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              h3Style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              inlineCodeStyle: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                backgroundColor: Colors.black.withOpacity(0.2),
                                fontFamily: 'monospace',
                              ),
                              codeBlockStyle: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'monospace',
                              ),
                            )
                          : (isDark
                              ? MarkdownStyleSheet.dark()
                              : MarkdownStyleSheet.light()),
                    ),
                    // Timestamp
                    const SizedBox(height: 4),
                    Text(
                      _formatMsgTime(msg.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: msg.isMe
                            ? Colors.white.withOpacity(0.6)
                            : (isDark ? Colors.grey[500] : Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (msg.isMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(conversation, isDark, size: 32),
          ],
        ],
      ),
    );
  }

  String _formatMsgTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Data Models ───

/// A single message within a conversation
class ChatMsg {
  const ChatMsg({
    required this.content,
    required this.isMe,
    required this.timestamp,
  });

  final String content;
  final bool isMe;
  final DateTime timestamp;
}

/// A conversation / chat session
class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.avatarColor,
    required this.lastMessage,
    required this.timestamp,
    required this.messages,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final String avatar;
  final Color avatarColor;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final List<ChatMsg> messages;
}
