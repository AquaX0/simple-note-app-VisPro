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
      // Optimistic update: add a provisional note immediately
      final provisionalId = -DateTime.now().millisecondsSinceEpoch;
      final provisional = Note(id: provisionalId, title: event.title, body: event.body);
      final currentBefore = List<Note>.from((state as NoteLoaded).notes);
      final optimistic = List<Note>.from(currentBefore)..add(provisional);
      emit(NoteLoaded(optimistic));

      try {
        final newNote = await repo.addNote(event.title, event.body);
        // replace provisional with actual note
        final replaced = (state as NoteLoaded).notes.map((n) => n.id == provisionalId ? newNote : n).toList();
        emit(NoteLoaded(replaced));
      } catch (e) {
        // rollback
        emit(NoteLoaded(currentBefore));
        emit(NoteError(e.toString()));
      }
    }
  }

  Future<void> _onDelete(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    if (state is NoteLoaded) {
      final before = List<Note>.from((state as NoteLoaded).notes);
      final optimistic = List<Note>.from(before)..removeWhere((n) => n.id == event.id);
      emit(NoteLoaded(optimistic));
      try {
        await repo.deleteNote(event.id);
      } catch (e) {
        // rollback
        emit(NoteLoaded(before));
        emit(NoteError(e.toString()));
      }
    }
  }

  Future<void> _onUpdate(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    if (state is NoteLoaded) {
      final before = List<Note>.from((state as NoteLoaded).notes);
      final optimistic = before.map((n) => n.id == event.id ? Note(id: n.id, title: event.title, body: event.body) : n).toList();
      emit(NoteLoaded(optimistic));
      try {
        final updated = await repo.updateNote(event.id, event.title, event.body);
        final replaced = (state as NoteLoaded).notes.map((n) => n.id == event.id ? updated : n).toList();
        emit(NoteLoaded(replaced));
      } catch (e) {
        // rollback
        emit(NoteLoaded(before));
        emit(NoteError(e.toString()));
      }
    }
  }
}
