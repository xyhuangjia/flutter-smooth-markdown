import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// 独立的标题行内格式测试页面
class HeaderTestPage extends StatelessWidget {
  const HeaderTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Header Inline Format Test'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SmoothMarkdown(
          data: '''
# 标题行内格式测试

## 📝 **我的建议** - 这是粗体

这个标题应该显示为：📝 后面是粗体的"我的建议"

---

## 更多测试

### This is *italic* text

### **Bold** and *italic* mixed

### Use \`code\` in headers

### Check [this link](https://flutter.dev)

### 🎉 **Celebration** with *style*

### ⚡ Performance **optimization** \`v2.0\`

---

## 验证清单

如果以下标题中的格式都正确显示，说明功能正常：

1. **粗体**: ## **重要** 通知
2. *斜体*: ## *注意* 事项
3. 代码: ## 运行 \`flutter test\`
4. 链接: ## 查看 [文档](https://flutter.dev)
5. 混合: ## 🚀 **快速** *开始* \`v2.0\`

---

# H1 标题测试

## H2 标题测试 - **粗体** 和 *斜体*

### H3 标题测试 - 使用 \`代码\`

#### H4 标题测试 - [链接](url)

##### H5 标题测试 - ~~删除线~~

###### H6 标题测试 - 所有 **格式** *混合* \`code\` [链接](url)
''',
        ),
      ),
    );
  }
}
