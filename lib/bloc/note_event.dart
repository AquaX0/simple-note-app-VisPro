abstract class NoteEvent {}

class LoadNotes extends NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final String title;
  final String body;
  AddNoteEvent(this.title, this.body);
}

class DeleteNoteEvent extends NoteEvent {
  final int id;
  DeleteNoteEvent(this.id);
}

class UpdateNoteEvent extends NoteEvent {
  final int id;
  final String title;
  final String body;
  UpdateNoteEvent(this.id, this.title, this.body);
}
