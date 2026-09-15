import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/bloc/notes/notes_event.dart';
import 'package:touring_game/services/game/bloc/notes/notes_state.dart';
import 'package:touring_game/services/game/game_repository.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesState()) {
    on<NotesEvent>(_handleEvent, transformer: sequential());
  }

  final NotesRepository _repository;

  Future<void> _handleEvent(NotesEvent event, Emitter<NotesState> emit) async {
    switch (event) {
      case NotesLoadRequested():
        await _load(event, emit);
      case NoteAdded():
        await _add(event, emit);
      case NoteEdited():
        await _edit(event, emit);
      case NoteMoved():
        await _move(event, emit);
      case NoteDeleted():
        await _delete(event, emit);
    }
  }

  Future<void> _load(NotesLoadRequested event, Emitter<NotesState> emit) async {
    _loading(emit, 'Loading notes');
    try {
      final notes = await _repository.loadNotes(event.activityId);
      emit(NotesState(notes: List.unmodifiable(notes)));
    } on Exception catch (error) {
      _failure(emit, error);
    }
  }

  Future<void> _add(NoteAdded event, Emitter<NotesState> emit) async {
    _loading(emit, 'Saving note');
    try {
      final savedNote = await _repository.saveNote(event.note);
      emit(NotesState(notes: List.unmodifiable([...state.notes, savedNote])));
    } on Exception catch (error) {
      _failure(emit, error);
    }
  }

  Future<void> _edit(NoteEdited event, Emitter<NotesState> emit) async {
    _loading(emit, 'Saving note');
    try {
      final savedNote = await _repository.updateNote(
        event.previousNote,
        event.note,
      );
      emit(
        NotesState(
          notes: List.unmodifiable(
            state.notes.map(
              (note) => note.id == savedNote.id ? savedNote : note,
            ),
          ),
        ),
      );
    } on Exception catch (error) {
      _failure(emit, error);
    }
  }

  Future<void> _move(NoteMoved event, Emitter<NotesState> emit) async {
    final notesBeforeMove = state.notes;
    emit(NotesState(notes: _replaceNote(notesBeforeMove, event.note)));
    try {
      final savedNote = await _repository.updateNote(
        event.previousNote,
        event.note,
      );
      emit(NotesState(notes: _replaceNote(state.notes, savedNote)));
    } on Exception catch (error) {
      emit(NotesState(notes: notesBeforeMove, exception: error));
    }
  }

  Future<void> _delete(NoteDeleted event, Emitter<NotesState> emit) async {
    _loading(emit, 'Deleting note');
    try {
      await _repository.deleteNote(event.note);
      emit(
        NotesState(
          notes: List.unmodifiable(
            state.notes.where((note) => note.id != event.note.id),
          ),
        ),
      );
    } on Exception catch (error) {
      _failure(emit, error);
    }
  }

  void _loading(Emitter<NotesState> emit, String text) {
    emit(NotesState(notes: state.notes, isLoading: true, loadingText: text));
  }

  void _failure(Emitter<NotesState> emit, Exception error) {
    emit(NotesState(notes: state.notes, exception: error));
  }

  List<DatabaseNote> _replaceNote(
    List<DatabaseNote> notes,
    DatabaseNote replacement,
  ) {
    return List.unmodifiable(
      notes.map((note) => note.id == replacement.id ? replacement : note),
    );
  }
}
