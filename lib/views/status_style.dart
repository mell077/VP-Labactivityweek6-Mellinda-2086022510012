import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';

/// Cara konsisten untuk menampilkan status (tersedia, dipinjam, terlambat, hilang).
class StatusStyle {
  final String label;
  final Color color;
  const StatusStyle(this.label, this.color);
}

StatusStyle styleForBook(BookDisplayStatus s) {
  switch (s) {
    case BookDisplayStatus.available:
      return const StatusStyle('Tersedia', Colors.green);
    case BookDisplayStatus.borrowed:
      return const StatusStyle('Dipinjam', Colors.blue);
    case BookDisplayStatus.overdue:
      return const StatusStyle('Terlambat', Colors.orange);
    case BookDisplayStatus.lost:
      return const StatusStyle('Hilang', Colors.red);
  }
}

StatusStyle styleForLoan(LoanStatus s) {
  switch (s) {
    case LoanStatus.active:
      return const StatusStyle('Dipinjam', Colors.blue);
    case LoanStatus.overdue:
      return const StatusStyle('Terlambat', Colors.orange);
    case LoanStatus.lost:
      return const StatusStyle('Hilang', Colors.red);
    case LoanStatus.returned:
      return const StatusStyle('Dikembalikan', Colors.grey);
  }
}

class StatusChip extends StatelessWidget {
  final StatusStyle style;
  const StatusChip(this.style, {super.key});

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(style.label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: style.color,
        visualDensity: VisualDensity.compact,
        side: BorderSide.none,
      );
}