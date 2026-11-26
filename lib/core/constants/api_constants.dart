/// Konstanta URL dan parameter untuk API Open-Meteo
class ApiConstants {
  ApiConstants._(); // Mencegah instantiasi

  // === Geocoding API ===
  static const String geocodingBaseUrl = 'geocoding-api.open-meteo.com';
  static const String geocodingPath = '/v1/search';
  static const String geocodingCount = '10';
  static const String geocodingLanguage = 'id';

  // === Forecast API ===
  static const String forecastBaseUrl = 'api.open-meteo.com';
  static const String forecastPath = '/v1/forecast';

  /// Parameter current weather yang diminta dari API
  static const String currentParams =
      'temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m';

  /// Parameter daily forecast yang diminta dari API
  static const String dailyParams =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max';

  /// Jumlah hari prakiraan
  static const String forecastDays = '7';

  /// Timeout durasi untuk HTTP request (detik)
  static const int timeoutSeconds = 10;
}
