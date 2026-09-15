import 'package:equatable/equatable.dart';
import 'package:touring_game/models/note.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => const [];
}

final class NotesLoadRequested extends NotesEvent {
  const NotesLoadRequested(this.activityId);

  final String activityId;

  @override
  List<Object?> get props => [activityId];
}

final class NoteAdded extends NotesEvent {
  const NoteAdded(this.note);

  final DatabaseNote note;

  @override
  List<Object?> get props => [note];
}

final class NoteEdited extends NotesEvent {
  const NoteEdited(this.previousNote, this.note);

  final DatabaseNote previousNote;
  final DatabaseNote note;

  @override
  List<Object?> get props => [previousNote, note];
}

final class NoteMoved extends NotesEvent {
  const NoteMoved(this.previousNote, this.note);

  final DatabaseNote previousNote;
  final DatabaseNote note;

  @override
  List<Object?> get props => [previousNote, note];
}

final class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.note);

  final DatabaseNote note;

  @override
  List<Object?> get props => [note];
}
