import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import '../model/forecast_model.dart';

class WeatherAlert {
  final String type; // 'rain', 'wind', 'temperature', 'uv'
  final String message;
  final String severity; // 'low', 'medium', 'high'
  final IconData icon;

  WeatherAlert({
    required this.type,
    required this.message,
    required this.severity,
    required this.icon,
  });
}

class WeatherAlertService {
  // Kiểm tra và tạo cảnh báo từ dữ liệu thời tiết
  static List<WeatherAlert> checkAlerts(
    Weather? weather,
    ForecastResponse? forecast,
  ) {
    final List<WeatherAlert> alerts = [];

    if (weather == null) return alerts;

    // Cảnh báo mưa
    if (weather.mainCondition.toLowerCase().contains('rain') ||
        weather.mainCondition.toLowerCase().contains('drizzle') ||
        weather.mainCondition.toLowerCase().contains('thunderstorm')) {
      String severity = 'low';
      String message = 'Có mưa';
      IconData icon = Icons.water_drop;

      if (weather.mainCondition.toLowerCase().contains('thunderstorm')) {
        severity = 'high';
        message = 'CẢNH BÁO: Có dông sét';
        icon = Icons.flash_on;
      } else if (weather.humidity > 80) {
        severity = 'medium';
        message = 'Mưa lớn, độ ẩm cao';
        icon = Icons.water_drop;
      }

      alerts.add(
        WeatherAlert(
          type: 'rain',
          message: message,
          severity: severity,
          icon: icon,
        ),
      );
    }

    // Cảnh báo gió mạnh
    if (weather.windSpeed > 15) {
      String severity = 'medium';
      String message = 'Gió mạnh: ${weather.windSpeed.round()} km/h';
      IconData icon = Icons.air;

      if (weather.windSpeed > 25) {
        severity = 'high';
        message = 'CẢNH BÁO: Gió rất mạnh: ${weather.windSpeed.round()} km/h';
        icon = Icons.warning;
      }

      alerts.add(
        WeatherAlert(
          type: 'wind',
          message: message,
          severity: severity,
          icon: icon,
        ),
      );
    }

    // Cảnh báo nhiệt độ cao
    if (weather.temperature > 35) {
      String severity = 'medium';
      String message = 'Nhiệt độ cao: ${weather.temperature.round()}°C';
      IconData icon = Icons.wb_sunny;

      if (weather.temperature > 40) {
        severity = 'high';
        message =
            'CẢNH BÁO: Nhiệt độ rất cao: ${weather.temperature.round()}°C';
        icon = Icons.warning;
      }

      alerts.add(
        WeatherAlert(
          type: 'temperature',
          message: message,
          severity: severity,
          icon: icon,
        ),
      );
    }

    // Cảnh báo nhiệt độ thấp
    if (weather.temperature < 10) {
      String severity = 'medium';
      String message = 'Nhiệt độ thấp: ${weather.temperature.round()}°C';
      IconData icon = Icons.ac_unit;

      if (weather.temperature < 5) {
        severity = 'high';
        message =
            'CẢNH BÁO: Nhiệt độ rất thấp: ${weather.temperature.round()}°C';
        icon = Icons.warning;
      }

      alerts.add(
        WeatherAlert(
          type: 'temperature',
          message: message,
          severity: severity,
          icon: icon,
        ),
      );
    }

    // Cảnh báo từ forecast (mưa sắp tới)
    if (forecast != null) {
      final hourlyForecasts = forecast.getHourlyForecasts();
      // Tìm forecast mưa gần nhất trong 24 giờ tới
      Forecast? nearestRainForecast;
      int minHours = 24;

      for (final forecastItem in hourlyForecasts) {
        final condition = forecastItem.mainCondition.toLowerCase();
        if (condition.contains('rain') ||
            condition.contains('drizzle') ||
            condition.contains('thunderstorm')) {
          final hoursUntil = forecastItem.date
              .difference(DateTime.now())
              .inHours;
          // Tìm forecast mưa gần nhất trong 24 giờ
          if (hoursUntil > 0 && hoursUntil <= 24 && hoursUntil < minHours) {
            nearestRainForecast = forecastItem;
            minHours = hoursUntil;
          }
        }
      }

      // Nếu tìm thấy mưa trong 24 giờ tới, thêm cảnh báo
      if (nearestRainForecast != null) {
        alerts.add(
          WeatherAlert(
            type: 'rain',
            message: 'Mưa dự kiến trong $minHours giờ tới',
            severity: 'medium',
            icon: Icons.water_drop,
          ),
        );
      }
    }

    return alerts;
  }

  // Lấy màu sắc theo mức độ nghiêm trọng
  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
