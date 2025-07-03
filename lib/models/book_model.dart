class Book {
  int id;
  String title;
  String author;
  String publisher;
  String isbn;
  int classificationId;
  int subjectId;
  int publicationDate;
  DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
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
    isbn: map['isbn'] ?? "",
    classificationId: map['classification_id'],
    subjectId: map['subject_id'],

    publicationDate: map['publication_date'] as int,
    createdAt: DateTime.parse(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'isbn': isbn,
    'title': title,
    'author': author,
    'publisher': publisher,

    'classification_id': classificationId,
    'subject_id': subjectId,
    'publication_date': publicationDate,
  };

  Map<String, dynamic> toLocalMap() {
    // For internal use (caching, editing)
    return {
      'id': id,
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,

      'classification_id': classificationId,
      'subject_id': subjectId,
      'publication_date': publicationDate,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
