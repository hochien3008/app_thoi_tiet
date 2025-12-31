import '../services/vietnam_cities.dart';

class Forecast {
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int cloudiness;

  Forecast({
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.cloudiness,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = json['weather'][0] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>?;
    final clouds = json['clouds'] as Map<String, dynamic>?;

    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temp: main['temp'].toDouble(),
      tempMin: main['temp_min'].toDouble(),
      tempMax: main['temp_max'].toDouble(),
      mainCondition: weather['main'] as String,
      description: weather['description'] as String? ?? weather['main'] as String,
      icon: weather['icon'] as String? ?? '01d',
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: wind?['deg'] as int? ?? 0,
      cloudiness: clouds?['all'] as int? ?? 0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

class ForecastResponse {
  final String cityName;
  final List<Forecast> forecasts;

  ForecastResponse({
    required this.cityName,
    required this.forecasts,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>;
    final rawCityName = city['name'] as String;
    final cityNameWithAccents = VietnamCities.getCityNameWithAccents(rawCityName);
    
    final list = json['list'] as List<dynamic>;
    final forecasts = list.map((item) => Forecast.fromJson(item as Map<String, dynamic>)).toList();

    return ForecastResponse(
      cityName: cityNameWithAccents,
      forecasts: forecasts,
    );
  }

  // Nhóm dự báo theo ngày và tính min/max nhiệt độ cho mỗi ngày
  List<Forecast> getDailyForecasts() {
    final Map<String, List<Forecast>> dailyForecastsMap = {};
    
    // Nhóm tất cả forecast theo ngày
    for (final forecast in forecasts) {
      final dateKey = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
      if (!dailyForecastsMap.containsKey(dateKey)) {
        dailyForecastsMap[dateKey] = [];
      }
      dailyForecastsMap[dateKey]!.add(forecast);
    }
    
    // Tạo danh sách forecast với min/max đã tính toán
    final List<Forecast> dailyForecasts = [];
    
    for (final entry in dailyForecastsMap.entries) {
      final dayForecasts = entry.value;
      
      // Tìm min và max từ tất cả forecast trong ngày
      double minTemp = dayForecasts.first.tempMin;
      double maxTemp = dayForecasts.first.tempMax;
      
      Forecast? bestForecast; // Forecast gần giữa ngày nhất (12:00) để lấy icon và mô tả
      
      for (final forecast in dayForecasts) {
        // So sánh với tempMin và tempMax của từng forecast
        if (forecast.tempMin < minTemp) minTemp = forecast.tempMin;
        if (forecast.tempMax > maxTemp) maxTemp = forecast.tempMax;
        // Cũng kiểm tra temp hiện tại
        if (forecast.temp < minTemp) minTemp = forecast.temp;
        if (forecast.temp > maxTemp) maxTemp = forecast.temp;
        
        // Chọn forecast gần giữa ngày nhất (12:00) để lấy icon và mô tả
        if (bestForecast == null) {
          bestForecast = forecast;
        } else {
          final bestHour = bestForecast.date.hour;
          final currentHour = forecast.date.hour;
          if ((currentHour - 12).abs() < (bestHour - 12).abs()) {
            bestForecast = forecast;
          }
        }
      }
      
      // Tạo forecast mới với min/max đã tính toán
      if (bestForecast != null) {
        final updatedForecast = Forecast(
          date: bestForecast.date,
          temp: bestForecast.temp,
          tempMin: minTemp,
          tempMax: maxTemp,
          mainCondition: bestForecast.mainCondition,
          description: bestForecast.description,
          icon: bestForecast.icon,
          humidity: bestForecast.humidity,
          windSpeed: bestForecast.windSpeed,
          windDeg: bestForecast.windDeg,
          cloudiness: bestForecast.cloudiness,
        );
        dailyForecasts.add(updatedForecast);
      }
    }
    
    return dailyForecasts..sort((a, b) => a.date.compareTo(b.date));
  }

  // Lấy dự báo theo giờ (24 giờ tiếp theo)
  List<Forecast> getHourlyForecasts() {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(hours: 24));
    
    return forecasts
        .where((forecast) =>
            forecast.date.isAfter(now) && forecast.date.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Lấy nhiệt độ cao nhất và thấp nhất trong ngày hôm nay
  Map<String, double> getTodayMinMaxTemp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Lấy tất cả forecast trong ngày hôm nay
    final todayForecasts = forecasts.where((forecast) {
      final forecastDate = DateTime(
        forecast.date.year,
        forecast.date.month,
        forecast.date.day,
      );
      return forecastDate.isAtSameMomentAs(today);
    }).toList();
    
    if (todayForecasts.isEmpty) {
      // Nếu không có forecast cho hôm nay, lấy từ các forecast tiếp theo
      final nextForecasts = forecasts
          .where((forecast) => forecast.date.isAfter(now))
          .take(8)
          .toList();
      
      if (nextForecasts.isEmpty) {
        return {'min': 0.0, 'max': 0.0};
      }
      
      double minTemp = nextForecasts.first.tempMin;
      double maxTemp = nextForecasts.first.tempMax;
      
      for (final forecast in nextForecasts) {
        if (forecast.tempMin < minTemp) minTemp = forecast.tempMin;
        if (forecast.tempMax > maxTemp) maxTemp = forecast.tempMax;
        // Cũng kiểm tra temp hiện tại
        if (forecast.temp < minTemp) minTemp = forecast.temp;
        if (forecast.temp > maxTemp) maxTemp = forecast.temp;
      }
      
      return {'min': minTemp, 'max': maxTemp};
    }
    
    // Tìm min và max từ các forecast trong ngày
    double minTemp = todayForecasts.first.tempMin;
    double maxTemp = todayForecasts.first.tempMax;
    
    for (final forecast in todayForecasts) {
      // So sánh với tempMin và tempMax của từng forecast
      if (forecast.tempMin < minTemp) minTemp = forecast.tempMin;
      if (forecast.tempMax > maxTemp) maxTemp = forecast.tempMax;
      // Cũng kiểm tra temp hiện tại của forecast
      if (forecast.temp < minTemp) minTemp = forecast.temp;
      if (forecast.temp > maxTemp) maxTemp = forecast.temp;
    }
    
    return {'min': minTemp, 'max': maxTemp};
  }
}

