import 'package:nba_book_catalogue/models/classification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final classificationsProvider = FutureProvider<List<Classification>>((
  ref,
) async {
  final response = await Supabase.instance.client
      .from('classifications')
      .select('id, name')
      .order('name');

  return (response as List).map((map) => Classification.fromMap(map)).toList();
});
