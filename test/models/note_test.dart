import 'package:flutter_test/flutter_test.dart';
import 'package:timeline_notebook/models/note.dart';
import 'dart:convert';

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

    test('should serialize imagePaths to JSON string in toMap', () {
      final note = Note(
        id: 1,
        content: 'Test note with images',
        timestamp: DateTime(2024, 2, 25),
        isFavorite: false,
        imagePaths: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
      );
      final map = note.toMap();
      expect(map.containsKey('image_paths'), true);

      final decoded = jsonDecode(map['image_paths']) as List;
      expect(decoded, ['/path/to/image1.jpg', '/path/to/image2.jpg']);
    });

    test('should serialize empty imagePaths list as empty JSON array', () {
      final note = Note(
        id: 1,
        content: 'Test note',
        timestamp: DateTime(2024, 2, 25),
        imagePaths: [],
      );
      final map = note.toMap();
      expect(map['image_paths'], '[]');
    });

    test('should deserialize imagePaths from JSON string in fromMap', () {
      final imagePathsJson = jsonEncode(['/path/to/image1.jpg', '/path/to/image2.jpg']);
      final map = {
        'id': 1,
        'content': 'Test note',
        'timestamp': 1708867200000,
        'isFavorite': 0,
        'image_paths': imagePathsJson,
      };
      final note = Note.fromMap(map);
      expect(note.imagePaths, ['/path/to/image1.jpg', '/path/to/image2.jpg']);
    });

    test('should deserialize empty imagePaths from empty JSON array', () {
      final map = {
        'id': 1,
        'content': 'Test note',
        'timestamp': 1708867200000,
        'isFavorite': 0,
        'image_paths': '[]',
      };
      final note = Note.fromMap(map);
      expect(note.imagePaths, isEmpty);
    });

    test('should default to empty list when image_paths is null in fromMap', () {
      final map = {
        'id': 1,
        'content': 'Test note',
        'timestamp': 1708867200000,
        'isFavorite': 0,
      };
      final note = Note.fromMap(map);
      expect(note.imagePaths, isEmpty);
    });

    test('should round-trip note with imagePaths through toMap and fromMap', () {
      final originalNote = Note(
        id: 1,
        content: 'Test note',
        timestamp: DateTime(2024, 2, 25),
        isFavorite: true,
        imagePaths: ['/path/1.jpg', '/path/2.jpg', '/path/3.jpg'],
      );

      final map = originalNote.toMap();
      final restoredNote = Note.fromMap(map);

      expect(restoredNote.id, originalNote.id);
      expect(restoredNote.content, originalNote.content);
      expect(restoredNote.isFavorite, originalNote.isFavorite);
      expect(restoredNote.imagePaths, originalNote.imagePaths);
      expect(restoredNote.timestamp, originalNote.timestamp);
    });
  });
}
