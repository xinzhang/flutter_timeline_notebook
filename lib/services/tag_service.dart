import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/tag.dart';

class TagService {
  static final RegExp _tagRegex = RegExp(r'#(\w+)');

  static List<String> extractTags(String content) {
    final matches = _tagRegex.allMatches(content);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }

  static Future<List<String>> saveTagsForNote(
    int noteId,
    List<String> tagNames,
  ) async {
    final db = await DatabaseHelper.instance.database;

    for (final tagName in tagNames) {
      var tag = await _getTagByName(db, tagName);
      if (tag == null) {
        final tagId = await db.insert('tags', {'name': tagName});
        tag = Tag(id: tagId, name: tagName);
      }

      await db.insert(
        'note_tags',
        {'noteId': noteId, 'tagId': tag.id},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }

    return tagNames;
  }

  static Future<Tag?> _getTagByName(Database db, String name) async {
    final result = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Tag.fromMap(result.first);
  }
}
