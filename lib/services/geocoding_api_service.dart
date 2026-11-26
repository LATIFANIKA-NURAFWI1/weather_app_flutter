import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/location_model.dart';

/// Service untuk mencari lokasi/kota melalui Geocoding API Open-Meteo
/// Hanya bertanggung jawab melakukan HTTP request dan parsing JSON
class GeocodingApiService {
  /// Cari lokasi berdasarkan nama kota
  /// Mengembalikan list LocationModel (bisa kosong jika tidak ditemukan)
  Future<List<LocationModel>> searchLocation(String query) async {
    // Validasi input: jangan request jika query kosong
    if (query.trim().isEmpty) {
      return [];
    }

    // Gunakan Uri.https dengan queryParameters
    final uri = Uri.https(
      ApiConstants.geocodingBaseUrl,
      ApiConstants.geocodingPath,
      {
        'name': query.trim(),
        'count': ApiConstants.geocodingCount,
        'language': ApiConstants.geocodingLanguage,
        'format': 'json',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(Duration(seconds: ApiConstants.timeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // Field "results" bisa tidak ada atau null jika kota tidak ditemukan
        final results = json['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return []; // Kota tidak ditemukan, kembalikan list kosong
        }

        return results
            .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Server merespons dengan status ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Koneksi timeout. Server tidak merespons dalam '
        '${ApiConstants.timeoutSeconds} detik.',
      );
    } on FormatException {
      throw const FormatException(
        'Data dari server tidak valid. Coba lagi nanti.',
      );
    }
  }
}
