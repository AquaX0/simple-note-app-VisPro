import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../models/note.dart';

/// NoteRepository tries to contact a backend at [baseUrl].
/// If network calls fail (for example on web due to CORS / no backend),
/// it falls back to an in-memory list so the app remains usable without
/// creating any persistent database or storage.
class NoteRepository {
  final String baseUrl;
  final List<Note> _inMemory = [];
  int _nextId = 1;
  final http.Client? client;
  final LocalStorageService storage;

  /// [client] can be injected for testing to avoid real network calls.
  NoteRepository({this.baseUrl = 'http://localhost:8080', this.client, LocalStorageService? storage}) : storage = storage ?? LocalStorageService();


  Future<List<Note>> fetchNotes() async {
    try {
  final uri = Uri.parse('$baseUrl/notes');
  final res = client != null ? await client!.get(uri) : await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Note.fromJson(e)).toList();
      }
      // fallthrough to in-memory on non-200
    } catch (e) {
      // network/CORS error — fall back to in-memory
    }
    // If in-memory empty, try loading from storage service
    if (_inMemory.isEmpty) {
      final loaded = await storage.loadNotes();
      if (loaded.isNotEmpty) {
        _inMemory.addAll(loaded);
        // ensure next id is higher than any stored id
        for (var n in _inMemory) {
          if (n.id >= _nextId) _nextId = n.id + 1;
        }
      }
    }
    // return a copy to avoid external mutation
    return List<Note>.from(_inMemory);
  }

  Future<Note> addNote(String title, String body) async {
    try {
      final uri = Uri.parse('$baseUrl/notes');
      final res = client != null
          ? await client!.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'title': title, 'body': body}))
          : await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'title': title, 'body': body}));
      if (res.statusCode == 201) {
        return Note.fromJson(jsonDecode(res.body));
      }
      // fallthrough to local
    } catch (e) {
      // ignore network errors and use local
    }
    final note = Note(id: _nextId++, title: title, body: body);
    _inMemory.add(note);
    await storage.saveNotes(_inMemory);
    return note;
  }

  Future<void> deleteNote(int id) async {
    try {
  final uri = Uri.parse('$baseUrl/notes/$id');
  final res = client != null ? await client!.delete(uri) : await http.delete(uri);
      if (res.statusCode == 204) return;
      // else fall through to in-memory
    } catch (e) {
      // ignore and delete locally
    }
    _inMemory.removeWhere((n) => n.id == id);
    await storage.saveNotes(_inMemory);
  }

  Future<Note> updateNote(int id, String title, String body) async {
    try {
      final uri = Uri.parse('$baseUrl/notes/$id');
      final res = client != null
          ? await client!.patch(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'title': title, 'body': body}))
          : await http.patch(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'title': title, 'body': body}));
      if (res.statusCode == 200) return Note.fromJson(jsonDecode(res.body));
      // else fall through
    } catch (e) {
      // ignore
    }
    final index = _inMemory.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final updated = Note(id: id, title: title, body: body);
      _inMemory[index] = updated;
      await storage.saveNotes(_inMemory);
      return updated;
    }
    // If not present locally, create new stub
    final newNote = Note(id: id == 0 ? _nextId++ : id, title: title, body: body);
    _inMemory.add(newNote);
    await storage.saveNotes(_inMemory);
    return newNote;
  }

  // Local persistence moved to LocalStorageService
}
