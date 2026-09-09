import 'package:equatable/equatable.dart';
import 'package:touring_game/models/note.dart';

class NotesState extends Equatable {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.loadingText,
    this.exception,
  });

  final List<DatabaseNote> notes;
  final bool isLoading;
  final String? loadingText;
  final Exception? exception;

  @override
  List<Object?> get props => [notes, isLoading, loadingText, exception];
}
