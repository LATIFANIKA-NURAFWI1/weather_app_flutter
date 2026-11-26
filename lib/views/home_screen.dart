import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/enums/view_state.dart';
import '../core/theme/app_theme.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/forecast_tile.dart';
import 'widgets/loading_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().loadLastLocationAndWeather();
      context.read<SearchViewModel>().loadLocalData();
    });
  }

  Future<void> _openSearchScreen() async {
    if (!mounted) return;
    context.read<SearchViewModel>().loadLocalData();

    final selectedLocation = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );

    if (selectedLocation != null && mounted) {
      context.read<WeatherViewModel>().selectLocation(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, weatherVM, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.skyTop,
                  AppTheme.skyMid,
                  AppTheme.skyBottom,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Soft Ambient Radial Glow Backdrop behind Hero
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 320,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color.fromRGBO(147, 197, 253, 0.32),
                            Color.fromRGBO(59, 130, 246, 0.12),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.45, 0.70],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // App Bar Header
                      _buildHeader(context, weatherVM),

                      // Weather Body
                      Expanded(
                        child: _buildBody(context, weatherVM),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WeatherViewModel weatherVM) {
    final location = weatherVM.selectedLocation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: App Name + Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.cloud,
                      size: 20,
                      color: AppTheme.skyLight,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Cuaca Kita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.skyAccent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location != null
                            ? location.displayName
                            : 'Memuat lokasi...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(255, 255, 255, 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: 3 Frosted Glass Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Star Favorite Button
              if (location != null)
                Consumer<SearchViewModel>(
                  builder: (context, searchVM, _) {
                    final isFav = searchVM.isFavorite(location);
                    return _buildGlassButton(
                      icon: isFav ? Icons.star : Icons.star_border,
                      iconColor: isFav ? AppTheme.goldAccent : Colors.white,
                      tooltip: isFav ? 'Hapus Favorit' : 'Simpan Favorit',
                      onPressed: () async {
                        await searchVM.toggleFavorite(location);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFav
                                    ? '${location.name} dihapus dari favorit'
                                    : '⭐ ${location.name} ditambahkan ke favorit',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              const SizedBox(width: 8),

              // 2. Search Button
              _buildGlassButton(
                icon: Icons.search,
                iconColor: Colors.white,
                tooltip: 'Cari Lokasi',
                onPressed: _openSearchScreen,
              ),
              const SizedBox(width: 8),

              // 3. Refresh Button
              _buildGlassButton(
                icon: Icons.refresh,
                iconColor: Colors.white,
                tooltip: 'Perbarui Cuaca',
                onPressed: weatherVM.state == ViewState.loading
                    ? null
                    : weatherVM.refreshWeather,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required Color iconColor,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.28),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVM) {
    switch (weatherVM.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const LoadingView();

      case ViewState.error:
        return ErrorView(
          message: weatherVM.errorMessage,
          onRetry: weatherVM.refreshWeather,
        );

      case ViewState.empty:
        return const EmptyView(
          message: 'Data cuaca tidak tersedia',
          submessage: 'Silakan pilih kota lain',
        );

      case ViewState.success:
        return _buildWeatherList(context, weatherVM);
    }
  }

  Widget _buildWeatherList(BuildContext context, WeatherViewModel weatherVM) {
    final weather = weatherVM.weather!;
    final locationName = weatherVM.selectedLocation?.name ?? 'Lokasi';

    return RefreshIndicator(
      onRefresh: weatherVM.refreshWeather,
      color: AppTheme.skyLight,
      backgroundColor: AppTheme.skyMid,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Hero Weather + 2x2 Metrics Grid
          CurrentWeatherCard(
            weather: weather.current,
            precipitationProbability: weather.todayPrecipitationProbability,
          ),

          const SizedBox(height: 16),

          // Forecast Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.skyAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Prakiraan 7 Hari',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 255, 255, 0.95),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                locationName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color.fromRGBO(255, 255, 255, 0.50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Unified Sleek Glass Container for 7-Day Forecast
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.22),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.22),
                      blurRadius: 36,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < weather.daily.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 1,
                          color: const Color.fromRGBO(255, 255, 255, 0.10),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ForecastTile(
                        forecast: weather.daily[i],
                        isToday: i == 0,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subtle footer note
          const Center(
            child: Text(
              'Data langsung dari Open-Meteo REST API',
              style: TextStyle(
                fontSize: 11,
                color: Color.fromRGBO(255, 255, 255, 0.40),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
