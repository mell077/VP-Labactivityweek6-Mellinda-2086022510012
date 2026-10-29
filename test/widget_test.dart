import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_activity_week6/main.dart';
import 'package:lab_activity_week6/models/book.dart';
import 'package:lab_activity_week6/models/library_repository.dart';
import 'package:lab_activity_week6/models/library_service.dart';
import 'package:lab_activity_week6/models/loan.dart';
import 'package:lab_activity_week6/viewmodels/library_view_model.dart';

const _json = '''
{
  "books": [
    { "id": "B1", "title": "Pemrograman Dart", "author": "A. Santoso", "replacementPrice": 85000, "isAvailable": true },
    { "id": "B2", "title": "Flutter untuk Pemula", "author": "R. Putri", "replacementPrice": 95000, "isAvailable": false }
  ],
  "loans": [
    { "id": "L1", "bookId": "B2", "studentId": "2024001", "dueInDays": -8 }
  ]
}
''';

LibraryViewModel _vmFromJson(DateTime today) {
  final data = LibraryRepository.parse(_json, today: today);
  return LibraryViewModel(
    service: LibraryService(books: data.books, loans: data.loans),
    clock: () => today,
  );
}

void main() {
  group('LibraryRepository', () {
    test('membaca buku dan pinjaman dari JSON', () {
      final data = LibraryRepository.parse(_json, today: DateTime(2026, 10, 15));
      expect(data.books.length, 2);
      expect(data.loans.length, 1);
      expect(data.loans.first.dueDate, DateTime(2026, 10, 7));
    });
  });

  group('LibraryViewModel', () {
    const book = Book(
        id: 'B1',
        title: 'T',
        author: 'A',
        replacementPrice: 100000,
        isAvailable: false);

    // Jatuh tempo 1 Oktober 2026
    int fineOn(DateTime now) {
      final vm = LibraryViewModel(
        service: LibraryService(books: [
          book
        ], loans: [
          Loan(
              id: 'L1',
              bookId: 'B1',
              studentId: 'S1',
              borrowDate: DateTime(2026, 9, 17),
              dueDate: DateTime(2026, 10, 1))
        ]),
        clock: () => now,
      );
      return vm.calculateFine(vm.activeLoans.first);
    }

    test('jadwal denda mingguan', () {
      expect(fineOn(DateTime(2026, 10, 1)), 0);
      expect(fineOn(DateTime(2026, 10, 7)), 0);
      expect(fineOn(DateTime(2026, 10, 8)), 5000);
      expect(fineOn(DateTime(2026, 10, 15)), 10000);
    });

    test('ambang enam bulan => Hilang dan harga pengganti', () {
      expect(fineOn(DateTime(2027, 3, 31)), 125000); // 25 minggu x 5.000
      expect(fineOn(DateTime(2027, 4, 1)), 100000); // harga pengganti
    });

    test('tidak boleh pinjam ganda', () {
      final vm = LibraryViewModel(
          service: LibraryService(books: [book.copyWith(isAvailable: true)]));
      expect(vm.borrowBook('B1', 'S1').success, isTrue);
      expect(vm.borrowBook('B1', 'S2').success, isFalse);
    });

    test('mengembalikan buku membuatnya tersedia lagi', () {
      final vm = LibraryViewModel(
          service: LibraryService(books: [book.copyWith(isAvailable: true)]));
      vm.borrowBook('B1', 'S1');
      vm.returnBook(vm.activeLoans.first.id);
      expect(vm.bookById('B1')!.isAvailable, isTrue);
      expect(vm.activeLoans, isEmpty);
    });

    test('denda dihitung per mahasiswa', () {
      final vm = _vmFromJson(DateTime(2026, 10, 15)); // terlambat 8 hari
      expect(vm.fineForStudent('2024001'), 5000);
      expect(vm.fineForStudent('2024999'), 0);
    });
  });

  group('Tampilan', () {
    testWidgets('menampilkan layar, denda per mahasiswa, dan meminjam buku',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(LibraryApp(viewModel: _vmFromJson(DateTime.now())));

      expect(find.text('Perpustakaan Universitas'), findsOneWidget);
      expect(find.text('Denda per mahasiswa'), findsOneWidget);
      expect(find.text('Mahasiswa 2024001'), findsOneWidget);
      expect(find.text('Pemrograman Dart'), findsOneWidget);

      await tester.tap(find.text('Pinjam').first);
      await tester.pump();

      expect(
          find.text('"Pemrograman Dart" berhasil dipinjam.'), findsOneWidget);
    });
  });
}