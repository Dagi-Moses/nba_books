import 'package:nba_book_catalogue/models/book_model.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class BookService {
  Future<void> createBook(Book book) async {
    await supabase.from('books').insert(book.toMap());
  }

  Future<void> updateBook(String id, Map<String, dynamic> updates) async {
    await supabase.from('books').update(updates).eq('id', id);
  }

  Future<void> deleteBook(String id) async {
    await supabase.from('books').delete().eq('id', id);
  }

  Future<Book?> fetchBookById(String id) async {
    final response =
        await supabase.from('books').select().eq('id', id).single();
    return Book.fromMap(response);
  }
}
