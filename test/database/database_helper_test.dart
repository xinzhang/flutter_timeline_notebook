import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timeline_notebook/database/database_helper.dart';
import 'package:timeline_notebook/models/note.dart';
import 'package:timeline_notebook/models/tag.dart';

void main() {
  // Setup FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper CRUD Operations', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Create a new test-specific DatabaseHelper instance for each test
      dbHelper = DatabaseHelper.forTest();
      await dbHelper.database;
    });

    tearDown(() async {
      // Close the database after each test
      await dbHelper.close();
    });

    test('should create a note and retrieve it', () async {
      final note = Note(
        content: 'Test note content',
        timestamp: DateTime(2024, 2, 25),
        isFavorite: false,
      );

      final id = await dbHelper.createNote(note);
      expect(id, greaterThan(0));

      final notes = await dbHelper.getAllNotes();
      expect(notes.length, 1);
      expect(notes.first.content, 'Test note content');
      expect(notes.first.isFavorite, false);
    });

    test('should create note with images and persist imagePaths', () async {
      final note = Note(
        content: 'Note with images',
        timestamp: DateTime(2024, 2, 25),
        imagePaths: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
      );

      final id = await dbHelper.createNote(note);
      final notes = await dbHelper.getAllNotes();

      expect(notes.length, 1);
      expect(notes.first.imagePaths, ['/path/to/image1.jpg', '/path/to/image2.jpg']);
    });

    test('should retrieve all notes ordered by timestamp descending', () async {
      final now = DateTime(2024, 2, 25);
      await dbHelper.createNote(Note(
        content: 'First note',
        timestamp: now,
      ));
      await dbHelper.createNote(Note(
        content: 'Second note',
        timestamp: now.add(Duration(hours: 1)),
      ));
      await dbHelper.createNote(Note(
        content: 'Third note',
        timestamp: now.subtract(Duration(hours: 1)),
      ));

      final notes = await dbHelper.getAllNotes();
      expect(notes.length, 3);
      expect(notes[0].content, 'Second note');
      expect(notes[1].content, 'First note');
      expect(notes[2].content, 'Third note');
    });

    test('should update an existing note', () async {
      final note = Note(
        content: 'Original content',
        timestamp: DateTime(2024, 2, 25),
      );

      final id = await dbHelper.createNote(note);
      final updatedNote = note.copyWith(
        id: id,
        content: 'Updated content',
        isFavorite: true,
      );

      final rowsAffected = await dbHelper.updateNote(updatedNote);
      expect(rowsAffected, 1);

      final notes = await dbHelper.getAllNotes();
      expect(notes.length, 1);
      expect(notes.first.content, 'Updated content');
      expect(notes.first.isFavorite, true);
    });

    test('should update note with imagePaths', () async {
      final note = Note(
        content: 'Note',
        timestamp: DateTime(2024, 2, 25),
        imagePaths: ['/path/1.jpg'],
      );

      final id = await dbHelper.createNote(note);
      final updatedNote = note.copyWith(
        id: id,
        imagePaths: ['/path/1.jpg', '/path/2.jpg', '/path/3.jpg'],
      );

      await dbHelper.updateNote(updatedNote);
      final notes = await dbHelper.getAllNotes();

      expect(notes.first.imagePaths.length, 3);
      expect(notes.first.imagePaths, ['/path/1.jpg', '/path/2.jpg', '/path/3.jpg']);
    });

    test('should delete a note', () async {
      final note = Note(
        content: 'Note to delete',
        timestamp: DateTime(2024, 2, 25),
      );

      final id = await dbHelper.createNote(note);
      expect(await dbHelper.getAllNotes(), hasLength(1));

      await dbHelper.deleteNote(id);
      expect(await dbHelper.getAllNotes(), isEmpty);
    });

    test('should persist favorite status correctly', () async {
      final note = Note(
        content: 'Favorite note',
        timestamp: DateTime(2024, 2, 25),
        isFavorite: true,
      );

      await dbHelper.createNote(note);
      final notes = await dbHelper.getAllNotes();

      expect(notes.first.isFavorite, true);
    });
  });

  group('DatabaseHelper Schema', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.forTest();
      await dbHelper.database;
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('should create notes table with image_paths column', () async {
      final db = await dbHelper.database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'notes'],
      );

      expect(tables.isNotEmpty, true);

      // Get table schema
      final columns = await db.rawQuery('PRAGMA table_info(notes)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('content'));
      expect(columnNames, contains('timestamp'));
      expect(columnNames, contains('isFavorite'));
      expect(columnNames, contains('image_paths'));
    });

    test('should create tags table', () async {
      final db = await dbHelper.database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'tags'],
      );

      expect(tables.isNotEmpty, true);

      final columns = await db.rawQuery('PRAGMA table_info(tags)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('name'));
    });

    test('should create note_tags junction table', () async {
      final db = await dbHelper.database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'note_tags'],
      );

      expect(tables.isNotEmpty, true);
    });
  });
}
