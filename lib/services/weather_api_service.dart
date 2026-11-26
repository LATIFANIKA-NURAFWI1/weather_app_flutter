import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/weather_model.dart';

class WeatherApiService {

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    // Gunakan Uri.https dengan queryParameters (bukan string concat)
    final uri = Uri.https(
      ApiConstants.forecastBaseUrl,
      ApiConstants.forecastPath,
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': ApiConstants.currentParams,
        'daily': ApiConstants.dailyParams,
        'timezone': 'auto',
        'forecast_days': ApiConstants.forecastDays,
      },
    );

    try {
      // HTTP GET dengan timeout 10 detik
      final response = await http
          .get(uri)
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      // Cek status code
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json);
      } else {
        throw HttpException(
          'Server merespons dengan status ${response.statusCode}',
        );
      }
    } on SocketException {
      // Tidak ada internet
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      // Request timeout
      throw TimeoutException(
        'Koneksi timeout. Server tidak merespons dalam '
        '${ApiConstants.timeoutSeconds} detik.',
      );
    } on FormatException {
      // JSON tidak valid
      throw const FormatException(
        'Data dari server tidak valid. Coba lagi nanti.',
      );
    }
  }
}
