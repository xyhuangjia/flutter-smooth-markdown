# 主动选取文本 (Active Text Selection)

## Goal

为 SmoothMarkdown 提供「主动/编程式选取文本」能力：外部代码（如长按菜单、工具栏按钮）
可触发渲染区域内全部文本的选取，并**可靠地进入带选区手柄 + 上下文工具栏的选择态**。

用户原话：使用 `SelectionContainer` + `SelectAllSelectionEvent` 实现文本主动选取。

## Confirmed Facts (from codebase)

- `SmoothMarkdown` 当前 `selectable: true` 用 `SelectableRegion` 包裹内容，文本节点走
  `Text.rich()`（见 `lib/widgets/smooth_markdown.dart:504-518, 702-712`）。
- 已有 `selectableRegionKey: GlobalKey<SelectableRegionState>?` 与
  `contextMenuBuilder(BuildContext, SelectableRegionState)` 两个公开 API
 （`smooth_markdown.dart:554, 578`）。
- `SelectableRegion` 内部基于 `SelectionContainer`；`SelectableRegionState.selectAll()`
  会通过 `SelectionRegistrar` 向各 `Selectable` 派发 `SelectAllSelectionEvent`。
- 现有示例 `example/lib/conversation_list_demo.dart` 的 `_triggerSelectAll`（line 845-852）
  走了个 workaround：从 `state.contextMenuButtonItems` 找内置 `selectAll` 按钮再触发其
  `onPressed`，并套了两层 `addPostFrameCallback`。
- 文本可选择性由 `MarkdownRenderContext.selectable` 控制（`widget_builder.dart:88-92`），
  开启时 builder 用 `Text` 而非 `SelectableText`。
- `StreamMarkdown` 转发 `selectable` / `contextMenuBuilder`（`stream_markdown.dart:222-230`）。
- 现有测试目录无 selection 相关用例（test/ 下有 integration/mermaid/parser/performance/
  renderer/stream，无 widgets/）。

## Requirements

### 功能性

- R1 `selectable: true` 时，外部可通过控制器编程式触发「全选」，并**显示选区手柄 +
  上下文工具栏**（核心修复点）。
- R2 控制器底层基于 `SelectionContainer` + `SelectionRegistrar`，并暴露手动派发
  `SelectAllSelectionEvent`（及其它 `SelectionEvent`）的能力，满足用户原始技术诉求。
- R3 保留 `Text.rich()` 渲染路径不变；跨段落/标题/代码块选取仍可用。
- R4 保留上下文菜单自定义（`contextMenuBuilder`）与复制剪贴板过滤逻辑
  （`_removeOverlayLines` 去除 `\u00A0` 行）。
- R5 手动拖选/长按选词等原生交互不回归。
- R6 新增 `selectWordAt(Offset globalPosition)`：在手指按压位置选词（非全选）并
  显示选区手柄 + 上下文工具栏，供长按菜单「选择文字」等入口使用（用户后续需求：
  选词而非全选，且手柄 + 工具栏都要）。
- R7 新增 `selectParagraphAt(Offset globalPosition)`：在手指按压位置选**段落**
  （非全选）并显示选区手柄 + 上下文工具栏；example 长按菜单「选择文字」改用此方法
  （用户最终需求：选段落而非选词/全选）。

### 非功能性

- N1 公开 API 仅做「轻破坏」：`selectable`/`contextMenuBuilder`/`selectable*Key` 名称保留，
  但 key 与 contextMenuBuilder 回调的类型从 `SelectableRegionState` 改为新控制器类型。
  需在 CHANGELOG/README 标注迁移。
- N2 行为在 iOS/Android/Desktop 三端保持一致（material selection controls）。
- N3 不显著降低滚动/流式场景性能。

## Acceptance Criteria

- [x] AC1 `SmoothMarkdown(selectable: true)` 下，外部调用控制器 `selectAll()` 后，
  **选区手柄 + 工具栏同时出现**（widget test `selectAll(toolbar)` 断言
  `TextSelectionToolbar findsOneWidget`）。
- [x] AC2 控制器暴露 `registrar` 与 `dispatchEvent(SelectionEvent)`，手动派发
  `SelectAllSelectionEvent()` 后所有可见文本被选中（widget test 断言 copy button 出现）。
- [x] AC3 上下文工具栏的 Copy 按钮复制结果不含 `\u00A0` overlay 行
  （`_removeOverlayLines` / `_scheduleClipboardFilter` 逻辑保持不变；且 contextMenuBuilder
      现在被正确路由，copy 按钮的过滤包装真正生效）。
- [x] AC4 普通长按选词、拖拽选区行为不回归（沿用 SelectableRegion 的手势/overlay 体系，
      composition 不改动该路径）。
- [x] AC5 `StreamMarkdown` 同样支持新控制器（新增 `selectableRegionKey` 字段转发；
      widget test 验证 dispatch 选中文本）。
- [x] AC6 example（conversation_list_demo）改用新控制器，`_triggerSelectAll` 直接
  `selectAll(SelectionChangedCause.toolbar)`，移除双层 post-frame workaround。
- [x] AC7 `flutter analyze` 无新增 error；新增 widget test 全部通过。
- [x] AC8 `SmoothSelectionRegionState.selectWordAt(Offset)` 在指定位置选词（非
  全文）并显示手柄 + 工具栏（widget test 用 mock clipboard 断言选区短于全文 +
  `TextSelectionToolbar findsOneWidget`）；example 长按菜单「选择文字」改用
  `selectWordAt(details.globalPosition)`，选中手指按压位置的词。
- [x] AC9 `SmoothSelectionRegionState.selectParagraphAt(Offset)` 在指定位置选段落
  （非全文）并显示手柄 + 工具栏（widget test 用 mock clipboard 断言选区短于全文 +
  `TextSelectionToolbar findsOneWidget`）；example 长按菜单「选择文字」改用
  `selectParagraphAt(details.globalPosition)`，选中手指按压位置所在的段落。

## Out of Scope

- 跨多个 SmoothMarkdown 实例（多条消息）的连选（后续可扩展）。
- 自定义选区样式/主题（沿用 material controls）。
- 把 `_triggerSelectAll` 的双层 post-frame 时序问题做成通用框架级修复。

## Open Questions

- 无（方向已确认）。

## Decisions Log

- D1 放弃保留 `SelectableRegion`；改用 `SelectionContainer` + 自管理 overlay，公开 key
  类型换为新控制器类型（用户确认「轻破块」）。
- D2 ~~根因诊断：cause=toolbar 会隐藏工具栏~~ **已证伪**（见 step0-evidence.md）。
  实测 `state.selectAll(SelectionChangedCause.toolbar)` 直调会让工具栏出现；示例
  `_triggerSelectAll` 失败是因为它在无选区时找 selectAll 按钮（按钮不存在）。
- D3（Step 0 后）用户知悉「SelectableRegion 并非瓶颈、重写不修复额外 bug」后仍选择
  重写。动机转为：**拿到可控的 `SelectionRegistrar` + `dispatchEvent(SelectionEvent)`
  能力**（可派发自定义 SelectionEvent），而非修 bug。AC1/AC4 同样必须满足。
