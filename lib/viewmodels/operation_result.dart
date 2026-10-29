/// Hasil sebuah aksi (pinjam/kembali) beserta pesan untuk ditampilkan.
class OperationResult {
  final bool success;
  final String message;
  const OperationResult.ok(this.message) : success = true;
  const OperationResult.fail(this.message) : success = false;
}