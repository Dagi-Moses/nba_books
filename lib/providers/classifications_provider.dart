import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      Fluttertoast.showToast(
        msg: "Classification Added",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      state = state.whenData((list) => [...list, newClassification]);
    } catch (e, st) {
      final errorMessage = e.toString();
      if (errorMessage.contains(
        'duplicate key value violates unique constraint',
      )) {
        debugPrint('Classification "$description" already exists.');
        Fluttertoast.showToast(
          msg: 'Classification "$description" already exists.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        state = AsyncError(e, st);
      }
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

      Fluttertoast.showToast(
        msg: "Classification updated successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e, st) {
      final errorMessage = e.toString();

      if (errorMessage.contains('duplicate key value') ||
          errorMessage.contains('Duplicate')) {
        Fluttertoast.showToast(
          msg: "A classification with this name already exists.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      Fluttertoast.showToast(
        msg: "Error updating classification: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      state = AsyncError(e, st);
    }
  }

  Future<void> deleteClassification(int id, BuildContext context) async {
    try {
      await supabase.from('classifications').delete().eq('id', id);
      state = state.whenData((list) => list.where((c) => c.id != id).toList());
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: "Subject deleted successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e, st) {
      Fluttertoast.showToast(
        msg: "Error deleting subject: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      state = AsyncError(e, st);
    }
  }
}
