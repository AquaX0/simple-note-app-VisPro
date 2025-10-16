import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/note_list_page.dart';
import 'package:frontend/bloc/note_bloc.dart';
import 'package:frontend/bloc/note_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/note_repository.dart';

void main() {
  testWidgets('NoteListPage shows notes from bloc', (tester) async {
    final repo = NoteRepository(baseUrl: 'http://invalid-host');

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<NoteBloc>(
        create: (_) => NoteBloc(repo: repo)..add(LoadNotes()),
        child: NoteListPage(),
      ),
    ));

    // initial pump to allow bloc to emit
    await tester.pumpAndSettle();

    // Since repo is in-memory and empty, expect no ListTile
    expect(find.byType(ListTile), findsNothing);

  // Add a note to repository and trigger reload
  await repo.addNote('xyz', 'abc');
  final bloc = BlocProvider.of<NoteBloc>(tester.element(find.byType(NoteListPage)));
  bloc.add(LoadNotes());
    await tester.pumpAndSettle();

    expect(find.text('xyz'), findsOneWidget);
  });
}
