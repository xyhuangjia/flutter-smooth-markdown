import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectAllSelectionEvent;
import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

const _markdownData = '# Title\n\n'
    'Hello **world** this is selectable text across paragraphs.\n\n'
    'Second paragraph with `inline code` and more content.';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: ListView(children: [child]),
      ),
    );

/// Triggers the Copy button on [regionKey] and returns what was actually
/// selected, captured via a mocked platform clipboard. The region does not
/// expose its selected content publicly, so this is the most faithful way to
/// assert on the real selection.
Future<String?> _copySelected(
  GlobalKey<SmoothSelectionRegionState> regionKey,
  WidgetTester tester,
) =>
    _copySelectedFromItems(
        regionKey.currentState!.contextMenuButtonItems, tester);

Future<String?> _copySelectedFromController(
  SmoothSelectionController controller,
  WidgetTester tester,
) =>
    _copySelectedFromItems(controller.contextMenuButtonItems, tester);

Future<String?> _copySelectedFromItems(
  List<ContextMenuButtonItem> buttonItems,
  WidgetTester tester,
) async {
  String? clip;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        clip = (call.arguments as Map)['text'] as String;
      }
      return null;
    },
  );
  final copy =
      buttonItems.firstWhere((i) => i.type == ContextMenuButtonType.copy);
  copy.onPressed!();
  await tester.pump();
  await tester.pump();
  tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null);
  return clip;
}

void main() {
  group('SmoothSelectionRegion — programmatic selection', () {
    testWidgets(
        'AC1: selectAll(toolbar) shows the selection toolbar with handles',
        (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          key: const ValueKey<String>('md'),
          data: _markdownData,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      expect(regionKey.currentState, isNotNull);
      expect(regionKey.currentState!.innerRegionState, isNotNull,
          reason: 'underlying SelectableRegionState should be attached');

      // Programmatic select-all using the toolbar cause: the framework should
      // summon the selection toolbar.
      regionKey.currentState!.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(TextSelectionToolbar), findsOneWidget,
          reason: 'toolbar should be visible after selectAll(toolbar)');
    });

    testWidgets(
        'AC2: dispatchEvent(SelectAllSelectionEvent) selects all text '
        '(copy button becomes available)', (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      // No selection yet → no copy button.
      expect(
        regionKey.currentState!.contextMenuButtonItems
            .where((i) => i.type == ContextMenuButtonType.copy),
        isEmpty,
        reason: 'nothing should be selected initially',
      );

      // Lower-level: dispatch SelectAllSelectionEvent straight to the
      // SelectionContainer's delegate (the SelectionContainer +
      // SelectAllSelectionEvent path).
      final result = regionKey.currentState!
          .dispatchEvent(const SelectAllSelectionEvent());
      expect(result, isNotNull, reason: 'container delegate should be mounted');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(
        regionKey.currentState!.contextMenuButtonItems
            .where((i) => i.type == ContextMenuButtonType.copy),
        isNotEmpty,
        reason: 'copy button should exist after select-all dispatch',
      );
    });

    testWidgets('registrar is exposed after build', (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      expect(regionKey.currentState!.registrar, isNotNull,
          reason:
              'SelectionContainer delegate should be captured as registrar');
    });

    testWidgets('controller attaches and drives selectAll', (tester) async {
      final controller = SmoothSelectionController();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: true,
          selectionController: controller,
        )),
      );
      await tester.pumpAndSettle();

      expect(controller.isAttached, isTrue);
      expect(controller.currentState, isNotNull);

      controller.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(TextSelectionToolbar), findsOneWidget);
      expect(await _copySelectedFromController(controller, tester),
          contains('Hello world'));
    });

    testWidgets('controller detaches when selection region unmounts',
        (tester) async {
      final controller = SmoothSelectionController();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: true,
          selectionController: controller,
        )),
      );
      await tester.pumpAndSettle();
      expect(controller.isAttached, isTrue);

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: false,
          selectionController: controller,
        )),
      );
      await tester.pumpAndSettle();

      expect(controller.isAttached, isFalse);
      expect(controller.currentState, isNull);
    });

    testWidgets('custom contextMenuBuilder receives SmoothSelectionRegionState',
        (tester) async {
      SmoothSelectionRegionState? captured;
      final regionKey = GlobalKey<SmoothSelectionRegionState>();

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: _markdownData,
          selectable: true,
          selectableRegionKey: regionKey,
          contextMenuBuilder: (context, state) {
            captured = state;
            return const SizedBox.shrink();
          },
        )),
      );
      await tester.pumpAndSettle();

      regionKey.currentState!.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(captured, isNotNull);
      expect(captured, same(regionKey.currentState));
    });

    testWidgets(
        'AC8: selectWordAt selects the word at the press point (not the whole '
        'document) and shows the toolbar + handles', (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();
      const source = 'alpha beta gamma delta epsilon';

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: source,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      // Baseline: selectAll copies the entire document.
      regionKey.currentState!.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(await _copySelected(regionKey, tester), source,
          reason: 'selectAll baseline should copy the whole document');

      // Select the word under the center of the rendered text — like a
      // long-press at that point.
      final center = tester.getCenter(find.byType(RichText).first);
      regionKey.currentState!.selectWordAt(center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Handles + toolbar are shown.
      expect(find.byType(TextSelectionToolbar), findsOneWidget,
          reason: 'toolbar should be visible after selectWordAt');

      // The selection is a single word — strictly shorter than the document
      // and a real token from it (not empty, not the whole thing).
      final wordText = await _copySelected(regionKey, tester);
      expect(wordText, isNotNull, reason: 'a word should be selected');
      expect(wordText!.length, lessThan(source.length),
          reason: 'selectWordAt must select a word, not the whole document');
      expect(source.contains(wordText), isTrue,
          reason: 'selected text must be a token from the source');
    });

    testWidgets(
        'AC9: selectParagraphAt selects the paragraph at the press point (not '
        'the whole document) and shows the toolbar + handles', (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();
      const source = 'alpha beta gamma\n\ndelta epsilon zeta';

      await tester.pumpWidget(
        _wrap(SmoothMarkdown(
          data: source,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      // Baseline: selectAll copies the entire document. Markdown collapses
      // the blank line between paragraphs, so compare by length.
      regionKey.currentState!.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final allText = await _copySelected(regionKey, tester);
      expect(allText, isNotNull,
          reason: 'selectAll baseline should produce content');
      expect(allText!.length, greaterThan(20),
          reason: 'selectAll baseline should copy the whole document');

      // Select the paragraph under the center of the first rendered text —
      // like a long-press "select text" at that point.
      final center = tester.getCenter(find.byType(RichText).first);
      regionKey.currentState!.selectParagraphAt(center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Handles + toolbar are shown.
      expect(find.byType(TextSelectionToolbar), findsOneWidget,
          reason: 'toolbar should be visible after selectParagraphAt');

      // The selection is a single paragraph — strictly shorter than the whole
      // document and a real slice of it (not empty, not the whole thing).
      final paragraphText = await _copySelected(regionKey, tester);
      expect(paragraphText, isNotNull,
          reason: 'a paragraph should be selected');
      expect(paragraphText!.length, lessThan(allText.length),
          reason: 'selectParagraphAt must select a paragraph, not the whole '
              'document');
      expect(allText.contains(paragraphText), isTrue,
          reason: 'selected text must be a slice from the document');
    });

    testWidgets('selectParagraphAt from nearby padding clears selectAll',
        (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();
      const source = 'alpha beta gamma\n\ndelta epsilon zeta';

      await tester.pumpWidget(
        _wrap(Padding(
          padding: const EdgeInsets.all(24),
          child: SmoothMarkdown(
            data: source,
            selectable: true,
            selectableRegionKey: regionKey,
          ),
        )),
      );
      await tester.pumpAndSettle();

      regionKey.currentState!.selectAll(SelectionChangedCause.toolbar);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final allText = await _copySelected(regionKey, tester);
      expect(allText, isNotNull);

      final textTopLeft = tester.getTopLeft(find.byType(RichText).first);
      regionKey.currentState!.selectParagraphAt(
        textTopLeft.translate(4, -8),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(
        regionKey.currentState!.contextMenuButtonItems
            .where((i) => i.type == ContextMenuButtonType.copy),
        isEmpty,
        reason: 'a padding-adjacent press should clear selection instead of '
            'keeping select-all active',
      );
    });
  });

  group('StreamMarkdown — selection passthrough (AC5)', () {
    testWidgets('selectableRegionKey is wired through StreamMarkdown',
        (tester) async {
      final regionKey = GlobalKey<SmoothSelectionRegionState>();
      final controller = StreamController<String>()
        ..add('# Stream\n\nSelectable text via stream.');

      await tester.pumpWidget(
        _wrap(StreamMarkdown(
          stream: controller.stream,
          selectable: true,
          selectableRegionKey: regionKey,
        )),
      );
      await tester.pumpAndSettle();

      expect(regionKey.currentState, isNotNull,
          reason: 'StreamMarkdown should forward selectableRegionKey');

      regionKey.currentState!.dispatchEvent(const SelectAllSelectionEvent());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(
        regionKey.currentState!.contextMenuButtonItems
            .where((i) => i.type == ContextMenuButtonType.copy),
        isNotEmpty,
        reason: 'dispatchEvent should select all streamed text',
      );

      await controller.close();
    });

    testWidgets('selectionController is wired through StreamMarkdown',
        (tester) async {
      final selectionController = SmoothSelectionController();
      final streamController = StreamController<String>()
        ..add('# Stream\n\nSelectable text via stream.');

      await tester.pumpWidget(
        _wrap(StreamMarkdown(
          stream: streamController.stream,
          selectable: true,
          selectionController: selectionController,
        )),
      );
      await tester.pumpAndSettle();

      expect(selectionController.isAttached, isTrue,
          reason: 'StreamMarkdown should forward selectionController');

      selectionController.dispatchEvent(const SelectAllSelectionEvent());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(
        selectionController.contextMenuButtonItems
            .where((i) => i.type == ContextMenuButtonType.copy),
        isNotEmpty,
        reason: 'controller dispatchEvent should select streamed text',
      );

      await streamController.close();
    });
  });

  group('gesture arena — outer long-press wins over SelectableRegion', () {
    // Regression for the chat-bubble pattern where a bubble-level long-press
    // menu must take precedence over SelectableRegion's native word-selection
    // long-press. SelectableRegion's LongPressGestureRecognizer uses the
    // default 500ms deadline; giving the outer a shorter deadline makes it
    // resolve(accepted) first and win the arena.
    testWidgets('shorter outer deadline suppresses inner native selection',
        (tester) async {
      var outerFired = false;
      final regionKey = GlobalKey<SmoothSelectionRegionState>();

      await tester.pumpWidget(
        _wrap(
          RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: <Type, GestureRecognizerFactory>{
              LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                  LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: const Duration(milliseconds: 350),
                ),
                (LongPressGestureRecognizer instance) {
                  instance.onLongPressStart = (_) => outerFired = true;
                },
              ),
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SmoothMarkdown(
                data: _markdownData,
                selectable: true,
                selectableRegionKey: regionKey,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(SmoothMarkdown));
      await tester.pumpAndSettle();

      expect(outerFired, isTrue,
          reason: 'outer long-press should win the arena');
      final innerHasSelection = regionKey.currentState!.contextMenuButtonItems
          .where((i) => i.type == ContextMenuButtonType.copy)
          .isNotEmpty;
      expect(innerHasSelection, isFalse,
          reason: 'inner SelectableRegion must not start native selection');
    });
  });
}
