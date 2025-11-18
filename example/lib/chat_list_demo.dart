import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// A realistic chat interface demo showcasing performance optimizations.
///
/// This example demonstrates a ChatGPT-like interface with:
/// - Parse caching for improved scroll performance
/// - RepaintBoundary for rendering isolation
/// - AutomaticKeepAliveClientMixin for state preservation
/// - Proper use of keys for widget identity
/// - Streaming markdown for real-time AI responses
class ChatListDemo extends StatefulWidget {
  const ChatListDemo({super.key});

  @override
  State<ChatListDemo> createState() => _ChatListDemoState();
}

class _ChatListDemoState extends State<ChatListDemo> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isStreaming = false;
  StreamController<String>? _streamController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadWelcomeMessage();
  }

  void _loadWelcomeMessage() {
    _messages.add(ChatMessage(
      id: 'welcome',
      content: '''
# 👋 Welcome to Chat Demo!

I'm your AI assistant powered by **Flutter Smooth Markdown** with performance optimizations.

## What I can help with:

- **Code Examples** - Ask me about programming
- **Markdown Formatting** - I support full markdown syntax
- **Real-time Streaming** - Watch as I type my responses
- **Performance Demo** - Scroll smoothly through our conversation

### Try asking me:
- "Show me a code example"
- "Explain markdown features"
- "Tell me about performance"

💡 **Tip**: Click the 📊 icon to see cache statistics!
''',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();
    _scrollToBottom();

    // Auto respond after a short delay
    Future.delayed(const Duration(milliseconds: 500), _generateAIResponse);
  }

  void _generateAIResponse() {
    if (_isStreaming) return;

    setState(() {
      _isStreaming = true;
      _streamController = StreamController<String>();
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        stream: _streamController!.stream,
      ));
    });

    _scrollToBottom();
    _streamAIResponse();
  }

  Future<void> _streamAIResponse() async {
    final responses = [
      _getCodeExampleResponse(),
      _getMarkdownFeaturesResponse(),
      _getPerformanceResponse(),
      _getTableResponse(),
    ];

    final response = responses[Random().nextInt(responses.length)];

    // Simulate realistic typing speed
    const baseChunkSize = 3;
    for (var i = 0; i < response.length;) {
      if (!mounted) break;

      // Variable chunk size for more natural typing
      final chunkSize = baseChunkSize + Random().nextInt(3);
      final end = min(i + chunkSize, response.length);
      final chunk = response.substring(i, end);

      _streamController?.add(chunk);

      // Variable delay for natural typing rhythm
      final delay = 20 + Random().nextInt(30);
      await Future.delayed(Duration(milliseconds: delay));

      i = end;
    }

    await _streamController?.close();
    if (mounted) {
      setState(() {
        _isStreaming = false;
      });
    }
  }

  String _getCodeExampleResponse() {
    return '''
# 💻 Code Example

Here's a Flutter widget with performance optimizations:

```dart
class OptimizedChatMessage extends StatefulWidget {
  const OptimizedChatMessage({
    required this.message,
    super.key,
  });

  final String message;

  @override
  State<OptimizedChatMessage> createState() => _OptimizedChatMessageState();
}

class _OptimizedChatMessageState extends State<OptimizedChatMessage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;  // ✅ Keep state alive

  @override
  Widget build(BuildContext context) {
    super.build(context);  // Required!

    return SmoothMarkdown(
      key: ValueKey(widget.message.id),
      data: widget.message.content,
      enableCache: true,  // ✅ Enable caching
      useRepaintBoundary: true,  // ✅ Isolate repaints
      styleSheet: MarkdownStyleSheet.light(),
    );
  }
}
```

**Key optimizations:**
- ✅ Cache hit: ~0.1ms vs ~15ms parsing
- ✅ RepaintBoundary reduces overdraw by 30%
- ✅ KeepAlive preserves state during scrolling
''';
  }

  String _getMarkdownFeaturesResponse() {
    return '''
# ✨ Markdown Features

I support rich **formatting** and *styling*!

## Lists

- ✅ Bullet points
- ✅ Numbered lists
- ✅ Task lists

## Code Blocks

```python
def calculate_fibonacci(n):
    """Calculate Fibonacci number efficiently."""
    if n <= 1:
        return n

    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b

    return b

# Example usage
result = calculate_fibonacci(10)
print(f"Fibonacci(10) = {result}")
```

## Quotes

> "The best way to predict the future is to invent it."
>
> — Alan Kay

## Links & More

Check out [Flutter Smooth Markdown](https://github.com) for more features!
''';
  }

  String _getPerformanceResponse() {
    return '''
# 🚀 Performance Optimizations

This chat demo includes several optimizations:

## 1. Parse Caching (32x faster!)

| Scenario | Without Cache | With Cache | Speedup |
|----------|--------------|------------|---------|
| First parse | 3.6ms | 3.6ms | 1x |
| Re-render | 3.6ms | 0.11ms | **32x** |
| Scroll (50 msgs) | 180ms | 5.5ms | **32x** |

## 2. Smart Rendering

- ✅ **RepaintBoundary** - Isolates each message
- ✅ **KeepAlive** - Preserves off-screen state
- ✅ **Throttling** - Batches stream updates (50ms)

## 3. Memory Management

```dart
// Cache statistics
final stats = SmoothMarkdown.cacheStatistics;
print('Cached: \${stats['size']}/\${stats['maxSize']}');
print('Hit rate: \${stats['utilization'] * 100}%');
```

**Result**: 60 FPS smooth scrolling! 🎯
''';
  }

  String _getTableResponse() {
    return '''
# 📊 Feature Comparison

Here's how different markdown renderers compare:

| Feature | Standard | Enhanced | Performance |
|---------|:--------:|:--------:|:-----------:|
| Parse Caching | ❌ | ✅ | **32x faster** |
| Stream Support | ❌ | ✅ | Real-time |
| Code Copy | ❌ | ✅ | One-click |
| Math Formulas | ❌ | ✅ | LaTeX |
| Table Support | ✅ | ✅ | Full GFM |
| SVG Images | ❌ | ✅ | Native |

## Why Choose This?

1. **Performance** - LRU cache + RepaintBoundary
2. **Features** - Code, math, tables, streaming
3. **UX** - Smooth animations and interactions

Try scrolling up and down - notice how smooth it is? That's the optimization at work! 🚀
''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCacheStats() {
    final stats = SmoothMarkdown.cacheStatistics;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Cache Statistics'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Cached Entries', '${stats['size']}'),
            const SizedBox(height: 8),
            _buildStatRow('Max Capacity', '${stats['maxSize']}'),
            const SizedBox(height: 8),
            _buildStatRow(
              'Utilization',
              '${(stats['utilization'] * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cache hits are ${((stats['utilization'] as double) > 0.5 ? '32x' : 'N/A')} faster than parsing!',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              SmoothMarkdown.clearCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cache cleared successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Cache'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDarkMode || theme.brightness == Brightness.dark;

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _isStreaming ? 'Typing...' : 'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isStreaming ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              tooltip: 'Toggle theme',
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: _showCacheStats,
              tooltip: 'Cache Statistics',
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatBubbleWidget(
                    key: ValueKey(_messages[index].id),
                    message: _messages[index],
                    isDark: isDark,
                  );
                },
              ),
            ),

            // Input area
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3A3A3C)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            hintText: 'Message AI Assistant...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _sendMessage,
                          enabled: !_isStreaming,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _isStreaming
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isStreaming ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _isStreaming
                            ? null
                            : () => _sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _streamController?.close();
    super.dispose();
  }
}

/// A single chat bubble widget with performance optimizations
class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    required this.message,
    required this.isDark,
    super.key,
  });

  final ChatMessage message;
  final bool isDark;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: widget.message.isUser
                    ? (widget.isDark
                        ? const Color(0xFF0A84FF)
                        : const Color(0xFF007AFF))
                    : (widget.isDark
                        ? const Color(0xFF2C2C2E)
                        : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Render markdown with optimizations
                  if (widget.message.stream != null)
                    StreamMarkdown(
                      stream: widget.message.stream!,
                      styleSheet: widget.message.isUser
                          ? _getUserStyleSheet()
                          : (widget.isDark
                              ? MarkdownStyleSheet.dark()
                              : MarkdownStyleSheet.light()),
                      useEnhancedComponents: !widget.message.isUser,
                    )
                  else
                    SmoothMarkdown(
                      data: widget.message.content,
                      enableCache: true,
                      useRepaintBoundary: true,
                      styleSheet: widget.message.isUser
                          ? _getUserStyleSheet()
                          : (widget.isDark
                              ? MarkdownStyleSheet.dark()
                              : MarkdownStyleSheet.light()),
                      useEnhancedComponents: !widget.message.isUser,
                    ),

                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.message.isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : (widget.isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[400],
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  MarkdownStyleSheet _getUserStyleSheet() {
    return MarkdownStyleSheet(
      textStyle: const TextStyle(color: Colors.white, fontSize: 15),
      paragraphStyle: const TextStyle(color: Colors.white, fontSize: 15),
      h1Style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      h2Style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      h3Style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      inlineCodeStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        fontFamily: 'monospace',
      ),
      codeBlockStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontFamily: 'monospace',
      ),
      blockquoteDecoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 30) {
      return 'Just now';
    } else if (diff.inMinutes < 1) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Chat message data model
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.stream,
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Stream<String>? stream;
}
