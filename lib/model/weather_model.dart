import '../services/openweathermap_cities.dart';

class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int pressure;
  final int visibility;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pressure,
    required this.visibility,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
  });

  // Chuyển đổi JSON từ API thành Object trong Dart
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Lấy tên thành phố từ API (có thể không có dấu)
    final rawCityName = json['name'] as String;

    // Chuyển đổi sang tên có dấu nếu là thành phố Việt Nam
    final cityNameWithAccents = OpenWeatherMapCities.getDisplayName(
      rawCityName,
    );

    final main = json['main'] as Map<String, dynamic>;
    final weather = json['weather'][0] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>?;

    // Xử lý icon an toàn
    String iconValue = '01d';
    if (weather['icon'] != null) {
      try {
        iconValue = weather['icon'].toString();
      } catch (e) {
        iconValue = '01d';
      }
    }

    // Xử lý mainCondition an toàn
    String mainConditionValue = 'Clear';
    if (weather['main'] != null) {
      try {
        mainConditionValue = weather['main'].toString();
      } catch (e) {
        mainConditionValue = 'Clear';
      }
    }

    // Xử lý description an toàn
    String descriptionValue = 'Clear sky';
    if (weather['description'] != null) {
      try {
        descriptionValue = weather['description'].toString();
      } catch (e) {
        if (weather['main'] != null) {
          descriptionValue = weather['main'].toString();
        }
      }
    }

    return Weather(
      cityName: cityNameWithAccents,
      temperature: main['temp'].toDouble(),
      feelsLike: main['feels_like']?.toDouble() ?? main['temp'].toDouble(),
      tempMin: main['temp_min']?.toDouble() ?? main['temp'].toDouble(),
      tempMax: main['temp_max']?.toDouble() ?? main['temp'].toDouble(),
      mainCondition: mainConditionValue,
      description: descriptionValue,
      icon: iconValue,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: wind?['deg'] as int? ?? 0,
      pressure: main['pressure'] as int? ?? 0,
      visibility: (json['visibility'] as int?) ?? 10000,
      cloudiness: clouds?['all'] as int? ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunrise'] as int?) ??
                DateTime.now().millisecondsSinceEpoch ~/ 1000) *
            1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        ((sys['sunset'] as int?) ??
                DateTime.now().millisecondsSinceEpoch ~/ 1000) *
            1000,
      ),
    );
  }

  // URL icon thời tiết từ OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
