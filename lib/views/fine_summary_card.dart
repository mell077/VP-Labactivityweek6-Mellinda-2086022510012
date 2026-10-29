import 'package:flutter/material.dart';

import 'view_helpers.dart';

/// Kartu ringkasan keseluruhan: hanya menampilkan angka dari ViewModel.
class FineSummaryCard extends StatelessWidget {
  final int available;
  final int borrowed;
  final int overdue;
  final int lost;
  final int totalFine;

  const FineSummaryCard({
    super.key,
    required this.available,
    required this.borrowed,
    required this.overdue,
    required this.lost,
    required this.totalFine,
  });

  Widget _item(String label, String value) => Expanded(
        child: Column(children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              _item('Tersedia', '$available'),
              _item('Dipinjam', '$borrowed'),
              _item('Terlambat', '$overdue'),
              _item('Hilang', '$lost'),
            ]),
            const Divider(),
            Text('Total biaya/denda: ${formatRupiah(totalFine)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

/// Total denda satu mahasiswa. Angkanya dihitung oleh ViewModel.
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