import 'package:flutter/material.dart';

/// Informasi cuaca: deskripsi Bahasa Indonesia + ikon Material + warna aksen
class WeatherInfo {
  final String description;
  final IconData icon;
  final Color iconColor;

  const WeatherInfo({
    required this.description,
    required this.icon,
    this.iconColor = Colors.white,
  });
}

/// Pemetaan WMO weather_code → deskripsi dan ikon persis dengan desain HTML
class WeatherCodeMapper {
  WeatherCodeMapper._();

  static const Map<int, WeatherInfo> _weatherMap = {
    // Cerah
    0: WeatherInfo(
      description: 'Cerah',
      icon: Icons.wb_sunny_rounded,
      iconColor: Color(0xFFFFD54F),
    ),
    // Berawan sebagian
    1: WeatherInfo(
      description: 'Cerah Berawan',
      icon: Icons.wb_cloudy_rounded,
      iconColor: Color(0xFFBAE6FD),
    ),
    2: WeatherInfo(
      description: 'Berawan Sebagian',
      icon: Icons.cloud_outlined,
      iconColor: Color(0xFFBAE6FD),
    ),
    3: WeatherInfo(
      description: 'Berawan',
      icon: Icons.cloud,
      iconColor: Color(0xFFBAE6FD),
    ),
    // Berkabut
    45: WeatherInfo(
      description: 'Berkabut',
      icon: Icons.foggy,
      iconColor: Color(0xFFA5F3FC),
    ),
    48: WeatherInfo(
      description: 'Kabut Tebal',
      icon: Icons.foggy,
      iconColor: Color(0xFFA5F3FC),
    ),
    // Gerimis
    51: WeatherInfo(
      description: 'Gerimis Ringan',
      icon: Icons.grain,
      iconColor: Color(0xFFA5F3FC),
    ),
    53: WeatherInfo(
      description: 'Gerimis Sedang',
      icon: Icons.grain,
      iconColor: Color(0xFFA5F3FC),
    ),
    55: WeatherInfo(
      description: 'Gerimis Lebat',
      icon: Icons.grain,
      iconColor: Color(0xFFA5F3FC),
    ),
    56: WeatherInfo(
      description: 'Gerimis Beku Ringan',
      icon: Icons.ac_unit,
      iconColor: Color(0xFFA5F3FC),
    ),
    57: WeatherInfo(
      description: 'Gerimis Beku Lebat',
      icon: Icons.ac_unit,
      iconColor: Color(0xFFA5F3FC),
    ),
    // Hujan
    61: WeatherInfo(
      description: 'Hujan Ringan',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    63: WeatherInfo(
      description: 'Hujan Sedang',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    65: WeatherInfo(
      description: 'Hujan Lebat',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    66: WeatherInfo(
      description: 'Hujan Beku Ringan',
      icon: Icons.ac_unit,
      iconColor: Color(0xFF93C5FD),
    ),
    67: WeatherInfo(
      description: 'Hujan Beku Lebat',
      icon: Icons.ac_unit,
      iconColor: Color(0xFF93C5FD),
    ),
    // Salju
    71: WeatherInfo(
      description: 'Salju Ringan',
      icon: Icons.ac_unit,
      iconColor: Colors.white,
    ),
    73: WeatherInfo(
      description: 'Salju Sedang',
      icon: Icons.ac_unit,
      iconColor: Colors.white,
    ),
    75: WeatherInfo(
      description: 'Salju Lebat',
      icon: Icons.ac_unit,
      iconColor: Colors.white,
    ),
    77: WeatherInfo(
      description: 'Butiran Salju',
      icon: Icons.ac_unit,
      iconColor: Colors.white,
    ),
    // Hujan lebat sesaat
    80: WeatherInfo(
      description: 'Hujan Sesaat Ringan',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    81: WeatherInfo(
      description: 'Hujan Sesaat Sedang',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    82: WeatherInfo(
      description: 'Hujan Sesaat Lebat',
      icon: Icons.water_drop,
      iconColor: Color(0xFF93C5FD),
    ),
    // Badai petir
    95: WeatherInfo(
      description: 'Badai Petir',
      icon: Icons.flash_on,
      iconColor: Color(0xFFFCD34D),
    ),
    96: WeatherInfo(
      description: 'Badai Petir + Hujan Es',
      icon: Icons.flash_on,
      iconColor: Color(0xFFFCD34D),
    ),
    99: WeatherInfo(
      description: 'Badai Petir Lebat',
      icon: Icons.flash_on,
      iconColor: Color(0xFFFCD34D),
    ),
  };

  static const WeatherInfo _fallback = WeatherInfo(
    description: 'Tidak Diketahui',
    icon: Icons.help_outline,
    iconColor: Colors.white70,
  );

  static WeatherInfo getWeatherInfo(int code) {
    return _weatherMap[code] ?? _fallback;
  }

  static String getDescription(int code) {
    return getWeatherInfo(code).description;
  }

  static IconData getIcon(int code) {
    return getWeatherInfo(code).icon;
  }
}
