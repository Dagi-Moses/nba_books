import 'package:nba_book_catalogue/components/add_book_dialog.dart';
import 'package:flutter/material.dart';

void showAddBookModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const AddBookModal(),
  );
}
