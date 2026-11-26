import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/geocoding_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService weatherApiService;
  final GeocodingApiService geocodingApiService;
  final LocalStorageService localStorageService;

  WeatherRepository({
    required this.weatherApiService,
    required this.geocodingApiService,
    required this.localStorageService,
  });

  // ======================= CUACA =======================

  /// Ambil data cuaca berdasarkan koordinat
  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) {
    return weatherApiService.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ======================= GEOCODING =======================

  /// Cari lokasi berdasarkan nama kota
  Future<List<LocationModel>> searchLocation(String query) {
    return geocodingApiService.searchLocation(query);
  }

  // ======================= FAVORIT =======================

  List<LocationModel> getFavorites() => localStorageService.getFavorites();

  Future<void> addFavorite(LocationModel location) =>
      localStorageService.addFavorite(location);

  Future<void> removeFavorite(LocationModel location) =>
      localStorageService.removeFavorite(location);

  bool isFavorite(LocationModel location) =>
      localStorageService.isFavorite(location);

  // ======================= RIWAYAT =======================

  List<LocationModel> getSearchHistory() =>
      localStorageService.getSearchHistory();

  Future<void> addToHistory(LocationModel location) =>
      localStorageService.addToHistory(location);

  Future<void> clearHistory() => localStorageService.clearHistory();

  // ======================= LOKASI TERAKHIR =======================

  Future<void> saveLastLocation(LocationModel location) =>
      localStorageService.saveLastLocation(location);

  LocationModel? getLastLocation() => localStorageService.getLastLocation();
}
