import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    StateNotifierProvider<SubjectsNotifier, AsyncValue<List<Subject>>>(
      (ref) => SubjectsNotifier(),
    );

class SubjectsNotifier extends StateNotifier<AsyncValue<List<Subject>>> {
  final supabase = Supabase.instance.client;

  SubjectsNotifier() : super(const AsyncLoading()) {
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
      final newSubject = Subject(id: id, name: description);
      Fluttertoast.showToast(
        msg: "Subject Added",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      state = state.whenData((list) => [...list, newSubject]);
    } catch (e, st) {
      final errorMessage = e.toString();
      if (errorMessage.contains(
        'duplicate key value violates unique constraint',
      )) {
        debugPrint('Subject "$description" already exists.');
        Fluttertoast.showToast(
          msg: 'Subject "$description" already exists.',
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

  Future<void> updateSubject(int id, String newDescription) async {
    try {
      await supabase
          .from('subjects')
          .update({'name': newDescription})
          .eq('id', id);

      state = state.whenData((list) {
        return list.map((subject) {
          if (subject.id == id) {
            return Subject(id: id, name: newDescription);
          }
          return subject;
        }).toList();
      });

      Fluttertoast.showToast(
        msg: "Subject updated successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e, st) {
      final errorMessage = e.toString();

      if (errorMessage.contains('duplicate key value') ||
          errorMessage.contains('Duplicate')) {
        Fluttertoast.showToast(
          msg: "A subject with this name already exists.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      Fluttertoast.showToast(
        msg: "Error updating subject: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      state = AsyncError(e, st);
    }
  }

  Future<void> deleteSubject(int id, BuildContext context) async {
    try {
      await supabase.from('subjects').delete().eq('id', id);

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
