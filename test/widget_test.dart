import 'package:flutter_test/flutter_test.dart';

import 'package:lab_activity_week6/main.dart';

void main() {
  testWidgets('menampilkan layar perpustakaan, ringkasan, dan daftar buku',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LibraryApp());

    expect(find.text('Perpustakaan Universitas'), findsOneWidget);
    expect(find.text('ID Mahasiswa'), findsOneWidget);
    expect(find.text('Pemrograman Dart'), findsOneWidget);
    expect(find.text('Pinjam'), findsWidgets);
  });

  testWidgets('meminjam buku tersedia memperbarui UI', (WidgetTester tester) async {
    await tester.pumpWidget(const LibraryApp());

    // Buku pertama (B1) tersedia: tekan tombol Pinjam pertama.
    await tester.tap(find.text('Pinjam').first);
    await tester.pump();

    expect(find.text('"Pemrograman Dart" berhasil dipinjam.'), findsOneWidget);
  });
}