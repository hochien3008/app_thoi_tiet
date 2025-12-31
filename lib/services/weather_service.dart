import 'dart:convert';
import 'package:geocoding/geocoding.dart'; // Import để dịch tọa độ ra tên thành phố
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../model/weather_model.dart';
import '../model/forecast_model.dart';

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static const FORECAST_URL = 'http://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;

  WeatherService(this.apiKey);

  // 1. Lấy dữ liệu thời tiết dựa trên tên thành phố
  Future<Weather> getWeather(String cityName) async {
    // Tạo danh sách các biến thể tên thành phố để thử
    final variants = _getCityNameVariants(cityName);

    // Thử từng biến thể cho đến khi tìm thấy
    for (final variant in variants) {
      try {
        final response = await http.get(
          Uri.parse(
            '$BASE_URL?q=${Uri.encodeComponent(variant)}&appid=$apiKey&units=metric',
          ),
        );

        if (response.statusCode == 200) {
          return Weather.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Lỗi khi tìm kiếm với "$variant": $e');
        continue;
      }
    }

    // Nếu tất cả đều thất bại
    throw Exception('Không tìm thấy thành phố "$cityName"');
  }

  // Tạo danh sách các biến thể tên thành phố để thử
  List<String> _getCityNameVariants(String cityName) {
    final variants = <String>[];

    // 1. Tên không dấu
    final withoutAccents = _removeVietnameseAccents(cityName);
    variants.add(withoutAccents);

    // 2. Tên gốc (có dấu)
    variants.add(cityName);

    // 3. Xử lý các trường hợp đặc biệt
    // Nếu có dấu gạch ngang, thử phần sau
    if (cityName.contains(' - ')) {
      final parts = cityName.split(' - ');
      if (parts.length > 1) {
        // Thử phần sau (ví dụ: "Vũng Tàu" từ "Bà Rịa - Vũng Tàu")
        variants.add(parts.last);
        variants.add(_removeVietnameseAccents(parts.last));
      }
    }

    // 4. Thử với "City" hoặc "Province" nếu không có
    if (!withoutAccents.toLowerCase().contains('city') &&
        !withoutAccents.toLowerCase().contains('province')) {
      variants.add('$withoutAccents City');
      variants.add('$withoutAccents Province');
    }

    // 5. Mapping các tên đặc biệt
    final specialMappings = _getSpecialCityMappings();
    if (specialMappings.containsKey(cityName)) {
      variants.insert(0, specialMappings[cityName]!);
    }
    if (specialMappings.containsKey(withoutAccents)) {
      variants.insert(0, specialMappings[withoutAccents]!);
    }

    return variants;
  }

  // Mapping các tên thành phố đặc biệt mà API có thể nhận diện
  Map<String, String> _getSpecialCityMappings() {
    return {
      'Bà Rịa - Vũng Tàu': 'Vung Tau',
      'Ba Ria - Vung Tau': 'Vung Tau',
      'Thừa Thiên Huế': 'Hue',
      'Thua Thien Hue': 'Hue',
      'Đắk Nông': 'Dak Nong',
      'Dak Nong': 'Dak Nong',
      'Đắk Lắk': 'Buon Ma Thuot',
      'Dak Lak': 'Buon Ma Thuot',
      'Phú Yên': 'Tuy Hoa',
      'Phu Yen': 'Tuy Hoa',
      'Khánh Hòa': 'Nha Trang',
      'Khanh Hoa': 'Nha Trang',
      'Bình Thuận': 'Phan Thiet',
      'Binh Thuan': 'Phan Thiet',
      'Bình Định': 'Quy Nhon',
      'Binh Dinh': 'Quy Nhon',
      'Quảng Nam': 'Hoi An',
      'Quang Nam': 'Hoi An',
      'Lâm Đồng': 'Da Lat',
      'Lam Dong': 'Da Lat',
      'Kiên Giang': 'Rach Gia',
      'Kien Giang': 'Rach Gia',
      'An Giang': 'Long Xuyen',
      'Tiền Giang': 'My Tho',
      'Tien Giang': 'My Tho',
      'Đồng Tháp': 'Cao Lanh',
      'Dong Thap': 'Cao Lanh',
      'Gia Lai': 'Pleiku',
      'Kon Tum': 'Kon Tum',
    };
  }

  // Helper function để loại bỏ dấu tiếng Việt
  String _removeVietnameseAccents(String str) {
    const Map<String, String> vietnameseToEnglish = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
      'À': 'A',
      'Á': 'A',
      'Ạ': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ầ': 'A',
      'Ấ': 'A',
      'Ậ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ă': 'A',
      'Ằ': 'A',
      'Ắ': 'A',
      'Ặ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'È': 'E',
      'É': 'E',
      'Ẹ': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ê': 'E',
      'Ề': 'E',
      'Ế': 'E',
      'Ệ': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ị': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ọ': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ồ': 'O',
      'Ố': 'O',
      'Ộ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ơ': 'O',
      'Ờ': 'O',
      'Ớ': 'O',
      'Ợ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ụ': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ư': 'U',
      'Ừ': 'U',
      'Ứ': 'U',
      'Ự': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ỳ': 'Y',
      'Ý': 'Y',
      'Ỵ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Đ': 'D',
    };

    String result = str;
    vietnameseToEnglish.forEach((vietnamese, english) {
      result = result.replaceAll(vietnamese, english);
    });
    return result;
  }

  // 2. Lấy vị trí hiện tại và dịch thành tên thành phố
  Future<String> getCurrentCity() async {
    try {
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

      // Lấy tọa độ hiện tại (Vĩ độ & Kinh độ)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

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
    final response = await http.get(
      Uri.parse(
        '$BASE_URL?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Không thể lấy dữ liệu thời tiết: ${response.statusCode}',
      );
    }
  }

  // 4. Lấy tọa độ hiện tại
  Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      print('Lỗi lấy tọa độ: $e');
      return null;
    }
  }

  // 5. Lấy dự báo thời tiết 5 ngày
  Future<ForecastResponse> getForecast(String cityName) async {
    // Sử dụng cùng logic với getWeather để thử nhiều biến thể
    final variants = _getCityNameVariants(cityName);

    // Thử từng biến thể cho đến khi tìm thấy
    for (final variant in variants) {
      try {
        final response = await http.get(
          Uri.parse(
            '$FORECAST_URL?q=${Uri.encodeComponent(variant)}&appid=$apiKey&units=metric',
          ),
        );

        if (response.statusCode == 200) {
          return ForecastResponse.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Lỗi khi lấy dự báo với "$variant": $e');
        continue;
      }
    }

    // Nếu tất cả đều thất bại
    throw Exception('Không tìm thấy thành phố "$cityName"');
  }

  // 6. Lấy dự báo thời tiết 5 ngày theo tọa độ
  Future<ForecastResponse> getForecastByLocation(
    double latitude,
    double longitude,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$FORECAST_URL?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return ForecastResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể lấy dự báo thời tiết: ${response.statusCode}');
    }
  }
}
