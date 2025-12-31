import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../model/weather_model.dart';
import '../model/forecast_model.dart';
import 'openweathermap_cities.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  static const FORECAST_URL =
      'https://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;

  WeatherService(this.apiKey);

  // 1. Lấy dữ liệu thời tiết dựa trên tên thành phố
  Future<Weather> getWeather(String cityName) async {
    // Tạo danh sách các biến thể tên thành phố để thử
    final variants = _getCityNameVariants(cityName);

    Exception? lastError;

    // Thử từng biến thể cho đến khi tìm thấy
    for (final variant in variants) {
      try {
        final response = await http
            .get(
              Uri.parse(
                '$BASE_URL?q=${Uri.encodeComponent(variant)}&appid=$apiKey&units=metric',
              ),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Kết nối timeout. Vui lòng kiểm tra kết nối mạng.',
                );
              },
            );

        if (response.statusCode == 200) {
          return Weather.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Lỗi khi tìm kiếm với "$variant": $e');
        // Lưu lỗi đầu tiên để báo cáo nếu tất cả đều thất bại
        if (lastError == null) {
          if (e.toString().contains('SocketException') ||
              e.toString().contains('Failed host lookup') ||
              e.toString().contains('Network is unreachable')) {
            lastError = Exception(
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
            );
          } else {
            lastError = e is Exception ? e : Exception(e.toString());
          }
        }
        continue;
      }
    }

    // Nếu tất cả đều thất bại, ném lỗi phù hợp
    if (lastError != null) {
      throw lastError;
    }
    throw Exception('Không tìm thấy thành phố "$cityName"');
  }

  // Tạo danh sách các biến thể tên thành phố để thử
  List<String> _getCityNameVariants(String cityName) {
    final variants = <String>[];

    // 1. Sử dụng OpenWeatherMapCities để map tên tỉnh -> tên thành phố
    final apiName = OpenWeatherMapCities.getApiName(cityName);
    if (apiName != cityName && !variants.contains(apiName)) {
      variants.add(apiName);
    }

    final withoutAccents = OpenWeatherMapCities.removeVietnameseAccents(
      cityName,
    );
    final apiNameWithoutAccents = OpenWeatherMapCities.getApiName(
      withoutAccents,
    );
    if (apiNameWithoutAccents != withoutAccents &&
        !variants.contains(apiNameWithoutAccents)) {
      variants.add(apiNameWithoutAccents);
    }

    // 2. Tên không dấu
    if (!variants.contains(withoutAccents)) {
      variants.add(withoutAccents);
    }

    // 3. Tên gốc (có dấu)
    if (!variants.contains(cityName)) {
      variants.add(cityName);
    }

    // 4. Xử lý các trường hợp đặc biệt
    // Nếu có dấu gạch ngang, thử phần sau
    if (cityName.contains(' - ')) {
      final parts = cityName.split(' - ');
      if (parts.length > 1) {
        // Thử phần sau (ví dụ: "Vũng Tàu" từ "Bà Rịa - Vũng Tàu")
        final lastPart = parts.last;
        if (!variants.contains(lastPart)) {
          variants.add(lastPart);
        }
        final lastPartWithoutAccents =
            OpenWeatherMapCities.removeVietnameseAccents(lastPart);
        if (!variants.contains(lastPartWithoutAccents)) {
          variants.add(lastPartWithoutAccents);
        }
      }
    }

    // 5. Thử với "City" hoặc "Province" nếu không có
    if (!withoutAccents.toLowerCase().contains('city') &&
        !withoutAccents.toLowerCase().contains('province')) {
      final withCity = '$withoutAccents City';
      final withProvince = '$withoutAccents Province';
      if (!variants.contains(withCity)) {
        variants.add(withCity);
      }
      if (!variants.contains(withProvince)) {
        variants.add(withProvince);
      }
    }

    // 6. Thử với "Vietnam" suffix
    final withVietnam = '$withoutAccents, Vietnam';
    if (!variants.contains(withVietnam)) {
      variants.add(withVietnam);
    }

    return variants;
  }

  // 2. Lấy vị trí hiện tại và dịch thành tên thành phố
  Future<String> getCurrentCity() async {
    try {
      // Kiểm tra xem dịch vụ vị trí có được bật không
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Dịch vụ vị trí chưa được bật');
        return "Hanoi";
      }

      // Xin quyền truy cập vị trí từ người dùng
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Nếu người dùng từ chối vĩnh viễn, trả về mặc định
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return "Hanoi";
      }

      // Thử lấy vị trí hiện tại với độ chính xác cao
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      } catch (e) {
        print(
          'Không lấy được vị trí hiện tại, thử vị trí cuối cùng đã biết: $e',
        );
        // Nếu timeout, thử lấy vị trí cuối cùng đã biết
        position = await Geolocator.getLastKnownPosition();
        if (position == null) {
          // Nếu vẫn không có, thử với độ chính xác thấp hơn
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 10),
            );
          } catch (e2) {
            print('Không thể lấy vị trí: $e2');
            return "Hanoi";
          }
        }
      }

      // Tại điểm này, position không thể null vì đã xử lý tất cả các trường hợp null
      // Chuyển tọa độ thành danh sách các địa danh (Placemarks)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Trích xuất tên thành phố (locality) từ địa danh đầu tiên tìm thấy
        if (placemarks.isNotEmpty && placemarks[0].locality != null) {
          return placemarks[0].locality!;
        }
      } catch (e) {
        print('Lỗi geocoding: $e');
        // Nếu geocoding fail, vẫn trả về tọa độ để dùng API theo tọa độ
      }

      // Nếu không lấy được tên thành phố, trả về mặc định
      return "Hanoi";
    } catch (e) {
      print('Lỗi lấy vị trí: $e');
      return "Hanoi";
    }
  }

  // 3. Lấy thời tiết dựa trên tọa độ (tránh vấn đề với tên địa danh)
  Future<Weather> getWeatherByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$BASE_URL?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Kết nối timeout. Vui lòng kiểm tra kết nối mạng.',
              );
            },
          );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Không thể lấy dữ liệu thời tiết: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
      rethrow;
    }
  }

  // 4. Lấy tọa độ hiện tại
  Future<Position?> getCurrentPosition() async {
    try {
      // Kiểm tra xem dịch vụ vị trí có được bật không
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Dịch vụ vị trí chưa được bật');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      Position? position;

      // Thử lấy vị trí hiện tại với độ chính xác cao
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        );
      } catch (e) {
        print(
          'Không lấy được vị trí hiện tại, thử vị trí cuối cùng đã biết: $e',
        );
        // Nếu timeout, thử lấy vị trí cuối cùng đã biết
        position = await Geolocator.getLastKnownPosition();
        if (position == null) {
          // Nếu vẫn không có, thử với độ chính xác thấp hơn
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 10),
            );
          } catch (e2) {
            print('Không thể lấy tọa độ: $e2');
            return null;
          }
        }
      }

      return position;
    } catch (e) {
      print('Lỗi lấy tọa độ: $e');
      return null;
    }
  }

  // 5. Lấy dự báo thời tiết 5 ngày
  Future<ForecastResponse> getForecast(String cityName) async {
    // Sử dụng cùng logic với getWeather để thử nhiều biến thể
    final variants = _getCityNameVariants(cityName);

    Exception? lastError;

    // Thử từng biến thể cho đến khi tìm thấy
    for (final variant in variants) {
      try {
        final response = await http
            .get(
              Uri.parse(
                '$FORECAST_URL?q=${Uri.encodeComponent(variant)}&appid=$apiKey&units=metric',
              ),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Kết nối timeout. Vui lòng kiểm tra kết nối mạng.',
                );
              },
            );

        if (response.statusCode == 200) {
          return ForecastResponse.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Lỗi khi lấy dự báo với "$variant": $e');
        // Lưu lỗi đầu tiên để báo cáo nếu tất cả đều thất bại
        if (lastError == null) {
          if (e.toString().contains('SocketException') ||
              e.toString().contains('Failed host lookup') ||
              e.toString().contains('Network is unreachable')) {
            lastError = Exception(
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
            );
          } else {
            lastError = e is Exception ? e : Exception(e.toString());
          }
        }
        continue;
      }
    }

    // Nếu tất cả đều thất bại, ném lỗi phù hợp
    if (lastError != null) {
      throw lastError;
    }
    throw Exception('Không tìm thấy thành phố "$cityName"');
  }

  // 6. Lấy dự báo thời tiết 5 ngày theo tọa độ
  Future<ForecastResponse> getForecastByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$FORECAST_URL?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Kết nối timeout. Vui lòng kiểm tra kết nối mạng.',
              );
            },
          );

      if (response.statusCode == 200) {
        return ForecastResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Không thể lấy dự báo thời tiết: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.',
        );
      }
      rethrow;
    }
  }
}
