import 'package:nba_book_catalogue/models/subject.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
//   final response = await Supabase.instance.client
//       .from('subjects')
//       .select('id, name')
//       .order('name');

//   return (response as List).map((map) => Subject.fromMap(map)).toList();
// });

final subjectsProvider =
    StateNotifierProvider<ClassificationsNotifier, AsyncValue<List<Subject>>>(
      (ref) => ClassificationsNotifier(),
    );

class ClassificationsNotifier extends StateNotifier<AsyncValue<List<Subject>>> {
  final supabase = Supabase.instance.client;

  ClassificationsNotifier() : super(const AsyncLoading()) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      final response = await supabase.from('subjects').select('id, name');
      final classifications =
          (response as List)
              .map(
                (item) => Subject(
                  id: item['id'] as int,
                  name: item['name'] as String,
                ),
              )
              .toList();
      state = AsyncData(classifications);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addSubject(String description) async {
    try {
      final response =
          await supabase
              .from('subjects')
              .insert({'name': description})
              .select()
              .single();
      final id = response['id'] as int;
      final newClassification = Subject(id: id, name: description);

      state = state.whenData((list) => [...list, newClassification]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSubject(int id, String newDescription) async {
    try {
      await supabase
          .from('subjects')
          .update({'name': newDescription})
          .eq('id', id);
      state = state.whenData((list) {
        return list.map((classification) {
          if (classification.id == id) {
            return Subject(id: id, name: newDescription);
          }
          return classification;
        }).toList();
      });
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      await supabase.from('subjects').delete().eq('id', id);
      state = state.whenData((list) => list.where((c) => c.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
