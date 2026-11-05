1. What is the difference between the Model, View, and ViewModel in this application?

Model hanya menyimpan data (Book dan Loan). ViewModel (LibraryViewModel) membuat keputusan: apakah buku boleh dipinjam, berapa dendanya, dan apa statusnya. View hanya menampilkan hasilnya dan meneruskan aksi pengguna (tombol Pinjam dan Kembalikan) ke ViewModel.

2. What should happen if a student attempts to borrow a book that already has an active loan?

Peminjaman harus ditolak. borrowBook() di ViewModel mengembalikan pesan "Buku ini sudah memiliki pinjaman aktif." dan tidak mengubah data apa pun, lalu View hanya menampilkan pesan itu lewat SnackBar.

3. Why is it better to calculate the fine in one place rather than repeating the formula in multiple widgets?

Kalau rumus disalin ke banyak widget, hasilnya bisa berbeda-beda dan setiap salinan harus diubah saat aturan berubah. Dengan satu tempat (FineCalculator), semua layar menampilkan angka yang sama dan perbaikan cukup dilakukan sekali.

4. What is the difference between a book being Overdue and being Missing?

Overdue (Terlambat) berarti tanggal jatuh tempo sudah lewat dan dendanya Rp5.000 untuk setiap minggu penuh keterlambatan. Missing (Hilang) berarti sudah enam bulan kalender sejak jatuh tempo, dan mahasiswa membayar harga penggantian buku sepenuhnya (replacementPrice), bukan denda mingguan.

5. If the university changes its weekly fine from Rp5,000 to Rp7,000, how should the app be updated?

Ubah satu nilai di lib/viewmodels/fine_calculator.dart: finePerWeek = 7000. Tampilan ikut menyesuaikan tanpa perubahan lain, dan angka yang diharapkan di test/widget_test.dart perlu disesuaikan dengan tarif baru.