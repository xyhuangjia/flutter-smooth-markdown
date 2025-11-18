import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownParseCache Performance Tests', () {
    late MarkdownParseCache cache;
    late MarkdownParser parser;

    setUp(() {
      cache = MarkdownParseCache(maxSize: 10);
      parser = MarkdownParser();
    });

    tearDown(() {
      cache.clear();
    });

    test('cache hit should be faster than parsing', () {
      const markdown = '''
# Performance Test

This is a test document with **bold** and *italic* text.

## Code Block

```dart
void main() {
  print('Hello, World!');
}
```

- List item 1
- List item 2
- List item 3
''';

      // Measure parsing time
      final parseStart = DateTime.now();
      final nodes = parser.parse(markdown);
      final parseTime = DateTime.now().difference(parseStart);

      // Store in cache
      cache.put(markdown, nodes);

      // Measure cache retrieval time
      final cacheStart = DateTime.now();
      final cached = cache.get(markdown);
      final cacheTime = DateTime.now().difference(cacheStart);

      expect(cached, isNotNull);
      expect(cached!.length, equals(nodes.length));

      // Cache should be significantly faster (at least 10x)
      expect(cacheTime.inMicroseconds, lessThan(parseTime.inMicroseconds ~/ 10));

      // ignore: avoid_print
      print('Parse time: ${parseTime.inMicroseconds}µs');
      // ignore: avoid_print
      print('Cache time: ${cacheTime.inMicroseconds}µs');
      // ignore: avoid_print
      print('Speed improvement: ${parseTime.inMicroseconds ~/ cacheTime.inMicroseconds}x');
    });

    test('LRU eviction works correctly', () {
      // Fill cache to capacity
      for (var i = 0; i < 10; i++) {
        final markdown = '# Message $i';
        final nodes = parser.parse(markdown);
        cache.put(markdown, nodes);
      }

      expect(cache.length, equals(10));

      // Access first entry to make it most recently used
      cache.get('# Message 0');

      // Add new entry, should evict Message 1 (least recently used)
      final newMarkdown = '# Message 10';
      final newNodes = parser.parse(newMarkdown);
      cache.put(newMarkdown, newNodes);

      expect(cache.length, equals(10));
      expect(cache.contains('# Message 0'), isTrue); // Still there
      expect(cache.contains('# Message 1'), isFalse); // Evicted
      expect(cache.contains('# Message 10'), isTrue); // Added
    });

    test('cache statistics are accurate', () {
      expect(cache.statistics['size'], equals(0));
      expect(cache.statistics['maxSize'], equals(10));
      expect(cache.statistics['utilization'], equals(0.0));

      // Add 5 entries
      for (var i = 0; i < 5; i++) {
        final markdown = '# Test $i';
        final nodes = parser.parse(markdown);
        cache.put(markdown, nodes);
      }

      expect(cache.statistics['size'], equals(5));
      expect(cache.statistics['utilization'], equals(0.5));
    });

    test('repeated messages benefit from caching', () {
      const commonMessage = '**Error**: File not found';

      // Simulate rendering the same error message 100 times
      var totalParseTime = Duration.zero;
      var totalCacheTime = Duration.zero;

      for (var i = 0; i < 100; i++) {
        final cached = cache.get(commonMessage);
        if (cached == null) {
          final start = DateTime.now();
          final nodes = parser.parse(commonMessage);
          totalParseTime += DateTime.now().difference(start);
          cache.put(commonMessage, nodes);
        } else {
          final start = DateTime.now();
          cache.get(commonMessage);
          totalCacheTime += DateTime.now().difference(start);
        }
      }

      // ignore: avoid_print
      print('Total parse time: ${totalParseTime.inMicroseconds}µs');
      // ignore: avoid_print
      print('Total cache time: ${totalCacheTime.inMicroseconds}µs');
      // ignore: avoid_print
      print('Cache hits: 99/100');

      expect(totalCacheTime.inMicroseconds, lessThan(totalParseTime.inMicroseconds * 2));
    });

    test('large cache handles many unique messages', () {
      final largeCache = MarkdownParseCache(maxSize: 500);

      // Add 500 unique messages
      final start = DateTime.now();
      for (var i = 0; i < 500; i++) {
        final markdown = '# Message $i\n\nThis is message number $i';
        final nodes = parser.parse(markdown);
        largeCache.put(markdown, nodes);
      }
      final fillTime = DateTime.now().difference(start);

      expect(largeCache.length, equals(500));

      // Access all entries (should be fast)
      final accessStart = DateTime.now();
      for (var i = 0; i < 500; i++) {
        final markdown = '# Message $i\n\nThis is message number $i';
        final cached = largeCache.get(markdown);
        expect(cached, isNotNull);
      }
      final accessTime = DateTime.now().difference(accessStart);

      // ignore: avoid_print
      print('Fill time (500 entries): ${fillTime.inMilliseconds}ms');
      // ignore: avoid_print
      print('Access time (500 lookups): ${accessTime.inMilliseconds}ms');
      // ignore: avoid_print
      print('Average lookup: ${accessTime.inMicroseconds ~/ 500}µs');

      largeCache.clear();
    });

    test('memory cleanup works correctly', () {
      // Add many entries
      for (var i = 0; i < 100; i++) {
        final markdown = '# Message $i';
        final nodes = parser.parse(markdown);
        cache.put(markdown, nodes);
      }

      // Cache should have evicted old entries
      expect(cache.length, equals(10)); // maxSize

      // Clear cache
      cache.clear();
      expect(cache.length, equals(0));
      expect(cache.isEmpty, isTrue);
    });

    test('cache handles empty and null inputs gracefully', () {
      final nodes = parser.parse('');
      cache.put('', nodes);

      final cached = cache.get('');
      expect(cached, isNotNull);
      expect(cached!.isEmpty, isTrue);
    });

    test('benchmark: chat scenario with repeated patterns', () {
      // Simulate a chat with common patterns
      final patterns = [
        '**Bold message**',
        '*Italic message*',
        '`code snippet`',
        '[Link](https://example.com)',
        'Plain text message',
      ];

      // Simulate 1000 messages using these patterns
      final start = DateTime.now();
      var cacheHits = 0;
      var cacheMisses = 0;

      for (var i = 0; i < 1000; i++) {
        final markdown = patterns[i % patterns.length];
        final cached = cache.get(markdown);

        if (cached == null) {
          final nodes = parser.parse(markdown);
          cache.put(markdown, nodes);
          cacheMisses++;
        } else {
          cacheHits++;
        }
      }

      final totalTime = DateTime.now().difference(start);

      // ignore: avoid_print
      print('Chat simulation (1000 messages):');
      // ignore: avoid_print
      print('  Total time: ${totalTime.inMilliseconds}ms');
      // ignore: avoid_print
      print('  Cache hits: $cacheHits');
      // ignore: avoid_print
      print('  Cache misses: $cacheMisses');
      // ignore: avoid_print
      print('  Hit rate: ${(cacheHits / 1000 * 100).toStringAsFixed(1)}%');

      expect(cacheHits, greaterThan(cacheMisses));
      expect(totalTime.inMilliseconds, lessThan(1000)); // Should be fast
    });
  });
}
