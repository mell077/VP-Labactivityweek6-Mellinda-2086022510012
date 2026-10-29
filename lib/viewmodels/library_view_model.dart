import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/library_service.dart';
import '../models/loan.dart';
import 'display_status.dart';
import 'fine_calculator.dart';
import 'operation_result.dart';

/// Ringkasan per mahasiswa (dihitung oleh ViewModel).
class StudentSummary {
  final String studentId;
  final int activeLoans;
  final int overdueLoans; // terlambat atau hilang
  final int totalFine;
  const StudentSummary({
    required this.studentId,
    required this.activeLoans,
    required this.overdueLoans,
    required this.totalFine,
  });
}

/// ViewModel: semua aturan bisnis & keputusan peminjaman ada di sini.
class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required LibraryService service,
    DateTime Function()? clock, loan, book,
  })  : _service = service,
        _clock = clock ?? DateTime.now;

  final LibraryService _service;
  final DateTime Function() _clock; // bisa diganti saat pengujian

  // ---------- Data untuk UI (read-only) ----------
  List<Book> get books => _service.books;
  List<Loan> get activeLoans =>
      List.unmodifiable(_service.loans.where((l) => l.isActive));
  List<Loan> get returnedLoans =>
      List.unmodifiable(_service.loans.where((l) => !l.isActive));
  List<Loan> get overdueLoans => List.unmodifiable(_service.loans.where((l) {
        final s = getOverdueStatus(l);
        return s == LoanStatus.overdue || s == LoanStatus.lost;
      }));

  Book? bookById(String id) => _service.findBook(id);

  // ---------- Ringkasan ----------
  int get availableCount => books.where((b) => b.isAvailable).length;
  int get borrowedCount => activeLoans.length;
  int get overdueCount => _service.loans
      .where((l) => getOverdueStatus(l) == LoanStatus.overdue)
      .length;
  int get lostCount => _service.loans
      .where((l) => getOverdueStatus(l) == LoanStatus.lost)
      .length;

  /// Total denda: pinjaman aktif (dihitung sekarang) + denda belum dibayar.
  int get totalOutstandingFine =>
      _service.loans.fold(0, (sum, l) => sum + calculateFine(l));

  // ---------- Perhitungan per mahasiswa ----------
  /// Total denda/biaya satu mahasiswa dari semua pinjamannya.
  int fineForStudent(String studentId) => _service.loans
      .where((l) => l.studentId == studentId)
      .fold(0, (sum, l) => sum + calculateFine(l));

  List<StudentSummary> get studentSummaries {
    final ids = _service.loans.map((l) => l.studentId).toSet().toList()..sort();
    return List.unmodifiable(ids.map((id) {
      final mine = _service.loans.where((l) => l.studentId == id).toList();
      return StudentSummary(
        studentId: id,
        activeLoans: mine.where((l) => l.isActive).length,
        overdueLoans: mine.where((l) {
          final s = getOverdueStatus(l);
          return s == LoanStatus.overdue || s == LoanStatus.lost;
        }).length,
        totalFine: fineForStudent(id),
      );
    }));
  }

  // ---------- Aturan bisnis ----------
  bool canBorrow(Book book) =>
      book.isAvailable && _service.activeLoanForBook(book.id) == null;

  OperationResult borrowBook(String bookId, String studentId) {
    final id = studentId.trim();
    if (id.isEmpty) {
      return const OperationResult.fail('ID mahasiswa wajib diisi.');
    }
    final book = _service.findBook(bookId);
    if (book == null) return const OperationResult.fail('Buku tidak ditemukan.');
    if (_service.activeLoanForBook(bookId) != null) {
      return const OperationResult.fail(
          'Buku ini sudah memiliki pinjaman aktif.'); // aturan 5
    }
    if (!book.isAvailable) {
      return const OperationResult.fail('Buku sedang tidak tersedia.'); // aturan 1
    }

    final now = FineCalculator.dateOnly(_clock());
    _service.addLoan(Loan(
      id: _service.nextLoanId(),
      bookId: bookId,
      studentId: id,
      borrowDate: now,
      dueDate: DateTime(now.year, now.month, now.day + FineCalculator.loanDurationDays),
    ));
    _service.setAvailability(bookId, false);
    notifyListeners(); // aturan 8
    return OperationResult.ok('"${book.title}" berhasil dipinjam.');
  }

  OperationResult returnBook(String loanId) {
    final loan = _service.findLoan(loanId);
    if (loan == null) {
      return const OperationResult.fail('Catatan peminjaman tidak ditemukan.');
    }
    if (!loan.isActive) {
      return const OperationResult.fail('Buku ini sudah dikembalikan.');
    }

    final now = _clock();
    final fine = _computeFine(loan, now);
    _service.replaceLoan(loan.copyWith(returnDate: now, unpaidFine: fine));
    _service.setAvailability(loan.bookId, true); // tersedia kembali (aturan 3)
    notifyListeners();

    final title = bookById(loan.bookId)?.title ?? 'Buku';
    return OperationResult.ok(fine > 0
        ? '"$title" dikembalikan. Biaya yang belum dibayar: Rp$fine.'
        : '"$title" dikembalikan tanpa denda.');
  }

  /// Denda saat ini. Pinjaman aktif dihitung ulang; yang sudah kembali
  /// memakai biaya yang tercatat saat pengembalian (peraturan 7).
  int calculateFine(Loan loan) =>
      loan.isActive ? _computeFine(loan, _clock()) : loan.unpaidFine;

  int _computeFine(Loan loan, DateTime asOf) {
    if (FineCalculator.isLost(loan.dueDate, asOf)) {
      return bookById(loan.bookId)?.replacementPrice ?? 0; // harga pengganti
    }
    return FineCalculator.weeklyFine(loan.dueDate, asOf);
  }

  int completedLateWeeks(Loan loan) => FineCalculator.completedLateWeeks(
      loan.dueDate, loan.returnDate ?? _clock());

  LoanStatus getOverdueStatus(Loan loan) {
    if (!loan.isActive) return LoanStatus.returned;
    final now = _clock();
    if (FineCalculator.isLost(loan.dueDate, now)) return LoanStatus.lost;
    if (FineCalculator.daysBetween(loan.dueDate, now) > 0) {
      return LoanStatus.overdue;
    }
    return LoanStatus.active;
  }

  BookDisplayStatus statusOfBook(Book book) {
    if (book.isAvailable) return BookDisplayStatus.available;
    final loan = _service.activeLoanForBook(book.id);
    if (loan == null) return BookDisplayStatus.borrowed;
    switch (getOverdueStatus(loan)) {
      case LoanStatus.lost:
        return BookDisplayStatus.lost;
      case LoanStatus.overdue:
        return BookDisplayStatus.overdue;
      default:
        return BookDisplayStatus.borrowed;
    }
  }
}