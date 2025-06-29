class Classification {
  final int id;
  final String name;

  Classification({required this.id, required this.name});

  factory Classification.fromMap(Map<String, dynamic> map) =>
      Classification(id: map['id'], name: map['name']);

  Map<String, dynamic> toMap() => {'name': name};
  Map<String, dynamic> toLocalMap() => {'name': name, 'id': id};
}
