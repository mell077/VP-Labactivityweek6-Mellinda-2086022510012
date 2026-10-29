import 'package:flutter_test/flutter_test.dart';
import 'package:lab_activity_week6/models/book.dart';
import 'package:lab_activity_week6/models/loan.dart';
import 'package:lab_activity_week6/viewmodels/library_view_model.dart';

void main() {
  const book = Book(
      id: 'B1',
      title: 'T',
      author: 'A',
      replacementPrice: 100000,
      isAvailable: false);

  Loan loanDue(DateTime due) => Loan(
      id: 'L1',
      bookId: 'B1',
      studentId: 'S1',
      borrowDate: due.subtract(const Duration(days: 14)),
      dueDate: due);

  // Jatuh tempo 1 Oktober 2026
  int fineOn(DateTime now) {
    final vm = LibraryViewModel(
        books: [book], loans: [loanDue(DateTime(2026, 10, 1))], clock: () => now);
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
    final vm = LibraryViewModel(books: [book.copyWith(isAvailable: true)]);
    expect(vm.borrowBook('B1', 'S1').success, isTrue);
    expect(vm.borrowBook('B1', 'S2').success, isFalse);
  });

  test('mengembalikan buku membuatnya tersedia lagi', () {
    final vm = LibraryViewModel(books: [book.copyWith(isAvailable: true)]);
    vm.borrowBook('B1', 'S1');
    vm.returnBook(vm.activeLoans.first.id);
    expect(vm.bookById('B1')!.isAvailable, isTrue);
    expect(vm.activeLoans, isEmpty);
  });

  test('denda dihitung per mahasiswa', () {
    final now = DateTime(2026, 10, 15);
    Loan loan(String id, String student) => Loan(
        id: id,
        bookId: 'B1',
        studentId: student,
        borrowDate: DateTime(2026, 9, 17),
        dueDate: DateTime(2026, 10, 1));
    final vm = LibraryViewModel(
        books: [book],
        loans: [loan('L1', 'S1')],
        clock: () => now);
    expect(vm.fineForStudent('S1'), 10000);
    expect(vm.fineForStudent('S2'), 0);
  });
}