import 'package:bloc/bloc.dart';
import 'note_event.dart';
import 'note_state.dart';
import '../repository/note_repository.dart';
import '../models/note.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repo;
  NoteBloc({required this.repo}) : super(NoteInitial()) {
    on<LoadNotes>(_onLoad);
    on<AddNoteEvent>(_onAdd);
    on<DeleteNoteEvent>(_onDelete);
    on<UpdateNoteEvent>(_onUpdate);
  }

  Future<void> _onLoad(LoadNotes event, Emitter<NoteState> emit) async {
    try {
      emit(NoteLoading());
      final notes = await repo.fetchNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onAdd(AddNoteEvent event, Emitter<NoteState> emit) async {
    if (state is NoteLoaded) {
      try {
        final newNote = await repo.addNote(event.title, event.body);
        final current = List<Note>.from((state as NoteLoaded).notes)..add(newNote);
        emit(NoteLoaded(current));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    }
  }

  Future<void> _onDelete(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    if (state is NoteLoaded) {
      try {
        await repo.deleteNote(event.id);
        final current = List<Note>.from((state as NoteLoaded).notes)
          ..removeWhere((n) => n.id == event.id);
        emit(NoteLoaded(current));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    }
  }

  Future<void> _onUpdate(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    if (state is NoteLoaded) {
      try {
        final updated = await repo.updateNote(event.id, event.title, event.body);
        final current = (state as NoteLoaded).notes.map((n) => n.id == event.id ? updated : n).toList();
        emit(NoteLoaded(current));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    }
  }
}
