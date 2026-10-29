import 'book.dart';
import 'loan.dart';

List<Book> buildSampleBooks() => const [
      Book(id: 'B1', title: 'Pemrograman Dart', author: 'A. Santoso', replacementPrice: 85000),
      Book(id: 'B2', title: 'Flutter untuk Pemula', author: 'R. Putri', replacementPrice: 95000, isAvailable: false),
      Book(id: 'B3', title: 'Struktur Data', author: 'D. Wijaya', replacementPrice: 120000, isAvailable: false),
      Book(id: 'B4', title: 'Basis Data Relasional', author: 'S. Lestari', replacementPrice: 110000, isAvailable: false),
      Book(id: 'B5', title: 'Jaringan Komputer', author: 'H. Kurniawan', replacementPrice: 150000, isAvailable: false),
      Book(id: 'B6', title: 'Rekayasa Perangkat Lunak', author: 'M. Rahman', replacementPrice: 130000),
    ];

/// Data awal untuk menguji berbagai kondisi (aktif, terlambat 1 & 2 minggu, hilang).
List<Loan> buildSampleLoans(DateTime now) {
  DateTime d(int daysFromNow) =>
      DateTime(now.year, now.month, now.day).add(Duration(days: daysFromNow));
  Loan make(String id, String bookId, String studentId, DateTime due) => Loan(
        id: id,
        bookId: bookId,
        studentId: studentId,
        borrowDate: due.subtract(const Duration(days: 14)),
        dueDate: due,
      );
  return [
    make('L1', 'B2', '2024001', d(4)), // masih aktif
    make('L2', 'B3', '2024002', d(-8)), // terlambat 1 minggu
    make('L3', 'B4', '2024002', d(-15)), // terlambat 2 minggu
    make('L4', 'B5', '2024003', d(-200)), // lewat enam bulan => Hilang
  ];
}