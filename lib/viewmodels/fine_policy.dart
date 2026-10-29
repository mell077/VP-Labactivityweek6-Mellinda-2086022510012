/// Kebijakan denda terpusat di satu tempat (aturan 6) dan
/// perhitungan tanggal yang konsisten berbasis tanggal kalender (aturan 7).
class FinePolicy {
  static const int finePerWeek = 5000; // Rp per minggu terlambat yang selesai
  static const int loanDurationDays = 14; // lama peminjaman standar
  static const int lostAfterMonths = 6; // batas buku dinyatakan Hilang

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Selisih hari kalender (to - from), aman dari pengaruh DST/jam.
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// Tambah bulan kalender; hari dijepit ke akhir bulan (31 Agu + 6 bln = 28/29 Feb).
  static DateTime addMonths(DateTime date, int months) {
    final total = date.month - 1 + months;
    final year = date.year + (total / 12).floor();
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day > lastDay ? lastDay : date.day);
  }

  static DateTime lostDate(DateTime dueDate) =>
      addMonths(dateOnly(dueDate), lostAfterMonths);

  /// Pada atau setelah tanggal ambang enam bulan => Hilang.
  static bool isLost(DateTime dueDate, DateTime asOf) =>
      !dateOnly(asOf).isBefore(lostDate(dueDate));

  /// Hanya minggu yang SUDAH SELESAI terlambat yang dihitung.
  static int completedLateWeeks(DateTime dueDate, DateTime asOf) {
    final days = daysBetween(dueDate, asOf);
    return days <= 0 ? 0 : days ~/ 7;
  }

  static int weeklyFine(DateTime dueDate, DateTime asOf) =>
      completedLateWeeks(dueDate, asOf) * finePerWeek;
}