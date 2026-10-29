/// Model: data buku. Tidak boleh berisi widget Flutter atau BuildContext.
class Book {
  final String id;
  final String title;
  final String author;
  final int replacementPrice; // harga penggantian (Rp)
  final bool isAvailable; // ketersediaan

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.isAvailable = true,
  });

  Book copyWith({bool? isAvailable}) => Book(
        id: id,
        title: title,
        author: author,
        replacementPrice: replacementPrice,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}