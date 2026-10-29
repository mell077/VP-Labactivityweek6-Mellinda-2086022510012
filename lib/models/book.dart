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

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        replacementPrice: json['replacementPrice'] as int,
        isAvailable: json['isAvailable'] as bool? ?? true,
      );

  Book copyWith({bool? isAvailable}) => Book(
        id: id,
        title: title,
        author: author,
        replacementPrice: replacementPrice,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}