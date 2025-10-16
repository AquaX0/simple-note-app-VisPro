import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;

final _dataFile = File(p.join(Directory.current.path, 'notes.json'));
List<Map<String, dynamic>> _notes = [];

Future<void> _load() async {
  if (await _dataFile.exists()) {
    final content = await _dataFile.readAsString();
    try {
      final data = jsonDecode(content) as List<dynamic>;
      _notes = data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      _notes = [];
    }
  } else {
    _notes = [];
  }
}

Future<void> _save() async {
  await _dataFile.writeAsString(jsonEncode(_notes));
}

void main(List<String> args) async {
  await _load();

  final router = Router();

  router.get('/notes', (Request req) => Response.ok(jsonEncode(_notes), headers: {'Content-Type': 'application/json'}));

  router.post('/notes', (Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final id = _notes.isEmpty ? 1 : (_notes.map((e) => e['ID'] as int).reduce((a, b) => a > b ? a : b) + 1);
    final note = {'ID': id, 'title': data['title'] ?? '', 'body': data['body'] ?? ''};
    _notes.add(note);
    await _save();
    return Response(201, body: jsonEncode(note), headers: {'Content-Type': 'application/json'});
  });

  router.patch('/notes/<id|[0-9]+>', (Request req, String id) async {
    final idx = _notes.indexWhere((n) => n['ID'].toString() == id);
    if (idx == -1) return Response.notFound('Not found');
    final body = await req.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    _notes[idx]['title'] = data['title'] ?? _notes[idx]['title'];
    _notes[idx]['body'] = data['body'] ?? _notes[idx]['body'];
    await _save();
    return Response.ok(jsonEncode(_notes[idx]), headers: {'Content-Type': 'application/json'});
  });

  router.delete('/notes/<id|[0-9]+>', (Request req, String id) async {
    final idx = _notes.indexWhere((n) => n['ID'].toString() == id);
    if (idx == -1) return Response.notFound('Not found');
    _notes.removeAt(idx);
    await _save();
    return Response(204);
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on http://${server.address.host}:${server.port}');
}
