class Book {
  int id;
  String title;
  String author;
  String publisher;
  int classificationId;
  int subjectId;
  DateTime publicationDate;
  DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.classificationId,
    required this.subjectId,
    required this.publicationDate,
    required this.createdAt,
  });

  factory Book.fromMap(Map<String, dynamic> map) => Book(
    id: map['id'],
    title: map['title'] ?? '',
    author: map['author'] ?? '',
    publisher: map['publisher'] ?? "",
    classificationId: map['classification_id'],
    subjectId: map['subject_id'],

    publicationDate: DateTime.parse(map['publication_date']),
    createdAt: DateTime.parse(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'publisher': publisher,
    'classification_id': classificationId,
    'subject_id': subjectId,
    'publication_date': publicationDate.toIso8601String(),
  };

  Map<String, dynamic> toLocalMap() {
    // For internal use (caching, editing)
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'classification_id': classificationId,
      'subject_id': subjectId,
      'publication_date': publicationDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
