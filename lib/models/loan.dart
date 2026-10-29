/// Model: catatan peminjaman. Hanya menyimpan data.
class Loan {
  final String id;
  final String bookId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate; // null = masih dipinjam
  final int unpaidFine; // denda yang belum dibayar (diisi saat pengembalian)

  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.unpaidFine = 0,
  });

  bool get isActive => returnDate == null;

  Loan copyWith({DateTime? returnDate, int? unpaidFine}) => Loan(
        id: id,
        bookId: bookId,
        studentId: studentId,
        borrowDate: borrowDate,
        dueDate: dueDate,
        returnDate: returnDate ?? this.returnDate,
        unpaidFine: unpaidFine ?? this.unpaidFine,
      );
}