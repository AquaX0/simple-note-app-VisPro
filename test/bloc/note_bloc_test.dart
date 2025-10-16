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

    blocTest<NoteBloc, NoteState>(
      'adds new note when AddNoteEvent is called and state was loaded',
      build: () {
        when(() => repo.addNote('a', 'b')).thenAnswer((_) async => Note(id: 1, title: 'a', body: 'b'));
        // initial fetch returns empty list
        when(() => repo.fetchNotes()).thenAnswer((_) async => []);
        return NoteBloc(repo: repo);
      },
      act: (b) async {
        b.add(LoadNotes());
        await Future.delayed(Duration.zero);
        b.add(AddNoteEvent('a', 'b'));
      },
      expect: () => [isA<NoteLoading>(), isA<NoteLoaded>(), isA<NoteLoaded>()],
    );
  });
}
