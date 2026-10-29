import 'package:flutter/material.dart';

import 'viewmodels/library_view_model.dart';
import 'views/library_screen.dart';

void main() => runApp(const LibraryApp(viewModel: null,));

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key, required LibraryViewModel viewModel});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final LibraryViewModel _viewModel = LibraryViewModel(
    book: buildSampleBook(),
    loan: buildSampleLoan(DateTime.now()), service: null,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sistem Perpustakaan Universitas',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: LibraryScreen(viewModel: _viewModel),
  );
}

