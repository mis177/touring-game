import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/game/bloc/notes/notes_bloc.dart';
import 'package:touring_game/services/game/bloc/notes/notes_event.dart';

import '../helpers/fake_game_repository.dart';

void main() {
  const note = DatabaseNote(
    id: 'note',
    activityId: 'activity',
    content: 'Original',
    color: '0xffffeb3b',
    positionX: 1,
    positionY: 2,
    isImage: false,
    imagePath: null,
  );

  test('failed edit keeps the persisted note visible', () async {
    final failure = Exception('save failed');
    final bloc = NotesBloc(
      FakeGameRepository(notes: const [note], saveError: failure),
    );

    bloc.add(const NotesLoadRequested('activity'));
    await bloc.stream.firstWhere((state) => state.notes.isNotEmpty);
    bloc.add(NoteEdited(note, note.copyWith(content: 'Changed')));
    final state = await bloc.stream.firstWhere(
      (state) => state.exception != null,
    );

    expect(state.notes, const [note]);
    expect(state.exception, same(failure));
    await bloc.close();
  });

  test('writes are processed sequentially in user-action order', () async {
    final repository = FakeGameRepository(controlledSaves: true);
    final bloc = NotesBloc(repository);
    final edited = note.copyWith(content: 'Changed');

    bloc.add(const NoteAdded(note));
    bloc.add(NoteEdited(note, edited));
    await Future<void>.delayed(Duration.zero);
    expect(repository.savedNotes, const [note]);

    repository.saveCompleters.first.complete();
    await Future<void>.delayed(Duration.zero);
    expect(repository.savedNotes, [note, edited]);
    repository.saveCompleters.last.complete();
    await bloc.stream.firstWhere(
      (state) => state.notes.length == 1 && state.notes.single == edited,
    );

    await bloc.close();
  });

  test('moving a note persists optimistically without loading state', () async {
    final repository = FakeGameRepository(
      notes: const [note],
      controlledSaves: true,
    );
    final bloc = NotesBloc(repository);
    final moved = note.copyWith(positionX: 0.5, positionY: 0.75);

    bloc.add(const NotesLoadRequested('activity'));
    await bloc.stream.firstWhere((state) => state.notes.isNotEmpty);
    bloc.add(NoteMoved(note, moved));
    final optimisticState = await bloc.stream.firstWhere(
      (state) => state.notes.single == moved,
    );

    expect(optimisticState.isLoading, isFalse);
    expect(repository.savedNotes, [moved]);

    repository.saveCompleters.single.complete();
    await bloc.close();
  });

  test('failed note move rolls back its optimistic position', () async {
    final failure = Exception('save failed');
    final bloc = NotesBloc(
      FakeGameRepository(notes: const [note], saveError: failure),
    );
    final moved = note.copyWith(positionX: 0.5, positionY: 0.75);

    bloc.add(const NotesLoadRequested('activity'));
    await bloc.stream.firstWhere((state) => state.notes.isNotEmpty);
    bloc.add(NoteMoved(note, moved));
    final failureState = await bloc.stream.firstWhere(
      (state) => state.exception != null,
    );

    expect(failureState.isLoading, isFalse);
    expect(failureState.notes, const [note]);
    expect(failureState.exception, same(failure));
    await bloc.close();
  });
}
