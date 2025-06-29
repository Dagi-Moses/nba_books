import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nba_book_catalogue/models/book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final bookSearchQueryProvider = StateProvider<String>((ref) => '');

final isEditingProvider = StateProvider<bool>((ref) => false);

final booksProvider = StreamProvider<List<Book>>((ref) {
  final stream = supabase.from('books').stream(primaryKey: ['id']);
  return stream.map((rows) {
    final books = rows.map(Book.fromMap).toList();

    return books;
  });
});
