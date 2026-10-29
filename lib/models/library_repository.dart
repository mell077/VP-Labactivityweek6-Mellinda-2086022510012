import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'book.dart';
import 'loan.dart';

/// Kumpulan data awal hasil pembacaan JSON.
class LibraryData {
  final List<Book> books;
  final List<Loan> loans;
  const LibraryData({required this.books, required this.loans});
}

/// Membaca data buku dan pinjaman dari assets/data/books.json.
class LibraryRepository {
  final String assetPath;
  const LibraryRepository({this.assetPath = 'assets/data/books.json'});

  Future<LibraryData> load({DateTime? today}) async {
    final raw = await rootBundle.loadString(assetPath);
    return parse(raw, today: today ?? DateTime.now());
  }

  /// Dipisahkan dari [load] agar mudah diuji tanpa membaca file asset.
  static LibraryData parse(String rawJson, {required DateTime today}) {
    final map = jsonDecode(rawJson) as Map<String, dynamic>;
    final books = (map['books'] as List)
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
    final loans = ((map['loans'] as List?) ?? const [])
        .map((e) => Loan.fromJson(e as Map<String, dynamic>, today))
        .toList();
    return LibraryData(books: books, loans: loans);
  }
}