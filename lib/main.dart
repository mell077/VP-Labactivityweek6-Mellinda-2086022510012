import 'package:flutter/material.dart';

import 'models/library_repository.dart';
import 'models/library_service.dart';
import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Data dibaca dari assets/data/books.json lewat repository (Model).
    final data = await const LibraryRepository().load();
    final viewModel = LibraryViewModel(
      service: LibraryService(books: data.books, loans: data.loans),
    );
    runApp(LibraryApp(viewModel: viewModel));
  } catch (e, st) {
    // Tampilkan penyebab error di layar agar mudah dilacak.
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Gagal memuat data')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText('$e\n\n$st'),
        ),
      ),
    ));
  }
}

class LibraryApp extends StatelessWidget {
  final LibraryViewModel viewModel;
  const LibraryApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sistem Perpustakaan Universitas',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: LibraryScreen(viewModel: viewModel),
      );
}