import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/utilities/notes/note_position.dart';

void main() {
  test('normalizes and restores a note position for a resized board', () {
    final normalized = normalizeNotePosition(
      localPosition: const Offset(50, 25),
      availableSize: const Size(200, 100),
    );

    expect(normalized, const Offset(0.25, 0.25));
    expect(
      resolveNotePosition(
        normalizedPosition: normalized,
        availableSize: const Size(400, 300),
      ),
      const Offset(100, 75),
    );
  });

  test('clamps note positions to the board bounds', () {
    expect(
      normalizeNotePosition(
        localPosition: const Offset(-20, 150),
        availableSize: const Size(100, 100),
      ),
      const Offset(0, 1),
    );
  });

  test('handles a board with no available drag space', () {
    expect(
      normalizeNotePosition(
        localPosition: const Offset(20, 20),
        availableSize: Size.zero,
      ),
      Offset.zero,
    );
  });
}
