import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/weather_model.dart';

class WeatherHistoryService {
  static const String _historyKey = 'weather_history';

  // Lưu dữ liệu thời tiết vào lịch sử
  Future<bool> saveWeatherHistory(Weather weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getWeatherHistory();

      // Tạo entry mới
      final entry = {
        'cityName': weather.cityName,
        'temperature': weather.temperature,
        'feelsLike': weather.feelsLike,
        'tempMin': weather.tempMin,
        'tempMax': weather.tempMax,
        'mainCondition': weather.mainCondition,
        'description': weather.description,
        'icon': weather.icon,
        'humidity': weather.humidity,
        'windSpeed': weather.windSpeed,
        'windDeg': weather.windDeg,
        'pressure': weather.pressure,
        'visibility': weather.visibility,
        'cloudiness': weather.cloudiness,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Thêm vào đầu danh sách
      history.insert(0, entry);

      // Giới hạn lịch sử 30 ngày
      if (history.length > 30) {
        history.removeRange(30, history.length);
      }

      // Lưu lại
      final historyJson = jsonEncode(history);
      return await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Lỗi khi lưu lịch sử thời tiết: $e');
      return false;
    }
  }

  // Lấy toàn bộ lịch sử
  Future<List<Map<String, dynamic>>> getWeatherHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) {
        return [];
      }
      final List<dynamic> history = jsonDecode(historyJson);
      return history.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Lỗi khi lấy lịch sử thời tiết: $e');
      return [];
    }
  }

  // Lấy lịch sử theo thành phố
  Future<List<Map<String, dynamic>>> getWeatherHistoryByCity(
      String cityName) async {
    try {
      final history = await getWeatherHistory();
      return history
          .where((entry) => entry['cityName'] == cityName)
          .toList();
    } catch (e) {
      print('Lỗi khi lấy lịch sử theo thành phố: $e');
      return [];
    }
  }

  // Lấy lịch sử theo ngày
  Future<List<Map<String, dynamic>>> getWeatherHistoryByDate(
      DateTime date) async {
    try {
      final history = await getWeatherHistory();
      final targetDate = DateTime(date.year, date.month, date.day);
      return history.where((entry) {
        final entryDate = DateTime.fromMillisecondsSinceEpoch(
          entry['timestamp'] as int,
        );
        final entryDateOnly =
            DateTime(entryDate.year, entryDate.month, entryDate.day);
        return entryDateOnly.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy lịch sử theo ngày: $e');
      return [];
    }
  }

  // Xóa toàn bộ lịch sử
  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      print('Lỗi khi xóa lịch sử: $e');
      return false;
    }
  }

  // Lấy thống kê từ lịch sử
  Future<Map<String, dynamic>> getStatistics(String? cityName) async {
    try {
      final history = cityName != null
          ? await getWeatherHistoryByCity(cityName)
          : await getWeatherHistory();

      if (history.isEmpty) {
        return {
          'avgTemp': 0.0,
          'maxTemp': 0.0,
          'minTemp': 0.0,
          'rainyDays': 0,
          'sunnyDays': 0,
          'cloudyDays': 0,
          'totalDays': 0,
        };
      }

      double totalTemp = 0.0;
      double maxTemp = history.first['tempMax']?.toDouble() ?? 0.0;
      double minTemp = history.first['tempMin']?.toDouble() ?? 0.0;
      int rainyDays = 0;
      int sunnyDays = 0;
      int cloudyDays = 0;
      Set<String> uniqueDays = {};

      for (final entry in history) {
        final temp = entry['temperature']?.toDouble() ?? 0.0;
        totalTemp += temp;

        final tempMax = entry['tempMax']?.toDouble() ?? temp;
        final tempMin = entry['tempMin']?.toDouble() ?? temp;

        if (tempMax > maxTemp) maxTemp = tempMax;
        if (tempMin < minTemp) minTemp = tempMin;

        final condition = (entry['mainCondition'] as String? ?? '').toLowerCase();
        final timestamp = entry['timestamp'] as int;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (!uniqueDays.contains(dateKey)) {
          uniqueDays.add(dateKey);

          if (condition.contains('rain') || condition.contains('drizzle')) {
            rainyDays++;
          } else if (condition.contains('clear') || condition.contains('sun')) {
            sunnyDays++;
          } else if (condition.contains('cloud')) {
            cloudyDays++;
          }
        }
      }

      return {
        'avgTemp': totalTemp / history.length,
        'maxTemp': maxTemp,
        'minTemp': minTemp,
        'rainyDays': rainyDays,
        'sunnyDays': sunnyDays,
        'cloudyDays': cloudyDays,
        'totalDays': uniqueDays.length,
      };
    } catch (e) {
      print('Lỗi khi tính thống kê: $e');
      return {
        'avgTemp': 0.0,
        'maxTemp': 0.0,
        'minTemp': 0.0,
        'rainyDays': 0,
        'sunnyDays': 0,
        'cloudyDays': 0,
        'totalDays': 0,
      };
    }
  }
}

