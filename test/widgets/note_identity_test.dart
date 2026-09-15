import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/utilities/notes/note_to_widget.dart';

void main() {
  testWidgets('deleting a note preserves the remaining note state', (
    tester,
  ) async {
    final boardKey = GlobalKey();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final first = _note(id: 'first', positionX: 0.1, color: Colors.yellow);
    final second = _note(id: 'second', positionX: 0.8, color: Colors.blue);

    await tester.pumpWidget(
      _NotesBoard(
        notes: [first, second],
        boardKey: boardKey,
        controller: controller,
      ),
    );
    await tester.pump();
    final originalPosition = _positionOf(tester, 'second');

    await tester.pumpWidget(
      _NotesBoard(notes: [second], boardKey: boardKey, controller: controller),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('first')), findsNothing);
    expect(_positionOf(tester, 'second'), originalPosition);
    expect(_colorOf(tester, 'second')?.toARGB32(), Colors.blue.toARGB32());
  });

  testWidgets('persisted note changes replace rendered position and color', (
    tester,
  ) async {
    final boardKey = GlobalKey();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final note = _note(id: 'note', positionX: 0.2, color: Colors.yellow);

    await tester.pumpWidget(
      _NotesBoard(notes: [note], boardKey: boardKey, controller: controller),
    );
    await tester.pump();
    final originalPosition = _positionOf(tester, 'note');

    await tester.pumpWidget(
      _NotesBoard(
        notes: [
          note.copyWith(
            positionX: 0.9,
            color: Colors.green.toARGB32().toString(),
          ),
        ],
        boardKey: boardKey,
        controller: controller,
      ),
    );
    await tester.pump();

    expect(_positionOf(tester, 'note'), isNot(originalPosition));
    expect(_colorOf(tester, 'note')?.toARGB32(), Colors.green.toARGB32());
  });

  testWidgets('long-press opens the standard anchored note menu', (
    tester,
  ) async {
    final boardKey = GlobalKey();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final note = _note(id: 'note', positionX: 0.2, color: Colors.yellow);

    await tester.pumpWidget(
      _NotesBoard(notes: [note], boardKey: boardKey, controller: controller),
    );
    await tester.pump();
    final menuButton = find.byIcon(Icons.more_vert);
    expect(menuButton, findsOneWidget);
    final buttonRect = tester.getRect(menuButton);

    await tester.longPress(find.text('note'));
    await tester.pumpAndSettle();

    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Color')).dy,
      greaterThan(buttonRect.top),
    );
  });
}

DatabaseNote _note({
  required String id,
  required double positionX,
  required Color color,
}) {
  return DatabaseNote(
    id: id,
    activityId: 'activity',
    content: id,
    color: color.toARGB32().toString(),
    positionX: positionX,
    positionY: positionX,
    isImage: false,
    imagePath: null,
  );
}

Offset _positionOf(WidgetTester tester, String noteId) {
  final positioned = tester.widget<Positioned>(
    find.descendant(
      of: find.byKey(ValueKey(noteId)),
      matching: find.byWidgetPredicate(
        (widget) => widget is Positioned && widget.left != null,
      ),
    ),
  );
  return Offset(positioned.left!, positioned.top!);
}

Color? _colorOf(WidgetTester tester, String noteId) {
  final containers = tester.widgetList<Container>(
    find.descendant(
      of: find.byKey(ValueKey(noteId)),
      matching: find.byType(Container),
    ),
  );
  return containers.singleWhere((container) => container.color != null).color;
}

class _NotesBoard extends StatelessWidget {
  const _NotesBoard({
    required this.notes,
    required this.boardKey,
    required this.controller,
  });

  final List<DatabaseNote> notes;
  final GlobalKey boardKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => SizedBox(
              width: 400,
              height: 400,
              child: Container(
                key: boardKey,
                child: Stack(
                  children: notes
                      .map(
                        (note) => getNotesWidget(
                          databaseNote: note,
                          notes: notes,
                          notesTextController: controller,
                          context: context,
                          boardKey: boardKey,
                          onDelete: (_) {},
                          onChanged: (_, _) {},
                          onPickImage: () async => null,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
