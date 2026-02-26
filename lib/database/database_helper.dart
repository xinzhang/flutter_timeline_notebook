import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/tag.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final bool _isTest;

  DatabaseHelper._init({bool isTest = false}) : _isTest = isTest;

  factory DatabaseHelper.forTest() {
    return DatabaseHelper._init(isTest: true);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_isTest ? ':memory:' : 'timeline_notebook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (_isTest) {
      // For testing, use in-memory database
      return await openDatabase(filePath, version: 1, onCreate: _createDB);
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        image_paths TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE note_tags (
        noteId INTEGER,
        tagId INTEGER,
        PRIMARY KEY (noteId, tagId),
        FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final result = await db.query(
      'notes',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createTag(String name) async {
    final db = await database;
    final result = await db.insert(
      'tags',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return result;
  }

  Future<Tag?> getTagByName(String name) async {
    final db = await database;
    final result = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Tag.fromMap(result.first);
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final result = await db.query('tags', orderBy: 'name ASC');
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  Future<List<Tag>> getTagsForNote(int noteId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT tags.* FROM tags
      INNER JOIN note_tags ON tags.id = note_tags.tagId
      WHERE note_tags.noteId = ?
    ''', [noteId]);
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  Future<Map<int, List<String>>> getAllNotesTags() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT nt.noteId, t.name
      FROM note_tags nt
      INNER JOIN tags t ON nt.tagId = t.id
    ''');

    final Map<int, List<String>> noteTags = {};
    for (final row in result) {
      final noteId = row['noteId'] as int;
      final tagName = row['name'] as String;
      noteTags.putIfAbsent(noteId, () => []).add(tagName);
    }
    return noteTags;
  }

  Future<void> addTagToNote(int noteId, int tagId) async {
    final db = await database;
    await db.insert(
      'note_tags',
      {'noteId': noteId, 'tagId': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTagFromNote(int noteId, int tagId) async {
    final db = await database;
    await db.delete(
      'note_tags',
      where: 'noteId = ? AND tagId = ?',
      whereArgs: [noteId, tagId],
    );
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    // Escape special SQL characters to prevent SQL injection
    final escapedQuery = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
    final result = await db.query(
      'notes',
      where: 'content LIKE ? ESCAPE \'\\\'',
      whereArgs: ['%$escapedQuery%'],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  void _resetDatabase() {
    _database = null;
  }
}
