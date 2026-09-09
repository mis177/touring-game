import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/bloc/notes/notes_bloc.dart';
import 'package:touring_game/services/game/bloc/notes/notes_event.dart';
import 'package:touring_game/services/game/bloc/notes/notes_state.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/media/image_picker_repository.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/dialogs/error_snack_bar.dart';
import 'package:touring_game/utilities/notes/note_to_widget.dart';
import 'package:touring_game/utilities/routes.dart';

class UserNotesBlocProvider extends StatelessWidget {
  const UserNotesBlocProvider({super.key, required this.arguments});

  final UserNotesArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc(context.read<NotesRepository>()),
      child: UserNotes(activity: arguments.activity),
    );
  }
}

class UserNotes extends StatefulWidget {
  const UserNotes({super.key, required this.activity});

  final DatabaseActivity activity;

  @override
  State<UserNotes> createState() => _UserNotesState();
}

class _UserNotesState extends State<UserNotes> {
  late TextEditingController notesTextController;
  List<DatabaseNote> notes = [];
  bool _didLoadNotes = false;

  @override
  void initState() {
    notesTextController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadNotes) {
      return;
    }

    context.read<NotesBloc>().add(NotesLoadRequested(widget.activity.id));
    _didLoadNotes = true;
  }

  @override
  void dispose() {
    notesTextController.dispose();

    super.dispose();
  }

  var boardKey = GlobalKey();

  void deleteNote(DatabaseNote note) {
    context.read<NotesBloc>().add(NoteDeleted(note));
  }

  void updateNote(DatabaseNote previousNote, DatabaseNote updatedNote) {
    context.read<NotesBloc>().add(NoteEdited(previousNote, updatedNote));
  }

  Future<String?> pickImage() async {
    try {
      return await context.read<ImagePickerRepository>().pickFromGallery();
    } on Exception catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error);
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return BlocConsumer<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.exception != null) {
          showErrorSnackBar(context, state.exception!);
        }
      },
      builder: (context, state) {
        List<Widget> widgetList = [];
        notes = state.notes;
        for (var note in notes) {
          widgetList.add(
            getNotesWidget(
              databaseNote: note,
              notes: notes,
              notesTextController: notesTextController,
              context: context,
              boardKey: boardKey,
              onDelete: deleteNote,
              onChanged: updateNote,
              onPickImage: pickImage,
            ),
          );
        }

        return LoadingOverlay(
          isLoading: state.isLoading,
          text: state.loadingText ?? 'Please wait a moment',
          child: Scaffold(
            appBar: AppBar(title: Text(activity.name)),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                key: boardKey,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('lib/images/pin_board.jpg'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(width: 5),
                ),
                child: Stack(children: widgetList),
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final imagePath = await pickImage();

                    if (imagePath != null) {
                      final newNote = DatabaseNote(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        activityId: activity.id,
                        content: '',
                        color: '0xffffeb3b',
                        positionX: -999,
                        positionY: -999,
                        isImage: true,
                        imagePath: imagePath,
                      );
                      if (context.mounted) {
                        context.read<NotesBloc>().add(NoteAdded(newNote));
                      }
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () async {
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
                    if (notesTextController.text.isNotEmpty) {
                      var newNote = DatabaseNote(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        activityId: activity.id,
                        content: notesTextController.text,
                        color: '0xffffeb3b',
                        positionX: -999,
                        positionY: -999,
                        isImage: false,
                        imagePath: null,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      context.read<NotesBloc>().add(NoteAdded(newNote));
                      notesTextController.clear();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
