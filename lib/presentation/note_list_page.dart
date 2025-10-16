import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../models/note.dart';
import 'note_detail_page.dart';
import 'note_add_page.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<Note> notes = [];
  List<Note> selectedNotes = [];
  bool isSelectionMode = false;

  void deleteSelectedNotes() async {
    for (var note in selectedNotes) {
      context.read<NoteBloc>().add(DeleteNoteEvent(note.id));
    }
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteBloc>().add(LoadNotes());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List'),
        actions: [
          if (!isSelectionMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  isSelectionMode = true;
                  selectedNotes = List.from(notes);
                });
              },
            ),
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteSelectedNotes,
            ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(builder: (context, state) {
        if (state is NoteLoading) return Center(child: CircularProgressIndicator());
        if (state is NoteError) return Center(child: Text('Error: ${state.message}'));
        if (state is NoteLoaded) {
          notes = state.notes;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final n = notes[index];
              return ListTile(
                title: Text(n.title),
                subtitle: Text(n.body),
                onTap: () {
                  if (isSelectionMode) {
                    setState(() {
                      if (selectedNotes.contains(n)) {
                        selectedNotes.remove(n);
                      } else {
                        selectedNotes.add(n);
                      }
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailPage(note: n),
                      ),
                    );
                  }
                },
                leading: isSelectionMode
                    ? Checkbox(
                        value: selectedNotes.contains(n),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedNotes.add(n);
                            } else {
                              selectedNotes.remove(n);
                            }
                          });
                        },
                      )
                    : null,
              );
            },
          );
        }
        return SizedBox.shrink();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteAddPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
