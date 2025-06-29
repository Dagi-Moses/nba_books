import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nba_book_catalogue/utils/modals/show_book_modal.dart';

class AddBookButton extends StatelessWidget {
  const AddBookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: () {
          showAddBookModal(context);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: const Text('Add Book', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
