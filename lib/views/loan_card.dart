import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'formatters.dart';
import 'status_style.dart';

class LoanCard extends StatelessWidget {
  final String bookTitle;
  final String studentId;
  final DateTime dueDate;
  final DateTime? returnDate;
  final LoanStatus status;
  final int fine; // sudah dihitung oleh ViewModel
  final int lateWeeks; // sudah dihitung oleh ViewModel
  final VoidCallback? onReturn; // memanggil ViewModel.returnBook()

  const LoanCard({
    super.key,
    required this.bookTitle,
    required this.studentId,
    required this.dueDate,
    required this.returnDate,
    required this.status,
    required this.fine,
    required this.lateWeeks,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      'Mahasiswa: $studentId',
      'Jatuh tempo: ${formatDate(dueDate)}',
      if (returnDate != null) 'Dikembalikan: ${formatDate(returnDate!)}',
      if (lateWeeks > 0) 'Terlambat: $lateWeeks minggu',
      if (fine > 0) 'Denda/biaya: ${formatRupiah(fine)}',
    ];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bookTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  for (final line in lines) Text(line),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(styleForLoan(status)),
                if (onReturn != null)
                  TextButton(
                      onPressed: onReturn, child: const Text('Kembalikan')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}