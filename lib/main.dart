import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'services/geocoding_api_service.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

/// Entry point aplikasi Cuaca Kita
/// Inisialisasi: format tanggal lokal, SharedPreferences, lalu jalankan app
void main() async {
  // Pastikan binding Flutter siap sebelum async call
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Bahasa Indonesia (id_ID)
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi local storage (SharedPreferences)
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Buat instance service dan repository
  final weatherApiService = WeatherApiService();
  final geocodingApiService = GeocodingApiService();

  final repository = WeatherRepository(
    weatherApiService: weatherApiService,
    geocodingApiService: geocodingApiService,
    localStorageService: localStorageService,
  );

  runApp(CuacaKitaApp(repository: repository));
}

/// Widget root aplikasi dengan MultiProvider
/// Provider digunakan untuk state management (ChangeNotifier)
class CuacaKitaApp extends StatelessWidget {
  final WeatherRepository repository;

  const CuacaKitaApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModel cuaca: mengelola data cuaca dan lokasi terpilih
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(repository: repository),
        ),
        // ViewModel pencarian: mengelola search, favorit, riwayat
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Cuaca Kita',
        debugShowCheckedModeBanner: false,
        // Tema Glassmorphism Dark Theme persis sesuai desain HTML/Tailwind
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
