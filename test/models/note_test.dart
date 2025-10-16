import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/note.dart';

void main() {
  test('Note toJson and fromJson roundtrip', () {
    final note = Note(id: 42, title: 'Hello', body: 'World');
    final json = note.toJson();

    expect(json['ID'], 42);
    expect(json['title'], 'Hello');
    expect(json['body'], 'World');

    final from = Note.fromJson({'id': 42, 'title': 'Hello', 'body': 'World'});
    expect(from.id, 42);
    expect(from.title, 'Hello');
    expect(from.body, 'World');
  });
}
