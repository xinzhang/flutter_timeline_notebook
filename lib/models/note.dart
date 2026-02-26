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
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isFavorite: map['isFavorite'] == 1,
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
