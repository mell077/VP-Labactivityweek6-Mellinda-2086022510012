import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/loan.dart';
import 'fine_policy.dart';

enum LoanStatus { active, overdue, lost, returned }

enum BookDisplayStatus { available, borrowed, overdue, lost }

class ActionResult {
  final bool success;
  final String message;
  const ActionResult.ok(this.message) : success = true;
  const ActionResult.fail(this.message) : success = false;
}

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
    required List<Book> books,
    List<Loan> loans = const [],
    DateTime Function()? clock,
  })  : _books = List.of(books),
        _loans = List.of(loans),
        _clock = clock ?? DateTime.now,
        _nextLoanNumber = loans.length + 1;

  final List<Book> _books;
  final List<Loan> _loans;
  final DateTime Function() _clock; // bisa diganti saat pengujian
  int _nextLoanNumber;

  // ---------- Data untuk UI (read-only) ----------
  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get activeLoans =>
      List.unmodifiable(_loans.where((l) => l.isActive));
  List<Loan> get returnedLoans =>
      List.unmodifiable(_loans.where((l) => !l.isActive));
  List<Loan> get overdueLoans => List.unmodifiable(_loans.where((l) {
        final s = getOverdueStatus(l);
        return s == LoanStatus.overdue || s == LoanStatus.lost;
      }));

  Book? bookById(String id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  Loan? _activeLoanForBook(String bookId) {
    for (final l in _loans) {
      if (l.bookId == bookId && l.isActive) return l;
    }
    return null;
  }

  // ---------- Ringkasan ----------
  int get availableCount => _books.where((b) => b.isAvailable).length;
  int get borrowedCount => activeLoans.length;
  int get overdueCount =>
      _loans.where((l) => getOverdueStatus(l) == LoanStatus.overdue).length;
  int get lostCount =>
      _loans.where((l) => getOverdueStatus(l) == LoanStatus.lost).length;

  /// Total denda: pinjaman aktif (dihitung sekarang) + denda belum dibayar.
  int get totalOutstandingFine =>
      _loans.fold(0, (sum, l) => sum + calculateFine(l));

  // ---------- Perhitungan per mahasiswa ----------
  /// Total denda/biaya satu mahasiswa dari semua pinjamannya.
  int fineForStudent(String studentId) => _loans
      .where((l) => l.studentId == studentId)
      .fold(0, (sum, l) => sum + calculateFine(l));

  List<StudentSummary> get studentSummaries {
    final ids = _loans.map((l) => l.studentId).toSet().toList()..sort();
    return List.unmodifiable(ids.map((id) {
      final mine = _loans.where((l) => l.studentId == id).toList();
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
      book.isAvailable && _activeLoanForBook(book.id) == null;

  ActionResult borrowBook(String bookId, String studentId) {
    final id = studentId.trim();
    if (id.isEmpty) return const ActionResult.fail('ID mahasiswa wajib diisi.');
    final book = bookById(bookId);
    if (book == null) return const ActionResult.fail('Buku tidak ditemukan.');
    if (_activeLoanForBook(bookId) != null) {
      return const ActionResult.fail(
          'Buku ini sudah memiliki pinjaman aktif.'); // aturan 5
    }
    if (!book.isAvailable) {
      return const ActionResult.fail('Buku sedang tidak tersedia.'); // aturan 1
    }

    final now = FinePolicy.dateOnly(_clock());
    _loans.add(Loan(
      id: 'L${_nextLoanNumber++}',
      bookId: bookId,
      studentId: id,
      borrowDate: now,
      dueDate: now.add(const Duration(days: FinePolicy.loanDurationDays)),
    ));
    _setAvailability(bookId, false);
    notifyListeners(); // aturan 8
    return ActionResult.ok('"${book.title}" berhasil dipinjam.');
  }

  ActionResult returnBook(String loanId) {
    final i = _loans.indexWhere((l) => l.id == loanId);
    if (i == -1) {
      return const ActionResult.fail('Catatan peminjaman tidak ditemukan.');
    }
    final loan = _loans[i];
    if (!loan.isActive) {
      return const ActionResult.fail('Buku ini sudah dikembalikan.');
    }

    final now = _clock();
    final fine = _computeFine(loan, now);
    _loans[i] = loan.copyWith(returnDate: now, unpaidFine: fine);
    _setAvailability(loan.bookId, true); // tersedia kembali (aturan 3)
    notifyListeners();

    final title = bookById(loan.bookId)?.title ?? 'Buku';
    return ActionResult.ok(fine > 0
        ? '"$title" dikembalikan. Biaya yang belum dibayar: Rp$fine.'
        : '"$title" dikembalikan tanpa denda.');
  }

  /// Denda saat ini. Pinjaman aktif dihitung ulang; yang sudah kembali
  /// memakai biaya yang tercatat saat pengembalian (peraturan 7).
  int calculateFine(Loan loan) =>
      loan.isActive ? _computeFine(loan, _clock()) : loan.unpaidFine;

  int _computeFine(Loan loan, DateTime asOf) {
    if (FinePolicy.isLost(loan.dueDate, asOf)) {
      return bookById(loan.bookId)?.replacementPrice ?? 0; // harga pengganti
    }
    return FinePolicy.weeklyFine(loan.dueDate, asOf);
  }

  int completedLateWeeks(Loan loan) => FinePolicy.completedLateWeeks(
      loan.dueDate, loan.returnDate ?? _clock());

  LoanStatus getOverdueStatus(Loan loan) {
    if (!loan.isActive) return LoanStatus.returned;
    final now = _clock();
    if (FinePolicy.isLost(loan.dueDate, now)) return LoanStatus.lost;
    if (FinePolicy.daysBetween(loan.dueDate, now) > 0) {
      return LoanStatus.overdue;
    }
    return LoanStatus.active;
  }

  BookDisplayStatus statusOfBook(Book book) {
    if (book.isAvailable) return BookDisplayStatus.available;
    final loan = _activeLoanForBook(book.id);
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

  void _setAvailability(String bookId, bool available) {
    final i = _books.indexWhere((b) => b.id == bookId);
    if (i != -1) _books[i] = _books[i].copyWith(isAvailable: available);
  }
}