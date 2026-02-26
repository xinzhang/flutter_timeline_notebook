import 'package:flutter_test/flutter_test.dart';
import 'package:timeline_notebook/models/note.dart';

void main() {
  group('Note Model', () {
    test('should create note from map', () {
      final map = {
        'id': 1,
        'content': 'Test note',
        'timestamp': 1708867200000,
        'isFavorite': 0,
      };
      final note = Note.fromMap(map);
      expect(note.id, 1);
      expect(note.content, 'Test note');
    });

    test('should convert note to map', () {
      final note = Note(
        id: 1,
        content: 'Test note',
        timestamp: DateTime(2024, 2, 25),
        isFavorite: false,
      );
      final map = note.toMap();
      expect(map['content'], 'Test note');
      expect(map['isFavorite'], 0);
    });
  });
}
