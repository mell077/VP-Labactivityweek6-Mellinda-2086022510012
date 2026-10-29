import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'book_card.dart';
import 'borrowed_books_screen.dart';
import 'fine_summary_card.dart';

class LibraryScreen extends StatefulWidget {
  final LibraryViewModel viewModel;
  const LibraryScreen({super.key, required this.viewModel});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _studentIdController = TextEditingController(text: '2024001');

  LibraryViewModel get vm => widget.viewModel;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  void _borrow(String bookId) {
    // View hanya meneruskan aksi; keputusan ada di ViewModel.
    final result = vm.borrowBook(bookId, _studentIdController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Perpustakaan Universitas'),
          actions: [
            IconButton(
              tooltip: 'Buku dipinjam',
              icon: const Icon(Icons.bookmarks),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BorrowedBooksScreen(viewModel: vm),
              )),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => ListView(children: [
            FineSummaryCard(
              available: vm.availableCount,
              borrowed: vm.borrowedCount,
              overdue: vm.overdueCount,
              lost: vm.lostCount,
              totalFine: vm.totalOutstandingFine,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text('Denda per mahasiswa',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final s in vm.studentSummaries)
              StudentFineCard(
                studentId: s.studentId,
                activeLoans: s.activeLoans,
                overdueLoans: s.overdueLoans,
                totalFine: s.totalFine,
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Mahasiswa',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final book in vm.books)
              BookCard(
                book: book,
                status: vm.statusOfBook(book),
                canBorrow: vm.canBorrow(book),
                onBorrow: () => _borrow(book.id),
              ),
          ]),
        ),
      );
}