import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/utils/weather_code_mapper.dart';
import '../../models/current_weather_model.dart';

/// Widget Hero Cuaca dan 2x2 Glass Grid Metrics
/// Mengimplementasikan persis desain HTML/Tailwind:
/// - Condition Pill
/// - Huge Minimalist Temperature (82px)
/// - Subtitle Terasa Seperti
/// - 2x2 Glass Card: Kelembapan, Curah Hujan, Angin, Peluang Hujan
class CurrentWeatherCard extends StatelessWidget {
  final CurrentWeatherModel weather;
  final int? precipitationProbability;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.precipitationProbability,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = WeatherCodeMapper.getWeatherInfo(weather.weatherCode);

    return Column(
      children: [
        // === Hero Weather Overview ===
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Column(
            children: [
              // Condition Pill with Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.20),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          weatherInfo.icon,
                          size: 18,
                          color: weatherInfo.iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          weatherInfo.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(255, 255, 255, 0.95),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Huge Minimal Temperature (82px)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.temperature.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 82,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 1),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w300,
                        color: Color.fromRGBO(255, 255, 255, 0.90),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // Feels like summary
              Text.rich(
                TextSpan(
                  text: 'Terasa seperti ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(255, 255, 255, 0.75),
                  ),
                  children: [
                    TextSpan(
                      text: '${weather.apparentTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(255, 255, 255, 0.90),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // === 2x2 Weather Metrics Glass Card ===
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.14),
                borderRadius: BorderRadius.circular(26),
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
              child: Row(
                children: [
                  // Column 1: Kelembapan & Curah Hujan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricItem(
                          icon: Icons.water_drop,
                          iconColor: const Color(0xFF93C5FD),
                          badgeBg: const Color.fromRGBO(96, 165, 250, 0.20),
                          badgeBorder: const Color.fromRGBO(147, 197, 253, 0.30),
                          label: 'KELEMBAPAN',
                          value: '${weather.humidity}%',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            height: 1,
                            color: const Color.fromRGBO(255, 255, 255, 0.10),
                          ),
                        ),
                        _buildMetricItem(
                          icon: Icons.umbrella_outlined,
                          iconColor: const Color(0xFFD8B4FE),
                          badgeBg: const Color.fromRGBO(192, 132, 252, 0.20),
                          badgeBorder: const Color.fromRGBO(216, 180, 254, 0.30),
                          label: 'CURAH HUJAN',
                          value: '${weather.precipitation.toStringAsFixed(1)} mm',
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    color: const Color.fromRGBO(255, 255, 255, 0.15),
                  ),

                  // Column 2: Angin & Peluang Hujan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricItem(
                          icon: Icons.air,
                          iconColor: const Color(0xFF5EEAD4),
                          badgeBg: const Color.fromRGBO(45, 212, 191, 0.20),
                          badgeBorder: const Color.fromRGBO(94, 234, 212, 0.30),
                          label: 'ANGIN',
                          value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            height: 1,
                            color: const Color.fromRGBO(255, 255, 255, 0.10),
                          ),
                        ),
                        _buildMetricItem(
                          icon: Icons.percent,
                          iconColor: const Color(0xFFFCD34D),
                          badgeBg: const Color.fromRGBO(251, 191, 36, 0.20),
                          badgeBorder: const Color.fromRGBO(252, 211, 77, 0.30),
                          label: 'PELUANG HUJAN',
                          value: precipitationProbability != null
                              ? '$precipitationProbability%'
                              : '0%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
    required Color badgeBorder,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: badgeBg,
            shape: BoxShape.circle,
            border: Border.all(color: badgeBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(255, 255, 255, 0.70),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
