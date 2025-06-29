import 'package:nba_book_catalogue/models/subject.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final response = await Supabase.instance.client
      .from('subjects')
      .select('id, name')
      .order('name');

  return (response as List).map((map) => Subject.fromMap(map)).toList();
});
