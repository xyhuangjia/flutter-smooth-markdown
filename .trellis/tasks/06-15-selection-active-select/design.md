# Design — SelectionContainer + 自管理 overlay 主动选取

## 1. 架构与边界

新增模块 `lib/widgets/smooth_selection_region.dart`：

```
SmoothMarkdown (selectable=true)
        │
        ├── _SelectionCopyFilter (保留：Cmd/Ctrl+C 剪贴板过滤)
        │
        └── SmoothSelectionRegion   ← 新增（替代 SelectableRegion）
              │
              ├── SelectionContainer(registrar: _registrar)
              │       └── child: 渲染后的 markdown widget 树（Text.rich 节点）
              │
              └── 自管理 SelectionOverlay（手柄/magnifier/工具栏）
                    ├── _handleStart / _handleEnd（基于首尾 Selectable 的选区点）
                    ├── AdaptiveTextSelectionToolbar（contextMenuBuilder 可覆盖）
                    └── materialTextSelectionControls / cupertinoTextSelectionControls
```

**职责边界**：
- `SmoothSelectionRegion` = `StatefulWidget`，其 `State` 既充当 `SelectionRegistrar`
  （收集子 `Selectable`），又充当 selection overlay 的管理者。
- `SmoothSelectionController`（可选高层封装）= 持有 region state 的弱引用，对外暴露
  `selectAll / clear / copy / dispatchEvent / registrar / contextMenuButtonItems /
  contextMenuAnchors`。两者择一作为公开 key 类型 —— **推荐直接暴露 State**（见 §2）。

## 2. 公开 API（轻破坏）

`lib/widgets/smooth_markdown.dart`：

```dart
// 类型变更（名称不变）：
final GlobalKey<SmoothSelectionRegionState>? selectableRegionKey;   // 原 SelectableRegionState
final Widget Function(BuildContext, SmoothSelectionRegionState)? contextMenuBuilder;
// bool selectable 不变
```

`SmoothSelectionRegionState` 暴露（对齐原 SelectableRegionState 常用面，便于迁移）：
```dart
void selectAll([SelectionChangedCause cause = SelectionChangedCause.longPress]);
void clearSelection([SelectionChangedCause cause = SelectionChangedCause.tap]);
List<ContextMenuButtonItem> get contextMenuButtonItems;
List<Offset> get contextMenuAnchors;            // 兼容旧 AdaptiveTextSelectionToolbar 调用
String get selectedContent;                      // 用于复制过滤
SelectionRegistrar? get registrar;               // 满足 R2：手动派发 SelectionEvent
void dispatchEvent(SelectionEvent event);        // 遍历 selectables 派发（核心：SelectAllSelectionEvent）
```

迁移指引（README/CHANGELOG）：
- `GlobalKey<SelectableRegionState>` → `GlobalKey<SmoothSelectionRegionState>`
- `contextMenuBuilder` 第二参 → `SmoothSelectionRegionState`
- 其余调用名（`selectAll`、`contextMenuButtonItems`、`contextMenuAnchors`）保持一致。

## 3. 数据流与契约

### 3.1 注册期
1. `SmoothSelectionRegion` build → `SelectionContainer(registrar: this, child: child)`。
2. 子 `Text.rich`（`RenderParagraph`）在 mount 时通过 `SelectionRegistrar.register` 把
   自己注册进 state。state 维护 `List<Selectable>` 有序集合（按布局顺序）。

### 3.2 主动全选（核心修复 R1/AC1）
```
controller.selectAll(cause)
  → state.dispatchSelectAll(cause)
      → for each selectable: selectable.dispatchSelectionEvent(SelectAllSelectionEvent())
      → 计算首尾 selection edge（首个 selectable 的 startHandle + 末个的 endHandle）
      → if cause != toolbar:
            selectionOverlay.showHandles()
            selectionOverlay.showToolbar()   // 关键：主动唤起工具栏
      → notifyListeners()
```
> 这正是用户诉求的「`SelectionContainer` + `SelectAllSelectionEvent`」路径：在
> `SelectionContainer` 提供的 registrar 之上，对全部注册 selectable 派发
> `SelectAllSelectionEvent`，并由我们（而非旧 SelectableRegion）显式控制 overlay 显隐。

### 3.3 工具栏按钮（R4/AC3）
- `contextMenuButtonItems` 由各 selectable 的 `contextMenuButtonItems` 聚合 + 复制按钮
  包一层 `_scheduleClipboardFilter`（沿用 `_removeOverlayLines`）。
- 默认 builder 走 `AdaptiveTextSelectionToolbar.buttonItems`，用户 `contextMenuBuilder`
  可覆盖。

### 3.4 原生手势（R5/AC4）
- 长按 / 拖拽由各 `RenderParagraph` 自身处理，通过 `SelectionRegistrar.pushSelectionStart`
  /`handleSelectionEnd` 等回调上报到 state → state 更新 overlay。该链路与
  `SelectableRegion` 原行为一致，需完整移植（见 §6 风险）。

## 4. 兼容性 / 迁移

- `StreamMarkdown`：把转发的 `contextMenuBuilder` 类型同步改为 `SmoothSelectionRegionState`。
- example `conversation_list_demo.dart`：
  - `_selectionKeys: Map<int, GlobalKey<SmoothSelectionRegionState>>`
  - `_triggerSelectAll` 直接调用 `state.selectAll(SelectionChangedCause.longPress)`，
    删除「找内置按钮 + 双 post-frame」workaround。
  - contextMenuBuilder 的 "选择文字" 按钮调用 `state.selectAll(...)`。
- dartdoc 同步更新示例代码。

## 5. 取舍

| 决策 | 选择 | 代价 |
|---|---|---|
| overlay 管理 | 自实现（移植 `SelectableRegion` 的 overlay 协调） | ~300-500 LOC，需覆盖手柄定位/magnifier/工具栏 anchor/键盘快捷键 |
| selection controls | 默认 material，按平台切 cupertino | 与现状一致 |
| registrar 暴露 | 公开 `registrar` + `dispatchEvent` | 满足 R2，允许用户任意派发 `SelectionEvent` |

## 6. 风险

- **R-1（高）**：自管理 overlay 是对本任务工作量与稳定性影响最大的部分。Flutter 的
  `SelectableRegion` 内部协调多 selectable 的手柄/工具栏并非平凡，移植不当会产生：
  手柄错位、magnifier 抖动、工具栏不消失等回归。
  **缓解**：实现前先建最小复现（见 implement.md step 0），用证据确认问题确实出在
  `SelectableRegion` 而非 cause；若发现保留 `SelectableRegion` 仅改 cause 即可修复，
  将回到 PRD 重新评估范围。
- **R-2（中）**：`SelectionContainer` / `SelectionRegistrar` / `SelectionEvent` 属较低层
  API，Flutter 跨版本可能有调整；需锁定 sdk 下限（当前 `>=3.0.0`），并在 README 注明
  最低支持版本。
- **R-3（中）**：流式 rebuild 期间 selectable 列表变化，`selectAll` 时序需防御性处理
  （空列表/未挂载）。

## 7. 回滚

- 新增文件 `smooth_selection_region.dart` 独立；`smooth_markdown.dart` 改动集中在
  build 末尾的包装与两个字段类型。
- 回滚 = 恢复 `SelectableRegion` 包装 + 还原字段类型；example 文件 git revert。
- 建议在独立 commit 完成「新增 region 文件」「SmoothMarkdown 切换」「example 迁移」
  「测试」四步，便于定位回滚点。
