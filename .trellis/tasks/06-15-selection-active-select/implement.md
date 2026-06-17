# Implement Plan — SelectionContainer + 自管理 overlay

## 验证命令

```bash
flutter analyze                       # 静态检查
flutter test test/widgets/smooth_selection_region_test.dart   # 新增 widget test
flutter test                          # 全量回归
cd example && flutter analyze         # example 静态检查
```

手动验证：
```bash
cd example && flutter run -d <device>   # 打开 conversation_list_demo
# 长按消息 → "选择文字" → 应同时看到选区手柄 + 工具栏
```

## 执行步骤（有序 checklist）

### Step 0 — 验证门：最小复现（证据先行，对冲 design.md R-1）
- [ ] 0.1 新建临时脚本/最小 widget：`SmoothMarkdown(selectable: true, selectableRegionKey: k)`，
      内容放 ListView 里模拟聊天气泡；长按菜单触发 `k.currentState?.selectAll(SelectionChangedCause.longPress)`。
- [ ] 0.2 实跑：观察手柄/工具栏是否出现。
- [ ] 0.3 记录结论到 task 笔记：
      - 若 **出现** → 把证据贴回 PRD，提示用户重新评估是否仍需自管理 overlay（可大幅缩范围）。
      - 若 **不出现** → 继续 Step 1，且把失败现象作为测试断言基础。
- [ ] 0.4 删除临时脚本，不进 commit。

### Step 1 — 新增 `SmoothSelectionRegion`（骨架）
- [ ] 1.1 新建 `lib/widgets/smooth_selection_region.dart`：
       `SmoothSelectionRegion`（StatefulWidget）+ `SmoothSelectionRegionState`。
- [ ] 1.2 State 实现/持有 `SelectionRegistrar`：维护 `List<Selectable>`，实现
       `register/unregister`（排序按 `Selectable` 的 `selectionStart/End` 或挂载顺序）。
- [ ] 1.3 build：`SelectionContainer(registrar: this, child: child)` + 一个
       `CompositedTransformTarget` 承载 overlay。
- [ ] 1.4 暴露 API：`selectAll / clearSelection / dispatchEvent / registrar /
       contextMenuButtonItems / contextMenuAnchors / selectedContent`。

### Step 2 — overlay 管理（核心、风险最高）
- [ ] 2.1 引入 `SelectionOverlay`（或 `TextSelectionOverlay` 视 API）实例字段，
       lazy 创建。
- [ ] 2.2 实现 selection 变更回调：接收 selectable 上报 → 计算首尾 handle 位置 →
       `update(...)`。
- [ ] 2.3 `selectAll(cause)`：遍历 `dispatchSelectionEvent(SelectAllSelectionEvent())`，
       随后 `showHandles()` + （cause != toolbar 时）`showToolbar()`。
- [ ] 2.4 工具栏：默认 `_defaultContextMenuBuilder`（迁移自 `smooth_markdown.dart`），
       支持用户 `contextMenuBuilder` 覆盖。
- [ ] 2.5 复制按钮包 `_scheduleClipboardFilter`（沿用 `_removeOverlayLines`）。

### Step 3 — 接入 `SmoothMarkdown`
- [ ] 3.1 `smooth_markdown.dart`：字段类型
       `selectableRegionKey: GlobalKey<SmoothSelectionRegionState>?`、
       `contextMenuBuilder: Widget Function(BuildContext, SmoothSelectionRegionState)?`。
- [ ] 3.2 build 中 `SelectableRegion(...)` → `SmoothSelectionRegion(...)`，传入
       `contextMenuBuilder` 与 `selectableRegionKey`。
- [ ] 3.3 把 `_defaultContextMenuBuilder` / `_SelectionCopyFilter` / 剪贴板过滤辅助函数
       迁移/共享到新模块（或保留 static 并 import）。
- [ ] 3.4 dartdoc 更新（selectAll 示例、迁移说明）。

### Step 4 — `StreamMarkdown` 同步
- [ ] 4.1 `stream_markdown.dart`：`contextMenuBuilder` 类型改为
       `SmoothSelectionRegionState`；新增/转发 `selectableRegionKey`（若原先未透传）。
- [ ] 4.2 流式增量时确保 region 不重建丢 state（key 稳定）。

### Step 5 — example 迁移
- [ ] 5.1 `conversation_list_demo.dart`：`_selectionKeys` 类型改
       `GlobalKey<SmoothSelectionRegionState>`。
- [ ] 5.2 删除 `_triggerSelectAll` 的 button workaround，直接
       `state.selectAll(SelectionChangedCause.longPress)`；去掉双层 post-frame。
- [ ] 5.3 contextMenuBuilder 的 "选择文字" 按钮调 `state.selectAll(...)`。

### Step 6 — 测试（test/widgets/，新建目录）
- [ ] 6.1 `smooth_selection_region_test.dart`：
       - AC1 selectAll 后 finder 找到 overlay/handle（用 `Overlay` 或
         `AdaptiveTextSelectionToolbar` finder）。
       - AC2 `dispatchEvent(SelectAllSelectionEvent())` 后 `selectedContent` 非空。
       - AC3 复制结果不含 `\u00A0` 行（mock clipboard）。
       - AC4 长按出现手柄（`flutter_test` gesture 长按）。
- [ ] 6.2 流式增量场景的最小 smoke test（AC5）。

### Step 7 — 文档与收尾
- [ ] 7.1 README：迁移段落（API 类型变更 + 示例）。
- [ ] 7.2 CHANGELOG（若存在）记录轻破坏变更。
- [ ] 7.3 `flutter analyze` + 全量 `flutter test` 通过。
- [ ] 7.4 实机/模拟器走查 conversation_list_demo。

## 风险文件 / 回滚点

| 文件 | 风险 | 回滚 |
|---|---|---|
| `lib/widgets/smooth_selection_region.dart`（新） | overlay 协调复杂 | 整文件删除 |
| `lib/widgets/smooth_markdown.dart`（改 build/字段） | 类型变更影响下游 | git revert 此文件 |
| `lib/widgets/stream_markdown.dart` | 类型跟随 | git revert |
| `example/lib/conversation_list_demo.dart` | 演示行为 | git revert |

建议按 Step 1-2 / Step 3 / Step 4-5 / Step 6-7 分 4 个 commit，便于二分与回滚。

## Review Gates

- Step 0 完成后：与用户确认证据结论是否影响范围（可能大幅缩减）。
- Step 2 完成后：自测 overlay 在静态页面可用，再接入 ListView/流式。
- Step 6 完成后：全量 test 通过再合入。
