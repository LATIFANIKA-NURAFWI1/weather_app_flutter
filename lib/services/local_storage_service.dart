import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan SharedPreferences
/// Mengelola: favorit, riwayat pencarian, dan lokasi terakhir
class LocalStorageService {
  // Key untuk SharedPreferences
  static const String _favoritesKey = 'favorites';
  static const String _searchHistoryKey = 'search_history';
  static const String _lastLocationKey = 'last_location';

  /// Batas maksimal riwayat pencarian
  static const int maxHistory = 10;

  late SharedPreferences _prefs;

  /// Inisialisasi SharedPreferences (dipanggil saat startup)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Inisialisasi data awal jika belum pernah disimpan sama sekali
    // agar saat pertama kali membuka aplikasi, langsung terbukti ada data lokal tersimpan
    if (!_prefs.containsKey(_favoritesKey)) {
      const defaultFav = LocationModel(
        id: 1640001,
        name: 'Kalimanah Kulon',
        latitude: -7.4050,
        longitude: 109.3360,
        country: 'Indonesia',
        admin1: 'Purbalingga, Jawa Tengah',
      );
      await addFavorite(defaultFav);
    }

    if (!_prefs.containsKey(_searchHistoryKey)) {
      const defaultHist = LocationModel(
        id: 1640001,
        name: 'Kalimanah Kulon',
        latitude: -7.4050,
        longitude: 109.3360,
        country: 'Indonesia',
        admin1: 'Purbalingga, Jawa Tengah',
      );
      await addToHistory(defaultHist);
    }
  }

  // ======================= FAVORIT =======================

  /// Ambil semua lokasi favorit
  List<LocationModel> getFavorites() {
    final jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    final List<LocationModel> list = [];
    for (final str in jsonList) {
      try {
        list.add(LocationModel.fromJsonString(str));
      } catch (_) {}
    }
    return list;
  }

  /// Simpan lokasi ke favorit (cek duplikat berdasarkan lat+lon)
  Future<void> addFavorite(LocationModel location) async {
    final favorites = getFavorites();

    // Cek duplikat: perbandingan menggunakan operator == di LocationModel
    final isDuplicate = favorites.any((fav) => fav == location);
    if (isDuplicate) return; // Sudah ada, jangan tambahkan lagi

    favorites.add(location);
    await _saveFavorites(favorites);
  }

  /// Hapus lokasi dari favorit
  Future<void> removeFavorite(LocationModel location) async {
    final favorites = getFavorites();
    favorites.removeWhere((fav) => fav == location);
    await _saveFavorites(favorites);
  }

  /// Cek apakah lokasi ada di favorit
  bool isFavorite(LocationModel location) {
    final favorites = getFavorites();
    return favorites.any((fav) => fav == location);
  }

  /// Simpan list favorit ke SharedPreferences
  Future<void> _saveFavorites(List<LocationModel> favorites) async {
    final jsonList = favorites.map((e) => e.toJsonString()).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  // ======================= RIWAYAT PENCARIAN =======================

  /// Ambil riwayat pencarian
  List<LocationModel> getSearchHistory() {
    final jsonList = _prefs.getStringList(_searchHistoryKey) ?? [];
    final List<LocationModel> list = [];
    for (final str in jsonList) {
      try {
        list.add(LocationModel.fromJsonString(str));
      } catch (_) {}
    }
    return list;
  }

  /// Tambah lokasi ke riwayat pencarian
  /// Tanpa duplikat, maksimal 10 item, terbaru di awal
  Future<void> addToHistory(LocationModel location) async {
    final history = getSearchHistory();

    // Hapus duplikat jika sudah ada
    history.removeWhere((item) => item == location);

    // Tambahkan di awal (terbaru)
    history.insert(0, location);

    // Batasi maksimal 10 item
    if (history.length > maxHistory) {
      history.removeRange(maxHistory, history.length);
    }

    final jsonList = history.map((e) => e.toJsonString()).toList();
    await _prefs.setStringList(_searchHistoryKey, jsonList);
  }

  /// Hapus semua riwayat pencarian
  Future<void> clearHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // ======================= LOKASI TERAKHIR =======================

  /// Simpan lokasi terakhir yang dipilih
  Future<void> saveLastLocation(LocationModel location) async {
    await _prefs.setString(_lastLocationKey, location.toJsonString());
  }

  /// Ambil lokasi terakhir yang dipilih (null jika belum ada)
  LocationModel? getLastLocation() {
    final jsonString = _prefs.getString(_lastLocationKey);
    if (jsonString == null) return null;
    return LocationModel.fromJsonString(jsonString);
  }
}
