import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/repository/note_repository.dart';

class _ThrowingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw Exception('network disabled in tests');
  }
}

void main() {
  group('NoteRepository in-memory fallback', () {
    late NoteRepository repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = NoteRepository(baseUrl: 'http://invalid-host', client: _ThrowingClient()); // force network failure fast
    });

    test('addNote returns note with increasing id', () async {
      final a = await repo.addNote('T1', 'B1');
      final b = await repo.addNote('T2', 'B2');

      expect(a.id, 1);
      expect(b.id, 2);
      final list = await repo.fetchNotes();
      expect(list.length, 2);
    });

    test('deleteNote removes note', () async {
      final note = await repo.addNote('ToDelete', 'x');
      await repo.deleteNote(note.id);
      final list = await repo.fetchNotes();
      expect(list.any((n) => n.id == note.id), false);
    });

    test('updateNote updates existing', () async {
      final note = await repo.addNote('Old', 'old');
      final updated = await repo.updateNote(note.id, 'New', 'new');
      expect(updated.id, note.id);
      expect(updated.title, 'New');
      final list = await repo.fetchNotes();
      expect(list.first.title, 'New');
    });
  });
}
