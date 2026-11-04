import 'package:flutter/material.dart';

import 'models/library_repository.dart';
import 'models/library_service.dart';
import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Data dibaca dari assets/data/books.json lewat repository (Model).
  final data = await const LibraryRepository().load();
  final viewModel = LibraryViewModel(
    service: LibraryService(books: data.books, loans: data.loans),
  );

  runApp(LibraryApp(viewModel: viewModel));
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