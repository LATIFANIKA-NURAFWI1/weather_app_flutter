import 'dart:convert';


class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocationModel.fromJsonString(String jsonString) {
    return LocationModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        (other.latitude - latitude).abs() < 0.0001 &&
        (other.longitude - longitude).abs() < 0.0001;
  }

  @override
  int get hashCode =>
      (latitude * 10000).round().hashCode ^
      (longitude * 10000).round().hashCode;
}
