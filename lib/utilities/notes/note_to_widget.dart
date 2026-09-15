import 'package:flutter/material.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/utilities/notes/note.dart';

Widget getNotesWidget({
  required DatabaseNote databaseNote,
  required List<DatabaseNote> notes,
  required TextEditingController notesTextController,
  required BuildContext context,
  required GlobalKey boardKey,
  required ValueChanged<DatabaseNote> onDelete,
  required void Function(DatabaseNote previous, DatabaseNote updated) onChanged,
  void Function(DatabaseNote previous, DatabaseNote updated)? onMoved,
  required Future<String?> Function() onPickImage,
}) {
  DatabaseNote note = notes
      .where((element) => element.id == databaseNote.id)
      .first;

  void updateNote(DatabaseNote updatedNote) {
    final previousNote = note;
    note = updatedNote;
    onChanged(previousNote, updatedNote);
  }

  return ActivityNote(
    key: ValueKey(databaseNote.id),
    onRemove: () {
      onDelete(databaseNote);
    },
    onEdit: () async {
      if (!note.isImage) {
        notesTextController.text = note.content;
        await showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: const Text('Your note'),
              icon: const Icon(Icons.note),
              content: TextField(controller: notesTextController),
            );
          }),
        );
        updateNote(note.copyWith(content: notesTextController.text));
        notesTextController.clear();
      } else {
        final imagePath = await onPickImage();

        if (imagePath != null) {
          updateNote(note.copyWith(imagePath: imagePath, imageUrl: null));
        }
      }
    },
    containerKey: boardKey,
    onDragEnd: (Offset offset) {
      final previousNote = note;
      note = note.copyWith(positionX: offset.dx, positionY: offset.dy);
      (onMoved ?? onChanged)(previousNote, note);
    },
    databaseNote: databaseNote,
    onColorChange: (String colorValue) {
      updateNote(note.copyWith(color: colorValue));
    },
  );
}
