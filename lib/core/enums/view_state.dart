/// Enum untuk merepresentasikan state tampilan
/// Digunakan oleh ViewModel untuk mengelola status data
enum ViewState {
  /// State awal, belum ada aksi
  initial,

  /// Sedang memuat data dari API
  loading,

  /// Data berhasil dimuat
  success,

  /// Data kosong (misalnya kota tidak ditemukan)
  empty,

  /// Terjadi error (tidak ada internet, timeout, dll)
  error,
}
