import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/note_repository.dart';
import 'bloc/note_bloc.dart';
import 'bloc/note_event.dart';
import 'presentation/note_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RepositoryProvider(
        create: (_) => NoteRepository(),
        child: BlocProvider(
          create: (context) => NoteBloc(repo: context.read<NoteRepository>())..add(LoadNotes()),
          child: NoteListPage(),
        ),
      ),
    );
  }
}
