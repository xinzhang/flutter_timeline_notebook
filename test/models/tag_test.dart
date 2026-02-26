import 'package:flutter_test/flutter_test.dart';
import 'package:timeline_notebook/models/tag.dart';

void main() {
  group('Tag Model', () {
    test('should create tag from map', () {
      final map = {
        'id': 1,
        'name': 'Important',
      };
      final tag = Tag.fromMap(map);
      expect(tag.id, 1);
      expect(tag.name, 'Important');
    });

    test('should create tag from map without id', () {
      final map = {
        'name': 'Work',
      };
      final tag = Tag.fromMap(map);
      expect(tag.id, null);
      expect(tag.name, 'Work');
    });

    test('should convert tag to map', () {
      final tag = Tag(
        id: 1,
        name: 'Personal',
      );
      final map = tag.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Personal');
    });

    test('should convert tag to map without id', () {
      final tag = Tag(name: 'Shopping');
      final map = tag.toMap();
      expect(map.containsKey('id'), false);
      expect(map['name'], 'Shopping');
    });

    test('should create tag with required name parameter', () {
      const tagName = 'Urgent';
      final tag = Tag(name: tagName);
      expect(tag.name, tagName);
      expect(tag.id, null);
    });
  });
}
