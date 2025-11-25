import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThinkingPlugin', () {
    late ParserPluginRegistry registry;
    late MarkdownParser parser;

    setUp(() {
      registry = ParserPluginRegistry();
      registry.register(const ThinkingPlugin());
      parser = MarkdownParser(plugins: registry);
    });

    test('parses XML-style thinking block', () {
      const markdown = '''
<thinking>
Let me analyze this step by step...
First, I need to consider the problem.
</thinking>
''';

      final nodes = parser.parse(markdown);
      expect(nodes.length, equals(1));
      expect(nodes.first, isA<ThinkingNode>());

      final thinkingNode = nodes.first as ThinkingNode;
      expect(thinkingNode.content, contains('step by step'));
      expect(thinkingNode.isCollapsed, isTrue);
    });

    test('parses think shorthand', () {
      const markdown = '''
<think>
Short thinking content
</think>
''';

      final nodes = parser.parse(markdown);
      expect(nodes.length, equals(1));
      expect(nodes.first, isA<ThinkingNode>());

      final thinkingNode = nodes.first as ThinkingNode;
      expect(thinkingNode.content, equals('Short thinking content'));
    });

    test('parses markdown-style thinking block', () {
      const markdown = '''
<|thinking|>
Alternative syntax for thinking
<|/thinking|>
''';

      final nodes = parser.parse(markdown);
      expect(nodes.length, equals(1));
      expect(nodes.first, isA<ThinkingNode>());
    });

    test('handles multiline thinking content', () {
      const markdown = '''
<thinking>
Line 1
Line 2
Line 3
</thinking>
''';

      final nodes = parser.parse(markdown);
      final thinkingNode = nodes.first as ThinkingNode;
      expect(thinkingNode.content, contains('Line 1'));
      expect(thinkingNode.content, contains('Line 2'));
      expect(thinkingNode.content, contains('Line 3'));
    });
  });

  group('ArtifactPlugin', () {
    late ParserPluginRegistry registry;
    late MarkdownParser parser;

    setUp(() {
      registry = ParserPluginRegistry();
      registry.register(const ArtifactPlugin());
      parser = MarkdownParser(plugins: registry);
    });

    test('parses code artifact', () {
      const markdown = '''
<artifact identifier="hello-py" type="code" language="python" title="Hello World">
print("Hello, World!")
</artifact>
''';

      final nodes = parser.parse(markdown);
      expect(nodes.length, equals(1));
      expect(nodes.first, isA<ArtifactNode>());

      final artifactNode = nodes.first as ArtifactNode;
      expect(artifactNode.identifier, equals('hello-py'));
      expect(artifactNode.artifactType, equals(ArtifactType.code));
      expect(artifactNode.language, equals('python'));
      expect(artifactNode.title, equals('Hello World'));
      expect(artifactNode.content, contains('print'));
    });

    test('parses document artifact', () {
      const markdown = '''
<artifact id="readme" type="document" title="README">
# My Project
This is a sample project.
</artifact>
''';

      final nodes = parser.parse(markdown);
      final artifactNode = nodes.first as ArtifactNode;
      expect(artifactNode.identifier, equals('readme'));
      expect(artifactNode.artifactType, equals(ArtifactType.document));
    });

    test('parses artifact with minimal attributes', () {
      const markdown = '''
<artifact id="test" type="html">
<div>Hello</div>
</artifact>
''';

      final nodes = parser.parse(markdown);
      final artifactNode = nodes.first as ArtifactNode;
      expect(artifactNode.identifier, equals('test'));
      expect(artifactNode.artifactType, equals(ArtifactType.html));
      expect(artifactNode.title, isNull);
    });

    test('handles custom artifact type', () {
      const markdown = '''
<artifact id="custom" type="my-custom-type">
Custom content
</artifact>
''';

      final nodes = parser.parse(markdown);
      final artifactNode = nodes.first as ArtifactNode;
      expect(artifactNode.artifactType, equals(ArtifactType.custom));
      expect(artifactNode.customType, equals('my-custom-type'));
    });

    test('parses mermaid artifact', () {
      const markdown = '''
<artifact id="diagram" type="mermaid" title="Flow Chart">
graph TD
    A[Start] --> B[End]
</artifact>
''';

      final nodes = parser.parse(markdown);
      final artifactNode = nodes.first as ArtifactNode;
      expect(artifactNode.artifactType, equals(ArtifactType.mermaid));
    });
  });

  group('ToolCallPlugin', () {
    late ParserPluginRegistry registry;
    late MarkdownParser parser;

    setUp(() {
      registry = ParserPluginRegistry();
      registry.register(const ToolCallPlugin());
      parser = MarkdownParser(plugins: registry);
    });

    test('parses tool_use block', () {
      const markdown = '''
<tool_use>
<tool_name>search</tool_name>
<tool_id>search_001</tool_id>
<input>
query: "flutter markdown"
</input>
</tool_use>
''';

      final nodes = parser.parse(markdown);
      expect(nodes.length, equals(1));
      expect(nodes.first, isA<ToolCallNode>());

      final toolCallNode = nodes.first as ToolCallNode;
      expect(toolCallNode.toolName, equals('search'));
      expect(toolCallNode.toolId, equals('search_001'));
      expect(toolCallNode.parameters, contains('flutter markdown'));
    });

    test('parses tool without id', () {
      const markdown = '''
<tool_use>
<tool_name>calculator</tool_name>
<input>
expression: "2 + 2"
</input>
</tool_use>
''';

      final nodes = parser.parse(markdown);
      final toolCallNode = nodes.first as ToolCallNode;
      expect(toolCallNode.toolName, equals('calculator'));
      expect(toolCallNode.toolId, isNull);
    });

    test('parses tool without input', () {
      const markdown = '''
<tool_use>
<tool_name>get_time</tool_name>
</tool_use>
''';

      final nodes = parser.parse(markdown);
      final toolCallNode = nodes.first as ToolCallNode;
      expect(toolCallNode.toolName, equals('get_time'));
      expect(toolCallNode.parameters, isNull);
    });

    test('default status is pending', () {
      const markdown = '''
<tool_use>
<tool_name>test</tool_name>
</tool_use>
''';

      final nodes = parser.parse(markdown);
      final toolCallNode = nodes.first as ToolCallNode;
      expect(toolCallNode.status, equals(ToolCallStatus.pending));
    });
  });

  group('Combined AI Chat Plugins', () {
    late ParserPluginRegistry registry;
    late MarkdownParser parser;

    setUp(() {
      registry = ParserPluginRegistry();
      registry.register(const ThinkingPlugin());
      registry.register(const ArtifactPlugin());
      registry.register(const ToolCallPlugin());
      parser = MarkdownParser(plugins: registry);
    });

    test('parses mixed content', () {
      const markdown = '''
<thinking>
Let me think about this...
</thinking>

Here is some regular text.

<artifact id="code" type="code" language="dart">
void main() {
  print('Hello');
}
</artifact>

<tool_use>
<tool_name>execute</tool_name>
</tool_use>
''';

      final nodes = parser.parse(markdown);

      // Find each type of node
      final thinkingNodes =
          nodes.whereType<ThinkingNode>().toList();
      final artifactNodes =
          nodes.whereType<ArtifactNode>().toList();
      final toolCallNodes =
          nodes.whereType<ToolCallNode>().toList();

      expect(thinkingNodes.length, equals(1));
      expect(artifactNodes.length, equals(1));
      expect(toolCallNodes.length, equals(1));
    });
  });

  group('Node copyWith and toJson', () {
    test('ThinkingNode copyWith', () {
      const node = ThinkingNode(
        content: 'original',
        isCollapsed: true,
      );

      final copied = node.copyWith(
        content: 'modified',
        isCollapsed: false,
      );

      expect(copied.content, equals('modified'));
      expect(copied.isCollapsed, isFalse);
    });

    test('ThinkingNode toJson', () {
      const node = ThinkingNode(
        content: 'test content',
        isCollapsed: true,
      );

      final json = node.toJson();
      expect(json['type'], equals('thinking'));
      expect(json['content'], equals('test content'));
      expect(json['isCollapsed'], isTrue);
    });

    test('ArtifactNode copyWith', () {
      const node = ArtifactNode(
        identifier: 'id1',
        artifactType: ArtifactType.code,
        content: 'original',
      );

      final copied = node.copyWith(
        identifier: 'id2',
        title: 'New Title',
      );

      expect(copied.identifier, equals('id2'));
      expect(copied.title, equals('New Title'));
      expect(copied.content, equals('original'));
    });

    test('ArtifactNode toJson', () {
      const node = ArtifactNode(
        identifier: 'test-id',
        artifactType: ArtifactType.document,
        content: 'doc content',
        title: 'Doc Title',
      );

      final json = node.toJson();
      expect(json['type'], equals('artifact'));
      expect(json['identifier'], equals('test-id'));
      expect(json['artifactType'], equals('document'));
      expect(json['title'], equals('Doc Title'));
    });

    test('ToolCallNode copyWith', () {
      const node = ToolCallNode(
        toolName: 'search',
        status: ToolCallStatus.pending,
      );

      final copied = node.copyWith(
        status: ToolCallStatus.completed,
        result: 'Found 10 results',
      );

      expect(copied.toolName, equals('search'));
      expect(copied.status, equals(ToolCallStatus.completed));
      expect(copied.result, equals('Found 10 results'));
    });

    test('ToolCallNode toJson', () {
      const node = ToolCallNode(
        toolName: 'calculator',
        toolId: 'calc_001',
        status: ToolCallStatus.running,
      );

      final json = node.toJson();
      expect(json['type'], equals('tool_call'));
      expect(json['toolName'], equals('calculator'));
      expect(json['toolId'], equals('calc_001'));
      expect(json['status'], equals('running'));
    });
  });
}
