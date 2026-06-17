# Step 0 Evidence Gate — 结论

## 方法
临时 widget test（已删除）在 ListView 场景下，对 `SmoothMarkdown(selectable:true,
selectableRegionKey:k)` 注入不同触发方式，断言 `TextSelectionToolbar` 是否出现。

## 结果矩阵

| 触发方式 | TextSelectionToolbar | 结论 |
|---|---|---|
| `state.selectAll(SelectionChangedCause.toolbar)` 直调 | **1（出现）** ✅ | 有效 |
| `state.selectAll(SelectionChangedCause.longPress)` 直调 | 0 | 无工具栏 |
| `state.selectAll(SelectionChangedCause.tap)` 直调 | 0 | 无工具栏 |
| `state.selectAll(SelectionChangedCause.keyboard)` 直调 | 0 | 无工具栏 |
| **示例现有流程**：双层 post-frame + 找 selectAll 按钮 onPressed | **0（不出现）** ❌ | 失败 |
| 手动 `tester.longPress(Text)` | 0 | 测试环境未触发（hit 问题，非结论性） |

## 关键诊断

1. **示例的 `_triggerSelectAll` 是坏的**：它在「尚无任何选区」时去
   `state.contextMenuButtonItems` 里找 `selectAll` 按钮 —— 但此时没有任何选区，
   `contextMenuButtonItems` 为空/无效，`onPressed` 不产生效果。这是手柄/工具栏
   「不出现」的直接原因，与 SelectableRegion 的能力无关。
2. **SelectableRegion 本身完全满足需求**：直接 `selectAll(SelectionChangedCause.toolbar)`
   就能让工具栏出现（test 已断言 `findsOneWidget`）。`cause=toolbar` 不会隐藏工具栏——
   这推翻了 design.md D2 里我早先的假设。
3. 早期我的诊断（"cause=toolbar 会隐藏工具栏"）被证据**证伪**。

## 对原计划的影响

- 用户选择 `SelectionContainer` 重写的依据是「现有方案无法满足需求」。但证据表明
  现有方案（SelectableRegion）只需**把示例的 `_triggerSelectAll` 换成直调
  `selectAll(SelectionChangedCause.toolbar)`** 即可满足「手柄+工具栏出现」。
- 自管理 overlay 的重写（~300-500 LOC）很可能**不必要**。

## 建议回到用户决策点

向用户汇报证据，提供两条路径：
- **A（推荐）**：放弃重写，把任务缩为「修复 example `_triggerSelectAll` + 补一个
  `selectAll` 直调的 widget test + dartdoc 示例更正」。工作量 < 30 分钟，零 API 破坏。
- **B**：仍按原计划做 SelectionContainer 重写（用户坚持）。但需告知证据显示 SelectableRegion
  并非瓶颈，重写收益主要是「可控的 registrar/dispatchEvent 能力」而非修复 bug。
