import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uas/widgets/product_card.dart';

void main() {
  test('buildHighlightedTextSpan highlights substring and preserves case', () {
    final normal = const TextStyle(color: Colors.black);
    final highlight = const TextStyle(backgroundColor: Colors.yellow);

    final span = buildHighlightedTextSpan(
      'Kaos Vintage',
      'vint',
      normal,
      highlight,
    );

    // Should be a TextSpan containing multiple children where one has highlight background
    final children = span.children ?? <InlineSpan>[span];
    final hasHighlight = children.any((c) {
      if (c is TextSpan) {
        return c.style?.backgroundColor == highlight.backgroundColor &&
            c.toPlainText().toLowerCase().contains('vint');
      }
      return false;
    });

    expect(hasHighlight, true);
  });

  test('empty query returns full text in normal style', () {
    final normal = const TextStyle(color: Colors.black);
    final highlight = const TextStyle(backgroundColor: Colors.yellow);

    final span = buildHighlightedTextSpan(
      'Kaos Vintage',
      '',
      normal,
      highlight,
    );
    expect(span.toPlainText(), 'Kaos Vintage');
    expect(span.style, normal);
  });
}
