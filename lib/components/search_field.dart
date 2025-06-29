import 'package:nba_book_catalogue/providers/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 700),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          ref.read(bookSearchQueryProvider.notifier).state =
              value.trim().toLowerCase();
        },
      ),
    );
  }
}
