import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/enums/view_state.dart';
import '../models/location_model.dart';
import '../repositories/weather_repository.dart';

/// ViewModel untuk Search Screen
/// Mengelola: pencarian kota, favorit, dan riwayat pencarian
class SearchViewModel extends ChangeNotifier {
  final WeatherRepository repository;

  SearchViewModel({required this.repository}) {
    loadLocalData();
  }

  // === State Pencarian ===
  ViewState _searchState = ViewState.initial;
  ViewState get searchState => _searchState;

  List<LocationModel> _searchResults = [];
  List<LocationModel> get searchResults => _searchResults;

  String _searchError = '';
  String get searchError => _searchError;

  // === Timer untuk debounce ===
  Timer? _debounceTimer;

  // === Favorit & Riwayat ===
  List<LocationModel> _favorites = [];
  List<LocationModel> get favorites => _favorites;

  List<LocationModel> _searchHistory = [];
  List<LocationModel> get searchHistory => _searchHistory;

  /// Muat data favorit dan riwayat dari penyimpanan lokal
  void loadLocalData() {
    _favorites = repository.getFavorites();
    _searchHistory = repository.getSearchHistory();
    notifyListeners();
  }

  /// Cari lokasi dengan debounce 500ms
  /// Setiap ketikan baru membatalkan timer sebelumnya
  void searchWithDebounce(String query) {
    // Batalkan timer sebelumnya
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = ViewState.initial;
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    notifyListeners();

    // Set timer baru 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  /// Eksekusi pencarian ke Geocoding API
  Future<void> _performSearch(String query) async {
    try {
      final results = await repository.searchLocation(query);

      if (results.isEmpty) {
        _searchState = ViewState.empty;
        _searchResults = [];
      } else {
        _searchState = ViewState.success;
        _searchResults = results;
      }
    } on SocketException catch (e) {
      _searchState = ViewState.error;
      _searchError = e.message;
    } on TimeoutException {
      _searchState = ViewState.error;
      _searchError =
          'Koneksi timeout. Server tidak merespons. Coba lagi nanti.';
    } on FormatException catch (e) {
      _searchState = ViewState.error;
      _searchError = e.message;
    } catch (e) {
      _searchState = ViewState.error;
      _searchError = 'Terjadi kesalahan: ${e.toString()}';
    }

    notifyListeners();
  }

  // ======================= FAVORIT =======================

  /// Toggle favorit: tambah jika belum ada, hapus jika sudah ada
  Future<void> toggleFavorite(LocationModel location) async {
    if (repository.isFavorite(location)) {
      await repository.removeFavorite(location);
    } else {
      await repository.addFavorite(location);
    }
    // Reload data favorit
    _favorites = repository.getFavorites();
    notifyListeners();
  }

  /// Cek apakah lokasi ada di favorit
  bool isFavorite(LocationModel location) {
    return repository.isFavorite(location);
  }

  /// Hapus satu favorit (untuk swipe-to-dismiss)
  Future<void> removeFavorite(LocationModel location) async {
    await repository.removeFavorite(location);
    _favorites = repository.getFavorites();
    notifyListeners();
  }

  // ======================= RIWAYAT =======================

  /// Tambah lokasi ke riwayat pencarian
  Future<void> addToHistory(LocationModel location) async {
    await repository.addToHistory(location);
    _searchHistory = repository.getSearchHistory();
    notifyListeners();
  }

  /// Hapus semua riwayat pencarian
  Future<void> clearHistory() async {
    await repository.clearHistory();
    _searchHistory = [];
    notifyListeners();
  }

  /// Bersihkan timer saat ViewModel di-dispose
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
