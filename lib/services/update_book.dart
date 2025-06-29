import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';

final supabase = Supabase.instance.client;

Future<void> updateBookOnSupabase({required Book book}) async {
  final updatedMap = book.toMap();

  try {
    final response =
        await supabase
            .from('books')
            .update(updatedMap)
            .eq('id', book.id)
            .select();

    if (response.isEmpty) {
      throw Exception("No response from Supabase");
    }

    Fluttertoast.showToast(
      msg: '✅ Book updated successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    debugPrint("❌ Failed to update book: $e");

    Fluttertoast.showToast(
      msg: '❌ Failed to update book',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
