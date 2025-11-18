import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// Demo page showing streaming Markdown rendering
///
/// This simulates an AI chat response being streamed chunk by chunk
class StreamingMarkdownDemo extends StatefulWidget {
  const StreamingMarkdownDemo({
    super.key,
    this.styleSheet,
  });

  final MarkdownStyleSheet? styleSheet;

  @override
  State<StreamingMarkdownDemo> createState() => _StreamingMarkdownDemoState();
}

class _StreamingMarkdownDemoState extends State<StreamingMarkdownDemo> {
  StreamController<String>? _streamController;
  bool _isStreaming = false;

  // Simulated AI response chunks
  final List<String> _responseChunks = [
    '# AI Assistant Response\n\n',
    'Let me help you understand ',
    '**Markdown streaming**. ',
    'This is perfect for:\n\n',
    '## Use Cases\n\n',
    '1. **AI Chat Applications** - ',
    'Show responses as they generate\n',
    '2. **Live Documentation** - ',
    'Update docs in real-time\n',
    '3. **Collaborative Editing** - ',
    'See changes as others type\n\n',
    '---\n\n',
    '## Code Example\n\n',
    'Here\'s how easy it is:\n\n',
    '```dart\n',
    'StreamMarkdown(\n',
    '  stream: responseStream,\n',
    '  styleSheet: MarkdownStyleSheet.light(),\n',
    '  useEnhancedComponents: true,\n',
    ')\n',
    '```\n\n',
    '### Features\n\n',
    '- ✅ **Real-time rendering** ',
    'as chunks arrive\n',
    '- ✅ **Syntax highlighting** ',
    'for code blocks\n',
    '- ✅ **Table support** ',
    'with GFM syntax\n',
    '- ✅ **All Markdown features** ',
    'work seamlessly\n\n',
    '> **Note:** The rendering is ',
    'optimized for performance, ',
    'only updating the UI when new ',
    'content arrives.\n\n',
    '## Try It Out!\n\n',
    'This demo simulates streaming ',
    'by sending chunks every 50ms. ',
    'In a real app, chunks would come ',
    'from an API or WebSocket.\n\n',
    '| Feature | Supported | Notes |\n',
    '|---------|-----------|-------|\n',
    '| Headers | ✅ | All 6 levels |\n',
    '| Code | ✅ | With highlighting |\n',
    '| Tables | ✅ | GFM format |\n',
    '| Lists | ✅ | Ordered & unordered |\n\n',
    '**That\'s it!** ',
    'The stream is now complete. ',
    '*Click "Start Stream" to see it again.*\n',
  ];

  Future<void> _startStreaming() async {
    if (_isStreaming) return;

    setState(() {
      _isStreaming = true;
      _streamController = StreamController<String>();
    });

    // Simulate streaming chunks with delay
    for (final chunk in _responseChunks) {
      if (!mounted || _streamController == null) break;
      _streamController!.add(chunk);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (mounted) {
      setState(() {
        _isStreaming = false;
      });
      await _streamController?.close();
    }
  }

  void _resetStream() {
    _streamController?.close();
    setState(() {
      _streamController = null;
      _isStreaming = false;
    });
  }

  @override
  void dispose() {
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streaming Markdown Demo'),
        actions: [
          if (_streamController != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetStream,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Column(
        children: [
          // Control panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _streamController == null && !_isStreaming
                        ? _startStreaming
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Stream'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _streamController != null || _isStreaming
                        ? _resetStream
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),

          // Status indicator
          if (_isStreaming)
            const LinearProgressIndicator()
          else if (_streamController != null)
            Container(
              height: 4,
              color: Colors.green,
            ),

          // Streaming content
          Expanded(
            child: _streamController == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stream,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Click "Start Stream" to begin',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Watch as Markdown renders in real-time',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: StreamMarkdown(
                      stream: _streamController!.stream,
                      styleSheet: widget.styleSheet,
                      useEnhancedComponents: true,
                      loadingWidget: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
