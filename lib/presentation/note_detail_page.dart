import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import 'note_edit_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;
  NoteDetailPage({required this.note});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteLoaded) {
          final exists = state.notes.any((n) => n.id == note.id);
          if (!exists) {
            // Note was deleted elsewhere; close detail view.
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        }
      },
      child: BlocBuilder<NoteBloc, NoteState>(builder: (context, state) {
        Note? current = note;
        if (state is NoteLoaded) {
          try {
            current = state.notes.firstWhere((n) => n.id == note.id);
          } catch (e) {
            current = null;
          }
        }

        if (current == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Note Detail')),
            body: Center(child: Text('Note not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Note Detail'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  final bloc = BlocProvider.of<NoteBloc>(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: NoteEditPage(note: current!),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.title,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(current.body),
              ],
            ),
          ),
        );
      }),
    );
  }
}
