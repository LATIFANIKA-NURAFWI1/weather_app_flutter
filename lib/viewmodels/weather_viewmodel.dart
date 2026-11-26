import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/enums/view_state.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository repository;

  WeatherViewModel({required this.repository});

  // === State ===
  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  LocationModel? _selectedLocation;
  LocationModel? get selectedLocation => _selectedLocation;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadLastLocationAndWeather() async {
    final lastLocation = repository.getLastLocation();
    if (lastLocation != null && lastLocation.name != 'Purwokerto') {
      await selectLocation(lastLocation);
    } else {
      // Default: Kalimanah Kulon, Purbalingga (data cuaca tetap diambil nyata dari API)
      await selectLocation(
        const LocationModel(
          id: 1640001,
          name: 'Kalimanah Kulon',
          latitude: -7.4050,
          longitude: 109.3360,
          country: 'Indonesia',
          admin1: 'Purbalingga, Jawa Tengah',
        ),
      );
    }
  }

  /// Pilih lokasi dan ambil data cuacanya dari API
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _weather = await repository.getWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _state = ViewState.success;

      // Simpan sebagai lokasi terakhir
      await repository.saveLastLocation(location);
    } on SocketException catch (e) {
      _state = ViewState.error;
      _errorMessage = e.message;
    } on TimeoutException {
      _state = ViewState.error;
      _errorMessage =
          'Koneksi timeout. Server tidak merespons. Coba lagi nanti.';
    } on FormatException catch (e) {
      _state = ViewState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_selectedLocation != null) {
      await selectLocation(_selectedLocation!);
    }
  }

  bool isCurrentLocationFavorite() {
    if (_selectedLocation == null) return false;
    return repository.isFavorite(_selectedLocation!);
  }
}
