import 'package:flutter/material.dart';

class BooksFooter extends StatelessWidget {
  final int totalBooks;

  const BooksFooter({super.key, required this.totalBooks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            'Total Books: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            '$totalBooks',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
