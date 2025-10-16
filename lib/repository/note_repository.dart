import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

/// NoteRepository tries to contact a backend at [baseUrl].
/// If network calls fail (for example on web due to CORS / no backend),
/// it falls back to an in-memory list so the app remains usable without
/// creating any persistent database or storage.
class NoteRepository {
  final String baseUrl;
  final List<Note> _inMemory = [];
  int _nextId = 1;

  NoteRepository({this.baseUrl = 'http://localhost:8080'});

  Future<List<Note>> fetchNotes() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/notes'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Note.fromJson(e)).toList();
      }
      // fallthrough to in-memory on non-200
    } catch (e) {
      // network/CORS error — fall back to in-memory
    }
    // return a copy to avoid external mutation
    return List<Note>.from(_inMemory);
  }

  Future<Note> addNote(String title, String body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (res.statusCode == 201) {
        return Note.fromJson(jsonDecode(res.body));
      }
      // fallthrough to local
    } catch (e) {
      // ignore network errors and use local
    }
    final note = Note(id: _nextId++, title: title, body: body);
    _inMemory.add(note);
    return note;
  }

  Future<void> deleteNote(int id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/notes/$id'));
      if (res.statusCode == 204) return;
      // else fall through to in-memory
    } catch (e) {
      // ignore and delete locally
    }
    _inMemory.removeWhere((n) => n.id == id);
  }

  Future<Note> updateNote(int id, String title, String body) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (res.statusCode == 200) return Note.fromJson(jsonDecode(res.body));
      // else fall through
    } catch (e) {
      // ignore
    }
    final index = _inMemory.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final updated = Note(id: id, title: title, body: body);
      _inMemory[index] = updated;
      return updated;
    }
    // If not present locally, create new stub
    final newNote = Note(id: id == 0 ? _nextId++ : id, title: title, body: body);
    _inMemory.add(newNote);
    return newNote;
  }
}
