import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        SelectedContent,
        SelectionEdgeUpdateEvent,
        SelectionEvent,
        SelectionHandler,
        SelectionRegistrar,
        SelectionResult,
        TextGranularity;

/// Signature for building the text selection context menu of a
/// [SmoothSelectionRegion].
///
/// Unlike [SelectableRegionContextMenuBuilder], the state passed in is a
/// [SmoothSelectionRegionState], which additionally exposes
/// [SmoothSelectionRegionState.dispatchEvent] and
/// [SmoothSelectionRegionState.registrar] for programmatic control.
typedef SmoothSelectionContextMenuBuilder = Widget Function(
  BuildContext context,
  SmoothSelectionRegionState selectableRegionState,
);

/// A [SelectableRegion]-based selection region that additionally exposes the
/// underlying `SelectionContainer + SelectionEvent` machinery for programmatic
/// control.
///
/// Internally this widget composes a framework [SelectableRegion] (which is
/// itself built on top of a `SelectionContainer`): its state implements
/// [SelectionRegistrar], the `SelectionContainer` in the subtree registers with
/// it as a single selectable, and `SelectableRegionState.selectAll` internally
/// dispatches a `SelectAllSelectionEvent` to that selectable.
///
/// [SmoothSelectionRegion] surfaces that lower-level surface so callers can
/// dispatch *arbitrary* [SelectionEvent]s and reach the registrar directly,
/// without giving up the framework-provided overlay (selection handles,
/// magnifier, toolbar, keyboard shortcuts, gestures).
///
/// Example:
///
/// ```dart
/// final key = GlobalKey<SmoothSelectionRegionState>();
///
/// SmoothMarkdown(
///   data: markdownText,
///   selectable: true,
///   selectableRegionKey: key,
/// )
///
/// // Programmatic select-all (shows handles + toolbar):
/// key.currentState?.selectAll(SelectionChangedCause.toolbar);
///
/// // Lower-level: dispatch an arbitrary SelectionEvent straight to the
/// // SelectionContainer (fans out to every text selectable). Does not, by
/// // itself, drive the overlay.
/// key.currentState?.dispatchEvent(const SelectAllSelectionEvent());
/// ```
/// A wrapper around [SelectableRegion] that additionally exposes the
/// underlying `SelectionContainer + SelectionEvent` machinery for programmatic
/// control.
///
/// Internally this widget composes a framework [SelectableRegion] (which is
/// itself built on top of a `SelectionContainer`): its state implements
class SmoothSelectionRegion extends StatefulWidget {
  /// Creates a [SmoothSelectionRegion].
  ///
  /// Mirrors [SelectableRegion.new], but [contextMenuBuilder] receives a
  /// [SmoothSelectionRegionState] instead of a plain [SelectableRegionState].
  const SmoothSelectionRegion({
    required this.selectionControls,
    required this.child,
    super.key,
    this.focusNode,
    this.magnifierConfiguration = TextMagnifierConfiguration.disabled,
    this.onSelectionChanged,
    this.contextMenuBuilder,
  });

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// The configuration for the magnifier used with selections in this region.
  final TextMagnifierConfiguration magnifierConfiguration;

  /// Called when the selected content changes.
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  /// The delegate to build the selection handles and toolbar for mobile devices.
  final TextSelectionControls selectionControls;

  /// The child widget this selection region applies to.
  final Widget child;

  /// Custom context menu builder. Receives a [SmoothSelectionRegionState].
  final SmoothSelectionContextMenuBuilder? contextMenuBuilder;

  @override
  State<SmoothSelectionRegion> createState() => SmoothSelectionRegionState();
}

/// State for [SmoothSelectionRegion].
///
/// Delegates the standard selection APIs ([selectAll], [clearSelection],
/// [contextMenuButtonItems], [contextMenuAnchors]) to the underlying
/// [SelectableRegionState], so they behave identically. On top of that, it
/// captures the inner `SelectionContainer`'s delegate (a
/// [SelectionHandler] + [SelectionRegistrar]) when the child subtree first
/// builds, and exposes:
///
/// * [dispatchEvent] — forward any [SelectionEvent] (e.g. a
///   `SelectAllSelectionEvent` or `ClearSelectionEvent`) to the contained
///   `SelectionContainer`, which fans it out to every text selectable in the
///   subtree. This is the literal `SelectionContainer + SelectAllSelectionEvent`
///   entry point.
/// * [registrar] — the [SelectionRegistrar] that collects the text selectables
///   in the subtree.
/// * [innerRegionState] — the wrapped [SelectableRegionState], for direct
///   access to the full framework API.
class SmoothSelectionRegionState extends State<SmoothSelectionRegion> {
  final GlobalKey<SelectableRegionState> _regionKey =
      GlobalKey<SelectableRegionState>();

  // The SelectionContainer's delegate (implements both SelectionHandler and
  // SelectionRegistrar). Captured from the child subtree's registrar scope.
  SelectionHandler? _containerHandler;
  SelectionRegistrar? _containerRegistrar;

  @override
  void dispose() {
    // Drop the captured SelectionContainer delegate references so that, if a
    // caller still holds this state after the widget is unmounted, dispatch
    // calls become safe no-ops instead of reaching a detached container.
    _containerHandler = null;
    _containerRegistrar = null;
    super.dispose();
  }

  /// The wrapped [SelectableRegionState]. `null` before first build.
  SelectableRegionState? get innerRegionState => _regionKey.currentState;

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
      key: _regionKey,
      focusNode: widget.focusNode,
      magnifierConfiguration: widget.magnifierConfiguration,
      onSelectionChanged: widget.onSelectionChanged,
      selectionControls: widget.selectionControls,
      contextMenuBuilder: widget.contextMenuBuilder == null
          ? null
          : (BuildContext context, SelectableRegionState state) {
              return widget.contextMenuBuilder!(context, this);
            },
      child: Builder(
        builder: (BuildContext childContext) {
          // SelectionContainer exposes its delegate as the subtree's
          // SelectionRegistrar via SelectionRegistrarScope. Capture both facets.
          final Object? registrar = SelectionContainer.maybeOf(childContext);
          _containerHandler = registrar as SelectionHandler?;
          _containerRegistrar = registrar as SelectionRegistrar?;
          return widget.child;
        },
      ),
    );
  }

  // ─── Programmatic, overlay-driven APIs (delegate to SelectableRegionState) ───

  /// Selects all the content in this region. Shows selection handles and, when
  /// [cause] is [SelectionChangedCause.toolbar], the context toolbar.
  ///
  /// Mirrors [SelectableRegionState.selectAll].
  void selectAll([SelectionChangedCause cause = SelectionChangedCause.toolbar]) {
    innerRegionState?.selectAll(cause);
  }

  /// Selects the content spanning the [granularity] boundary (word or
  /// paragraph) that contains [globalPosition], and shows the selection
  /// handles + context toolbar.
  ///
  /// Shared implementation behind [selectWordAt] and [selectParagraphAt].
  /// SelectableRegionState only exposes [selectAll] as a public overlay-driving
  /// entry point, and once the whole region is selected the granular
  /// `SelectWordSelectionEvent` / `SelectParagraphSelectionEvent` events no
  /// longer narrow it (`SelectWordSelectionEvent` short-circuits because the
  /// press point is "within the current selection"; `SelectParagraphSelectionEvent`
  /// leaves non-pressed paragraphs selected). So this first enters the
  /// selection state via [selectAll] — which creates and shows the overlay —
  /// then narrows the selection by moving both selection edges to
  /// [globalPosition] at [granularity]: the start edge snaps to the boundary
  /// start and the end edge to the boundary end, collapsing the selection to
  /// that single span and clearing the rest. The region rebuilds the
  /// already-visible overlay, repositioning the handles + toolbar.
  ///
  /// [globalPosition] is in global (screen) coordinates — pass the press
  /// position from the gesture that triggered selection (e.g.
  /// `LongPressStartDetails.globalPosition`). Points outside the region's
  /// selectable bounds are handled by the framework (typically no-op), so the
  /// call is always safe.
  void _selectAt(Offset globalPosition, TextGranularity granularity) {
    // Enter the selection state via the only public overlay-driving path:
    // creates and shows the handles + toolbar.
    innerRegionState?.selectAll(SelectionChangedCause.toolbar);
    // Narrow the selection to the pressed boundary by moving both edges to the
    // press position at the requested granularity (start edge → boundary
    // start, end edge → boundary end), so the selection collapses to that
    // single span and the rest is cleared.
    _containerHandler?.dispatchSelectionEvent(
      SelectionEdgeUpdateEvent.forStart(
        globalPosition: globalPosition,
        granularity: granularity,
      ),
    );
    _containerHandler?.dispatchSelectionEvent(
      SelectionEdgeUpdateEvent.forEnd(
        globalPosition: globalPosition,
        granularity: granularity,
      ),
    );
  }

  /// Selects the word at [globalPosition] and shows the selection handles and
  /// context toolbar — the programmatic equivalent of a native long-press at
  /// that point.
  ///
  /// Prefer this over [selectAll] when entering selection mode anchored on the
  /// user's press position (e.g. a long-press menu's "select text" action).
  /// See [_selectAt] for how the overlay is surfaced while narrowing to a
  /// word.
  void selectWordAt(Offset globalPosition) =>
      _selectAt(globalPosition, TextGranularity.word);

  /// Selects the paragraph containing [globalPosition] and shows the selection
  /// handles and context toolbar.
  ///
  /// Prefer this over [selectAll] when entering selection mode anchored on the
  /// user's press position (e.g. a long-press menu's "select text" action).
  /// See [_selectAt] for how the overlay is surfaced while narrowing to a
  /// paragraph.
  void selectParagraphAt(Offset globalPosition) =>
      _selectAt(globalPosition, TextGranularity.paragraph);

  /// Clears the current selection.
  ///
  /// Mirrors [SelectableRegionState.clearSelection].
  void clearSelection() {
    innerRegionState?.clearSelection();
  }

  /// The [ContextMenuButtonItem]s for the platform-default selection menu.
  ///
  /// Mirrors [SelectableRegionState.contextMenuButtonItems].
  List<ContextMenuButtonItem> get contextMenuButtonItems =>
      innerRegionState?.contextMenuButtonItems ?? const <ContextMenuButtonItem>[];

  /// The anchors used to position the text selection toolbar.
  ///
  /// Mirrors [SelectableRegionState.contextMenuAnchors].
  TextSelectionToolbarAnchors get contextMenuAnchors =>
      innerRegionState?.contextMenuAnchors ??
      const TextSelectionToolbarAnchors(primaryAnchor: Offset.zero);

  // ─── Lower-level SelectionContainer entry points ───

  /// Dispatch an arbitrary [SelectionEvent] to the contained
  /// [SelectionContainer]'s delegate.
  ///
  /// The container fans the event out to every registered text selectable in
  /// the subtree. For example, to programmatically select everything *without*
  /// driving the overlay:
  ///
  /// ```dart
  /// state.dispatchEvent(const SelectAllSelectionEvent());
  /// ```
  ///
  /// Note: dispatching an event directly does not, by itself, show or hide the
  /// selection handles/toolbar. Use [selectAll] / [clearSelection] when you
  /// need the overlay to react; use [dispatchEvent] when you want raw fan-out
  /// only. Returns the [SelectionResult] reported by the container (or `null`
  /// if the container has not mounted yet).
  SelectionResult? dispatchEvent(SelectionEvent event) =>
      _containerHandler?.dispatchSelectionEvent(event);

  /// The [SelectionRegistrar] that collects the text selectables in the
  /// subtree (the inner [SelectionContainer]'s delegate). `null` before the
  /// child subtree has built.
  SelectionRegistrar? get registrar => _containerRegistrar;
}
