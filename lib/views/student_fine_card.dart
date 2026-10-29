import 'package:flutter/material.dart';

import 'formatters.dart';

/// Menampilkan total denda satu mahasiswa. Angkanya dihitung oleh ViewModel.
class StudentFineCard extends StatelessWidget {
  final String studentId;
  final int activeLoans;
  final int overdueLoans;
  final int totalFine;

  const StudentFineCard({
    super.key,
    required this.studentId,
    required this.activeLoans,
    required this.overdueLoans,
    required this.totalFine,
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
                    Text('Mahasiswa $studentId',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                        'Pinjaman aktif: $activeLoans • Terlambat/hilang: $overdueLoans'),
                  ],
                ),
              ),
              Text(formatRupiah(totalFine),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}