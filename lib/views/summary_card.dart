import 'package:flutter/material.dart';

import 'formatters.dart';

/// Kartu ringkasan: hanya menampilkan angka dari ViewModel.
class SummaryCard extends StatelessWidget {
  final int available;
  final int borrowed;
  final int overdue;
  final int lost;
  final int totalFine;

  const SummaryCard({
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