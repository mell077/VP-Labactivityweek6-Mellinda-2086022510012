import 'package:flutter/material.dart';

import '../models/book.dart';
import '../viewmodels/display_status.dart';
import 'status_chip.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final BookDisplayStatus status;
  final bool canBorrow;
  final VoidCallback onBorrow; // memanggil ViewModel.borrowBook()

  const BookCard({
    super.key,
    required this.book,
    required this.status,
    required this.canBorrow,
    required this.onBorrow,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(book.author),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(styleForBook(status)),
                  if (canBorrow)
                    TextButton(
                        onPressed: onBorrow, child: const Text('Pinjam')),
                ],
              ),
            ],
          ),
        ),
      );
}