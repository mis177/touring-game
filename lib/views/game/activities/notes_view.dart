import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/bloc/game_bloc.dart';
import 'package:touring_game/services/game/bloc/game_event.dart';
import 'package:touring_game/services/game/bloc/game_state.dart';
import 'package:touring_game/services/game/game_provider.dart';
import 'package:touring_game/services/game/game_service.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/notes/note.dart';

class UserNotesBlocProvider extends StatelessWidget {
  const UserNotesBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
          FirebaseCloudGameService(provider: FirebaseCloudGameProvider())),
      child: const UserNotes(),
    );
  }
}

class UserNotes extends StatefulWidget {
  const UserNotes({super.key});

  @override
  State<UserNotes> createState() => _UserNotesState();
}

class _UserNotesState extends State<UserNotes> {
  late TextEditingController notesTextController;
  List<DatabaseNote> notes = [];

  List<GlobalKey<State<StatefulWidget>>> globalKeys = [];

  final String imagePathPrefix = 'dggf.;hb,fghdfpsdf;';

  @override
  void initState() {
    notesTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    notesTextController.dispose();

    super.dispose();
  }

  var boardKey = GlobalKey();
  Widget getNotesWidget(
    DatabaseNote databaseNote,
  ) {
    DatabaseNote note =
        notes.where((element) => element.id == databaseNote.id).first;
    return ActivityNote(
      notesTextController: notesTextController,
      onRemove: () {
        setState(() {
          notes.remove(databaseNote);
        });
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
          final XFile? image =
              await picker.getImage(source: ImageSource.gallery);

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
        setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final argumentList = ModalRoute.of(context)!.settings.arguments as List;
    final activity = argumentList[0] as DatabaseActivity;
    context.read<GameBloc>().add(
          GameEventLoadNotes(activityId: activity.id),
        );

    return PopScope(
      onPopInvoked: (value) {
        context.read<GameBloc>().add(
              GameEventUpdateNotes(databaseNotes: notes),
            );
      },
      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingScreen().show(
                context: context,
                text: state.loadingText ?? 'Please wait a moment');
          } else {
            LoadingScreen().hide();
          }
        },
        builder: (context, state) {
          List<Widget> widgetList = [];
          if (state is GameStateLoadedNotes) {
            notes = state.activityNotes;
            for (var note in notes) {
              widgetList.add(getNotesWidget(note));
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              backgroundColor: Colors.grey[300],
              title: Text(activity.name),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                  key: boardKey,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage(
                          'lib/images/pin_board.jpg',
                        ),
                        fit: BoxFit.cover),
                    border: Border.all(width: 5, color: Colors.black54),
                  ),
                  child: Stack(
                    children: widgetList,
                  )),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final ImagePickerAndroid picker = ImagePickerAndroid();
                    final XFile? image =
                        await picker.getImage(source: ImageSource.gallery);

                    if (image != null) {
                      setState(() {
                        var newNote = DatabaseNote(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          activityId: activity.id,
                          content: Image.file(File(image.path)),
                          color: '0xffffeb3b',
                          positionX: -999,
                          positionY: -999,
                          isImage: true,
                          imagePath: image.path,
                        );
                        setState(() {
                          context.read<GameBloc>().add(
                                GameEventAddNote(databaseNote: newNote),
                              );
                        });
                      });
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
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
                    if (notesTextController.text.isNotEmpty) {
                      var newNote = DatabaseNote(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        activityId: activity.id,
                        content: notesTextController.text,
                        color: '0xffffeb3b',
                        positionX: -999,
                        positionY: -999,
                        isImage: false,
                        imagePath: null,
                      );
                      setState(() {
                        context.read<GameBloc>().add(
                              GameEventAddNote(databaseNote: newNote),
                            );
                        notesTextController.clear();
                      });
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
