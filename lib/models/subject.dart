class Subject {
  final int id;
  final String name;

  Subject({required this.id, required this.name});

  factory Subject.fromMap(Map<String, dynamic> map) =>
      Subject(id: map['id'], name: map['name']);

  Map<String, dynamic> toMap() => {'name': name};
  Map<String, dynamic> toLocalMap() => {'name': name, 'id': id};
}
