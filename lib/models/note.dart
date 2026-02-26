import 'dart:convert';

class Note {
  final int? id;
  final String content;
  final DateTime timestamp;
  final bool isFavorite;
  final List<String> imagePaths;

  Note({
    this.id,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
    this.imagePaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
      'image_paths': jsonEncode(imagePaths),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    List<String> parsedImagePaths = [];
    if (map['image_paths'] != null && map['image_paths'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['image_paths']);
        if (decoded is List) {
          parsedImagePaths = decoded.cast<String>();
        }
      } catch (e) {
        // If JSON parsing fails, default to empty list
        parsedImagePaths = [];
      }
    }

    return Note(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isFavorite: map['isFavorite'] == 1,
      imagePaths: parsedImagePaths,
    );
  }

  Note copyWith({
    int? id,
    String? content,
    DateTime? timestamp,
    bool? isFavorite,
    List<String>? imagePaths,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
