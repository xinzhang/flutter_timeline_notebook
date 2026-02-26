import 'package:flutter_test/flutter_test.dart';
import 'package:timeline_notebook/services/tag_service.dart';

void main() {
  group('TagService.extractTags', () {
    test('should extract tags from content with hashtags', () {
      final content = 'Hello #world this is a #test note';
      final tags = TagService.extractTags(content);

      expect(tags, contains('world'));
      expect(tags, contains('test'));
      expect(tags.length, 2);
    });

    test('should extract unique tags only', () {
      final content = '#test #test #other';
      final tags = TagService.extractTags(content);

      expect(tags.length, 2);
      expect(tags, contains('test'));
      expect(tags, contains('other'));
    });

    test('should return empty list when no tags present', () {
      final content = 'Hello world this is a note without tags';
      final tags = TagService.extractTags(content);

      expect(tags, isEmpty);
    });

    test('should extract tags with alphanumeric characters', () {
      final content = '#tag123 #test456 #mixedABC123';
      final tags = TagService.extractTags(content);

      expect(tags.length, 3);
      expect(tags, contains('tag123'));
      expect(tags, contains('test456'));
      expect(tags, contains('mixedABC123'));
    });

    test('should handle tag at beginning of content', () {
      final content = '#importanthtag This note starts with a tag';
      final tags = TagService.extractTags(content);

      expect(tags.length, 1);
      expect(tags.first, 'importanthtag');
    });

    test('should handle tag at end of content', () {
      final content = 'This note ends with a tag #final';
      final tags = TagService.extractTags(content);

      expect(tags.length, 1);
      expect(tags.first, 'final');
    });

    test('should handle multiple tags with same name', () {
      final content = '#repeat #repeat #repeat again #repeat';
      final tags = TagService.extractTags(content);

      expect(tags.length, 1);
      expect(tags.first, 'repeat');
    });

    test('should extract tags from content with punctuation', () {
      final content = 'Hello #world! This is a #test, note.';
      final tags = TagService.extractTags(content);

      expect(tags, contains('world'));
      expect(tags, contains('test'));
      expect(tags.length, 2);
    });

    test('should handle tags with underscores', () {
      final content = 'Using #snake_case tags #test_tag';
      final tags = TagService.extractTags(content);

      // The regex #(\w+) matches \w which includes underscores
      // So #snake_case is captured as one tag: 'snake_case'
      expect(tags, contains('snake_case'));
      expect(tags, contains('test_tag'));
      expect(tags.length, 2);
    });

    test('should handle empty content', () {
      final content = '';
      final tags = TagService.extractTags(content);

      expect(tags, isEmpty);
    });

    test('should handle content with only hashtags', () {
      final content = '#tag1 #tag2 #tag3';
      final tags = TagService.extractTags(content);

      expect(tags.length, 3);
      expect(tags, containsAll(['tag1', 'tag2', 'tag3']));
    });

    test('should handle tags with numbers', () {
      final content = 'Meeting #2024 goals #project123';
      final tags = TagService.extractTags(content);

      expect(tags, contains('2024'));
      expect(tags, contains('project123'));
      expect(tags.length, 2);
    });

    test('should maintain insertion order for unique tags', () {
      final content = '#zebra #apple #banana #apple #zebra';
      final tags = TagService.extractTags(content);

      expect(tags.length, 3);
      expect(tags[0], 'zebra');
      expect(tags[1], 'apple');
      expect(tags[2], 'banana');
    });

    test('should handle single word tags', () {
      final content = '#a #i #x';
      final tags = TagService.extractTags(content);

      expect(tags.length, 3);
      expect(tags, containsAll(['a', 'i', 'x']));
    });

    test('should handle hashtags with special characters', () {
      final content = 'Test #tag# #tag@ #tag\$ special #tag!';
      final tags = TagService.extractTags(content);

      // The regex matches #(\w+), so \w includes alphanumeric and underscore
      // Special characters after \w+ should not be included
      expect(tags, contains('tag'));
      // Each special character variant of #tag gets parsed separately
      expect(tags.length, greaterThan(0));
    });
  });
}
