import 'package:nba_book_catalogue/models/classification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final classificationsProvider = FutureProvider<List<Classification>>((
//   ref,
// ) async {
//   final response = await Supabase.instance.client
//       .from('classifications')
//       .select('id, name')
//       .order('name');

//   return (response as List).map((map) => Classification.fromMap(map)).toList();
// });

final classificationsProvider = StateNotifierProvider<
  ClassificationsNotifier,
  AsyncValue<List<Classification>>
>((ref) => ClassificationsNotifier());

class ClassificationsNotifier
    extends StateNotifier<AsyncValue<List<Classification>>> {
  final supabase = Supabase.instance.client;

  ClassificationsNotifier() : super(const AsyncLoading()) {
    loadClassifications();
  }

  Future<void> loadClassifications() async {
    try {
      final response = await supabase
          .from('classifications')
          .select('id, name');
      final classifications =
          (response as List)
              .map(
                (item) => Classification(
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

  Future<void> addClassification(String description) async {
    try {
      final response =
          await supabase
              .from('classifications')
              .insert({'name': description})
              .select()
              .single();
      final id = response['id'] as int;
      final newClassification = Classification(id: id, name: description);

      state = state.whenData((list) => [...list, newClassification]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateClassification(int id, String newDescription) async {
    try {
      await supabase
          .from('classifications')
          .update({'name': newDescription})
          .eq('id', id);
      state = state.whenData((list) {
        return list.map((classification) {
          if (classification.id == id) {
            return Classification(id: id, name: newDescription);
          }
          return classification;
        }).toList();
      });
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteClassification(int id) async {
    try {
      await supabase.from('classifications').delete().eq('id', id);
      state = state.whenData((list) => list.where((c) => c.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
