import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'loan_card.dart';
import 'summary_card.dart';

class BorrowedBooksScreen extends StatelessWidget {
  final LibraryViewModel viewModel;
  const BorrowedBooksScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Buku Dipinjam')),
        body: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final active = viewModel.activeLoans;
            final history = viewModel.returnedLoans;
            return ListView(children: [
              SummaryCard(
                available: viewModel.availableCount,
                borrowed: viewModel.borrowedCount,
                overdue: viewModel.overdueCount,
                lost: viewModel.lostCount,
                totalFine: viewModel.totalOutstandingFine,
              ),
              const _Header('Pinjaman aktif'),
              if (active.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada pinjaman aktif.')),
              for (final loan in active)
                LoanCard(
                  bookTitle:
                      viewModel.bookById(loan.bookId)?.title ?? loan.bookId,
                  studentId: loan.studentId,
                  dueDate: loan.dueDate,
                  returnDate: null,
                  status: viewModel.getOverdueStatus(loan),
                  fine: viewModel.calculateFine(loan),
                  lateWeeks: viewModel.completedLateWeeks(loan),
                  onReturn: () {
                    final r = viewModel.returnBook(loan.id);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(r.message)));
                  },
                ),
              if (history.isNotEmpty) const _Header('Riwayat'),
              for (final loan in history)
                LoanCard(
                  bookTitle:
                      viewModel.bookById(loan.bookId)?.title ?? loan.bookId,
                  studentId: loan.studentId,
                  dueDate: loan.dueDate,
                  returnDate: loan.returnDate,
                  status: LoanStatus.returned,
                  fine: viewModel.calculateFine(loan),
                  lateWeeks: viewModel.completedLateWeeks(loan),
                ),
            ]);
          },
        ),
      );
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}