
class DailyForecastModel {
  final String date; // Format: "2024-01-15"
  final int weatherCode; // WMO weather code
  final double tempMax; // temperature_2m_max (°C)
  final double tempMin; // temperature_2m_min (°C)
  final int?
  precipitationProbability; // precipitation_probability_max (%) - bisa null

  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    this.precipitationProbability,
  });

  static List<DailyForecastModel> fromDailyJson(Map<String, dynamic> daily) {
    final times = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>;
    final minTemps = daily['temperature_2m_min'] as List<dynamic>;
    final precipProbs =
        daily['precipitation_probability_max'] as List<dynamic>?;

    final List<DailyForecastModel> forecasts = [];
    for (int i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecastModel(
          date: times[i] as String,
          weatherCode: (codes[i] as num).toInt(),
          tempMax: (maxTemps[i] as num).toDouble(),
          tempMin: (minTemps[i] as num).toDouble(),
          // Antisipasi null pada precipitation_probability_max
          precipitationProbability:
              precipProbs != null && i < precipProbs.length
              ? (precipProbs[i] as num?)?.toInt()
              : null,
        ),
      );
    }
    return forecasts;
  }
}
