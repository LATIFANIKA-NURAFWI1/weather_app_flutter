import 'current_weather_model.dart';
import 'daily_forecast_model.dart';

/// Model gabungan cuaca: current + daily forecast
/// Digunakan oleh WeatherViewModel sebagai data utama
class WeatherModel {
  final CurrentWeatherModel current;
  final List<DailyForecastModel> daily;

  const WeatherModel({required this.current, required this.daily});

  /// Parsing dari response lengkap Forecast API
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      current: CurrentWeatherModel.fromJson(
        json['current'] as Map<String, dynamic>,
      ),
      daily: DailyForecastModel.fromDailyJson(
        json['daily'] as Map<String, dynamic>,
      ),
    );
  }

  /// Ambil peluang hujan hari ini dari daily forecast pertama
  /// Digunakan di Home Screen sebagai info cuaca hari ini
  int? get todayPrecipitationProbability {
    if (daily.isNotEmpty) {
      return daily.first.precipitationProbability;
    }
    return null;
  }
}
