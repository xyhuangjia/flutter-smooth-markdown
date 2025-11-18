import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Smooth Markdown Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: const MarkdownDemoPage(),
    );
  }
}

class MarkdownDemoPage extends StatefulWidget {
  const MarkdownDemoPage({super.key});

  @override
  State<MarkdownDemoPage> createState() => _MarkdownDemoPageState();
}

class _MarkdownDemoPageState extends State<MarkdownDemoPage> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<MarkdownExample> _examples = [
    MarkdownExample(
      title: 'Basic Formatting',
      markdown: '''
# Basic Text Formatting

This is a **paragraph** with different text styles.

You can make text **bold** or *italic*. You can also combine ***both***.

For inline code, use backticks: `var x = 42;`

You can also use ~~strikethrough~~ text.
''',
    ),
    MarkdownExample(
      title: 'Headers',
      markdown: '''
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

Regular paragraph text follows headers.
''',
    ),
    MarkdownExample(
      title: 'Lists',
      markdown: '''
# Unordered Lists

- Item 1
- Item 2
- Item 3
  - Nested items work too

# Ordered Lists

1. First item
2. Second item
3. Third item

# Task Lists

- [x] Completed task
- [ ] Pending task
- [x] Another completed task
- [ ] Another pending task
''',
    ),
    MarkdownExample(
      title: 'Code Blocks',
      markdown: '''
# Code Example

Here's a Dart code block:

```dart
void main() {
  print('Hello, World!');

  final numbers = [1, 2, 3, 4, 5];
  final doubled = numbers.map((n) => n * 2);

  print('Doubled: \$doubled');
}
```

And some JavaScript:

```javascript
function greet(name) {
  console.log(\`Hello, \${name}!\`);
}

greet('Flutter');
```
''',
    ),
    MarkdownExample(
      title: 'Quotes & Rules',
      markdown: '''
# Blockquotes

> This is a blockquote.
> It can span multiple lines.
>
> And have multiple paragraphs.

---

# Horizontal Rules

Text above the rule

---

Text below the rule

***

Another rule style
''',
    ),
    MarkdownExample(
      title: 'Links & Images',
      markdown: '''
# Links

Check out [Flutter](https://flutter.dev) for more information.

Here's a [GitHub link](https://github.com) you can click.

# Images

![Flutter Logo](https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png)

![Alt text for broken image](https://example.com/nonexistent.png)
''',
    ),
    MarkdownExample(
      title: 'Complex Example',
      markdown: '''
# Complete Markdown Demo

This demonstrates **all features** working together.

## Text Formatting

You can mix *italic*, **bold**, and `code` in the same paragraph.
Even ~~strikethrough~~ works inline!

## Code Example

```dart
class MarkdownRenderer {
  final StyleSheet styleSheet;

  Widget render(String markdown) {
    final nodes = parse(markdown);
    return buildWidgets(nodes);
  }
}
```

## Lists and Tasks

Shopping List:
- [x] Buy groceries
- [x] Write documentation
- [ ] Deploy to production

Priority order:
1. Fix critical bugs
2. Add new features
3. Optimize performance

## Quotes

> "The best way to predict the future is to invent it."
> - Alan Kay

---

## Summary

This package supports:
- **Headers** (H1-H6)
- **Text styles** (bold, italic, strikethrough)
- **Code** blocks and inline
- **Lists** (ordered, unordered, tasks)
- **Quotes** and horizontal rules
- **Links** and images

For more info, visit [the docs](https://example.com).
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final example = _examples[_selectedIndex];
    final styleSheet = _isDarkMode
        ? MarkdownStyleSheet.dark()
        : MarkdownStyleSheet.light();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth Markdown Demo'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.article, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Markdown Examples',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(_examples.length, (index) {
              return ListTile(
                leading: Icon(
                  _getIconForExample(index),
                  color: _selectedIndex == index ? Colors.blue : null,
                ),
                title: Text(
                  _examples[index].title,
                  style: TextStyle(
                    fontWeight: _selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  _getIconForExample(_selectedIndex),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  example.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SmoothMarkdown(
                data: example.markdown,
                styleSheet: styleSheet,
                onTapLink: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link tapped: $url'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Markdown Source'),
              content: SingleChildScrollView(
                child: SelectableText(
                  example.markdown,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        tooltip: 'View Markdown Source',
        child: const Icon(Icons.code),
      ),
    );
  }

  IconData _getIconForExample(int index) {
    switch (index) {
      case 0:
        return Icons.format_bold;
      case 1:
        return Icons.title;
      case 2:
        return Icons.list;
      case 3:
        return Icons.code;
      case 4:
        return Icons.format_quote;
      case 5:
        return Icons.link;
      case 6:
        return Icons.dashboard;
      default:
        return Icons.article;
    }
  }
}

class MarkdownExample {
  const MarkdownExample({
    required this.title,
    required this.markdown,
  });

  final String title;
  final String markdown;
}
