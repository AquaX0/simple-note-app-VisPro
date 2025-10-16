import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/bloc/note_bloc.dart';
import 'package:frontend/bloc/note_event.dart';
import 'package:frontend/bloc/note_state.dart';
import 'package:frontend/models/note.dart';
import 'package:frontend/repository/note_repository.dart';

class MockRepo extends Mock implements NoteRepository {}

void main() {
  group('NoteBloc', () {
    late MockRepo repo;

    setUp(() {
      repo = MockRepo();
      when(() => repo.fetchNotes()).thenAnswer((_) async => []);
    });

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteLoaded] when LoadNotes is added',
      build: () => NoteBloc(repo: repo),
      act: (b) => b.add(LoadNotes()),
      expect: () => [isA<NoteLoading>(), isA<NoteLoaded>()],
    );

    test('adds new note when AddNoteEvent is called and state was loaded', () async {
      when(() => repo.addNote('a', 'b')).thenAnswer((_) async => Note(id: 1, title: 'a', body: 'b'));
      when(() => repo.fetchNotes()).thenAnswer((_) async => []);

      final bloc = NoteBloc(repo: repo);
      bloc.add(LoadNotes());
      await Future.delayed(Duration.zero);
      bloc.add(AddNoteEvent('a', 'b'));

      // Wait until we observe a NoteLoaded that contains our new note
      final loaded = await bloc.stream.firstWhere((s) => s is NoteLoaded && (s as NoteLoaded).notes.any((n) => n.title == 'a' && n.body == 'b'));
      expect(loaded, isA<NoteLoaded>());
      expect((loaded as NoteLoaded).notes.any((n) => n.title == 'a' && n.body == 'b'), isTrue);
    });
  });
}
