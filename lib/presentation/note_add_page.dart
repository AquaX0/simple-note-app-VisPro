import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../repository/note_repository.dart';

class NoteAddPage extends StatefulWidget {
  final NoteBloc? noteBloc;
  NoteAddPage({Key? key, this.noteBloc}) : super(key: key);

  @override
  _NoteAddPageState createState() => _NoteAddPageState();
}

class _NoteAddPageState extends State<NoteAddPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Note')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            SizedBox(height: 10),
            TextField(controller: _bodyController, decoration: InputDecoration(labelText: 'Content'), maxLines: null),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text;
                final body = _bodyController.text;

                // Prefer dispatching to the bloc if available. If not, fall back to repository.
                // Prefer injected bloc (passed via constructor) to avoid provider scope issues.
                final injected = widget.noteBloc;
                if (injected != null) {
                  injected.add(AddNoteEvent(title, body));
                } else {
                  NoteBloc? bloc;
                  try {
                    bloc = BlocProvider.of<NoteBloc>(context);
                  } catch (_) {
                    bloc = null;
                  }

                  if (bloc != null) {
                    bloc.add(AddNoteEvent(title, body));
                  } else {
                  // Fallback: use repository directly so saving still works.
                  try {
                    final repo = RepositoryProvider.of<NoteRepository>(context);
                    await repo.addNote(title, body);
                  } catch (e) {
                    // ignore: no-op fallback failure
                  }
                  }
                }

                Navigator.pop(context);
              },
              child: Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
