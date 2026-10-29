import 'book.dart';
import 'loan.dart';

/// Penyimpanan data di memori (tanpa database). Hanya menyimpan, mencari,
/// dan memperbarui data. Keputusan bisnis ada di ViewModel.
class LibraryService {
  LibraryService({required List<Book> books, List<Loan> loans = const []})
      : _books = List.of(books),
        _loans = List.of(loans);

  final List<Book> _books;
  final List<Loan> _loans;

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);

  Book? findBook(String id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  Loan? findLoan(String id) {
    for (final l in _loans) {
      if (l.id == id) return l;
    }
    return null;
  }

  Loan? activeLoanForBook(String bookId) {
    for (final l in _loans) {
      if (l.bookId == bookId && l.isActive) return l;
    }
    return null;
  }

  String nextLoanId() {
    var n = _loans.length + 1;
    while (findLoan('L$n') != null) {
      n++;
    }
    return 'L$n';
  }

  void addLoan(Loan loan) => _loans.add(loan);

  void replaceLoan(Loan loan) {
    final i = _loans.indexWhere((l) => l.id == loan.id);
    if (i != -1) _loans[i] = loan;
  }

  void setAvailability(String bookId, bool available) {
    final i = _books.indexWhere((b) => b.id == bookId);
    if (i != -1) _books[i] = _books[i].copyWith(isAvailable: available);
  }
}