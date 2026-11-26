import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/weather_code_mapper.dart';
import '../../models/daily_forecast_model.dart';

/// Baris harian di dalam SevenDayForecastGlassCard
/// Baris "Hari Ini" diberi highlight khusus (glass-highlight)
class ForecastTile extends StatelessWidget {
  final DailyForecastModel forecast;
  final bool isToday;

  const ForecastTile({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(forecast.date) ?? DateTime.now();
    final dayName = isToday ? 'Hari Ini' : DateFormat('EEEE', 'id_ID').format(date);
    final dateStr = DateFormat('d MMM', 'id_ID').format(date);
    final weatherInfo = WeatherCodeMapper.getWeatherInfo(forecast.weatherCode);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isToday ? 10 : 8,
      ),
      child: Row(
        children: [
          // Hari & Tanggal
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday
                        ? Colors.white
                        : const Color.fromRGBO(255, 255, 255, 0.90),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w500 : FontWeight.normal,
                    color: isToday
                        ? const Color(0xFFBAE6FD)
                        : const Color.fromRGBO(255, 255, 255, 0.50),
                  ),
                ),
              ],
            ),
          ),

          // Icon & Deskripsi Kondisi
          Expanded(
            child: Row(
              children: [
                Icon(
                  weatherInfo.icon,
                  size: 16,
                  color: weatherInfo.iconColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    weatherInfo.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? Colors.white
                          : const Color.fromRGBO(255, 255, 255, 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Peluang Hujan (💧 %) - Dibuat kontras tinggi & jelas terbaca
          if (forecast.precipitationProbability != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(56, 189, 248, 0.22),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color.fromRGBO(125, 211, 252, 0.40),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 11,
                    color: Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${forecast.precipitationProbability}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0F2FE), // Putih kebiruan terang, sangat kontras & terbaca jelas
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 10),

          // Suhu Max / Min
          Text(
            '${forecast.tempMax.toInt()}° / ${forecast.tempMin.toInt()}°',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isToday
                  ? Colors.white
                  : const Color.fromRGBO(255, 255, 255, 0.90),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );

    if (isToday) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.32),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(255, 255, 255, 0.10),
              offset: Offset(0, 1),
              blurRadius: 1,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
