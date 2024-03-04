import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/utilities/notes/note.dart';

Widget getNotesWidget(
    {required DatabaseNote databaseNote,
    required List<DatabaseNote> notes,
    required TextEditingController notesTextController,
    required BuildContext context,
    required GlobalKey boardKey,
    required Function refresh}) {
  DatabaseNote note =
      notes.where((element) => element.id == databaseNote.id).first;
  return ActivityNote(
    notesTextController: notesTextController,
    onRemove: () {
      refresh(databaseNote);
    },
    onEdit: () async {
      if (note.content is String) {
        notesTextController.text = note.content;
        await showDialog(
            context: context,
            builder: ((context) {
              return AlertDialog(
                title: const Text('Your note'),
                icon: const Icon(Icons.note),
                content: TextField(
                  controller: notesTextController,
                ),
              );
            }));
        note.content = notesTextController.text;

        notesTextController.clear();
      } else if (note.content is Image) {
        final ImagePickerAndroid picker = ImagePickerAndroid();
        final XFile? image = await picker.getImage(source: ImageSource.gallery);

        if (image != null) {
          var oldPath = note.imagePath;
          note.imagePath = image.path;
          note.content = Image.file(File(image.path));

          // ignore: use_build_context_synchronously
          context.read<GameBloc>().add(
                GameEventDeleteImageFromStorage(imagePath: oldPath!),
              );
        }
      }
      refresh(null);
    },
    containerKey: boardKey,
    onDragEnd: (Offset offset) {
      note.positionX = offset.dx;
      note.positionY = offset.dy;
    },
    databaseNote: databaseNote,
    onColorChange: (String colorValue) {
      note.color = colorValue;
    },
  );
}
