
class CurrentWeatherModel {
  final double temperature; // temperature_2m (°C)
  final int humidity; // relative_humidity_2m (%)
  final double apparentTemp; // apparent_temperature (°C)
  final double precipitation; // precipitation (mm)
  final int weatherCode; // weather_code (WMO)
  final double windSpeed; // wind_speed_10m (km/h)

  const CurrentWeatherModel({
    required this.temperature,
    required this.humidity,
    required this.apparentTemp,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemp: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}
