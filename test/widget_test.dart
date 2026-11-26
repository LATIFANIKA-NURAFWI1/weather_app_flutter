import 'package:flutter_test/flutter_test.dart';

import 'package:weather99/models/location_model.dart';
import 'package:weather99/models/current_weather_model.dart';
import 'package:weather99/models/daily_forecast_model.dart';
import 'package:weather99/models/weather_model.dart';
import 'package:weather99/core/utils/weather_code_mapper.dart';

/// Unit test untuk parsing model dan utilitas
/// Memastikan data dari JSON API diparsing dengan benar
void main() {
  // ======================= LocationModel =======================
  group('LocationModel', () {
    test('fromJson membuat objek dengan benar', () {
      final json = {
        'id': 1630084,
        'name': 'Purwokerto',
        'latitude': -7.4281,
        'longitude': 109.2347,
        'country': 'Indonesia',
        'admin1': 'Jawa Tengah',
        'timezone': 'Asia/Jakarta',
      };

      final location = LocationModel.fromJson(json);

      expect(location.id, 1630084);
      expect(location.name, 'Purwokerto');
      expect(location.latitude, -7.4281);
      expect(location.longitude, 109.2347);
      expect(location.country, 'Indonesia');
      expect(location.admin1, 'Jawa Tengah');
      expect(location.timezone, 'Asia/Jakarta');
    });

    test('fromJson menangani admin1 null', () {
      final json = {
        'id': 123,
        'name': 'Kota',
        'latitude': 0.0,
        'longitude': 0.0,
        'country': 'Negara',
      };

      final location = LocationModel.fromJson(json);
      expect(location.admin1, isNull);
    });

    test('toJson dan fromJsonString roundtrip', () {
      const original = LocationModel(
        id: 1,
        name: 'Jakarta',
        latitude: -6.2,
        longitude: 106.8,
        country: 'Indonesia',
        admin1: 'DKI Jakarta',
      );

      final jsonString = original.toJsonString();
      final restored = LocationModel.fromJsonString(jsonString);

      expect(restored.name, original.name);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
    });

    test('displayName dengan admin1', () {
      const loc = LocationModel(
        id: 1,
        name: 'Purwokerto',
        latitude: -7.4,
        longitude: 109.2,
        country: 'Indonesia',
        admin1: 'Jawa Tengah',
      );
      expect(loc.displayName, 'Purwokerto, Jawa Tengah, Indonesia');
    });

    test('displayName tanpa admin1', () {
      const loc = LocationModel(
        id: 1,
        name: 'Purwokerto',
        latitude: -7.4,
        longitude: 109.2,
        country: 'Indonesia',
      );
      expect(loc.displayName, 'Purwokerto, Indonesia');
    });

    test('equality berdasarkan lat+lon', () {
      const a = LocationModel(
        id: 1,
        name: 'A',
        latitude: 1.0,
        longitude: 2.0,
        country: 'X',
      );
      const b = LocationModel(
        id: 2,
        name: 'B',
        latitude: 1.0,
        longitude: 2.0,
        country: 'Y',
      );
      const c = LocationModel(
        id: 1,
        name: 'A',
        latitude: 3.0,
        longitude: 2.0,
        country: 'X',
      );

      expect(a == b, isTrue); // Sama lat+lon
      expect(a == c, isFalse); // Beda lat
    });
  });

  // ======================= CurrentWeatherModel =======================
  group('CurrentWeatherModel', () {
    test('fromJson membuat objek dengan benar', () {
      final json = {
        'temperature_2m': 28.5,
        'relative_humidity_2m': 75,
        'apparent_temperature': 30.1,
        'precipitation': 0.0,
        'weather_code': 3,
        'wind_speed_10m': 12.3,
      };

      final weather = CurrentWeatherModel.fromJson(json);

      expect(weather.temperature, 28.5);
      expect(weather.humidity, 75);
      expect(weather.apparentTemp, 30.1);
      expect(weather.precipitation, 0.0);
      expect(weather.weatherCode, 3);
      expect(weather.windSpeed, 12.3);
    });

    test('fromJson menangani int sebagai double', () {
      final json = {
        'temperature_2m': 28, // int bukan double
        'relative_humidity_2m': 75,
        'apparent_temperature': 30,
        'precipitation': 0,
        'weather_code': 3,
        'wind_speed_10m': 12,
      };

      final weather = CurrentWeatherModel.fromJson(json);
      expect(weather.temperature, 28.0);
      expect(weather.windSpeed, 12.0);
    });
  });

  // ======================= DailyForecastModel =======================
  group('DailyForecastModel', () {
    test('fromDailyJson membuat list objek dengan benar', () {
      final dailyJson = {
        'time': ['2024-01-15', '2024-01-16', '2024-01-17'],
        'weather_code': [0, 3, 61],
        'temperature_2m_max': [30.0, 28.5, 25.0],
        'temperature_2m_min': [22.0, 21.0, 20.5],
        'precipitation_probability_max': [10, 50, 90],
      };

      final forecasts = DailyForecastModel.fromDailyJson(dailyJson);

      expect(forecasts.length, 3);
      expect(forecasts[0].date, '2024-01-15');
      expect(forecasts[0].weatherCode, 0);
      expect(forecasts[0].tempMax, 30.0);
      expect(forecasts[0].tempMin, 22.0);
      expect(forecasts[0].precipitationProbability, 10);
      expect(forecasts[2].precipitationProbability, 90);
    });

    test('fromDailyJson menangani precipitation_probability_max null', () {
      final dailyJson = {
        'time': ['2024-01-15'],
        'weather_code': [0],
        'temperature_2m_max': [30.0],
        'temperature_2m_min': [22.0],
        'precipitation_probability_max': null,
      };

      final forecasts = DailyForecastModel.fromDailyJson(dailyJson);
      expect(forecasts[0].precipitationProbability, isNull);
    });
  });

  // ======================= WeatherModel =======================
  group('WeatherModel', () {
    test('fromJson membuat model gabungan dengan benar', () {
      final json = {
        'current': {
          'temperature_2m': 28.5,
          'relative_humidity_2m': 75,
          'apparent_temperature': 30.1,
          'precipitation': 0.0,
          'weather_code': 3,
          'wind_speed_10m': 12.3,
        },
        'daily': {
          'time': ['2024-01-15'],
          'weather_code': [0],
          'temperature_2m_max': [30.0],
          'temperature_2m_min': [22.0],
          'precipitation_probability_max': [10],
        },
      };

      final weather = WeatherModel.fromJson(json);

      expect(weather.current.temperature, 28.5);
      expect(weather.daily.length, 1);
      expect(weather.todayPrecipitationProbability, 10);
    });

    test('todayPrecipitationProbability null ketika daily kosong', () {
      final json = {
        'current': {
          'temperature_2m': 28.5,
          'relative_humidity_2m': 75,
          'apparent_temperature': 30.1,
          'precipitation': 0.0,
          'weather_code': 3,
          'wind_speed_10m': 12.3,
        },
        'daily': {
          'time': <String>[],
          'weather_code': <int>[],
          'temperature_2m_max': <double>[],
          'temperature_2m_min': <double>[],
          'precipitation_probability_max': <int>[],
        },
      };

      final weather = WeatherModel.fromJson(json);
      expect(weather.todayPrecipitationProbability, isNull);
    });
  });

  // ======================= WeatherCodeMapper =======================
  group('WeatherCodeMapper', () {
    test('kode 0 = Cerah', () {
      expect(WeatherCodeMapper.getDescription(0), 'Cerah');
    });

    test('kode 61 = Hujan Ringan', () {
      expect(WeatherCodeMapper.getDescription(61), 'Hujan Ringan');
    });

    test('kode 95 = Badai Petir', () {
      expect(WeatherCodeMapper.getDescription(95), 'Badai Petir');
    });

    test('kode tidak dikenal = fallback', () {
      expect(WeatherCodeMapper.getDescription(999), 'Tidak Diketahui');
    });

    test('getIcon mengembalikan IconData', () {
      final icon = WeatherCodeMapper.getIcon(0);
      expect(icon, isNotNull);
    });

    test('getWeatherInfo mengembalikan WeatherInfo lengkap', () {
      final info = WeatherCodeMapper.getWeatherInfo(45);
      expect(info.description, 'Berkabut');
      expect(info.icon, isNotNull);
    });
  });
}
