import 'package:flutter/material.dart';
import 'dart:async';
import '../model/weather_model.dart';
import '../model/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/favorite_city_service.dart';
import '../services/openweathermap_cities.dart';
import '../services/weather_history_service.dart';
import '../services/weather_alert_service.dart';
import 'search_city_page.dart';
import 'compare_cities_page.dart';
import 'statistics_page.dart';
import 'tourism_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Nhập API Key của bạn vào đây
  final _weatherService = WeatherService('d6c025fbb03c620a08c8548eecfd142b');
  final _favoriteService = FavoriteCityService();
  final _historyService = WeatherHistoryService();
  Weather? _weather;
  ForecastResponse? _forecast;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  List<String> _favoriteCities = [];
  Timer? _autoUpdateTimer;
  List<WeatherAlert> _alerts = [];

  // Hàm lấy dữ liệu thời tiết
  _fetchWeather([String? cityName]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Nếu có tên thành phố được truyền vào, dùng nó
      if (cityName != null && cityName.isNotEmpty) {
        final weather = await _weatherService.getWeather(cityName);
        final forecast = await _weatherService.getForecast(cityName);
        setState(() {
          _weather = weather;
          _forecast = forecast;
          _isLoading = false;
        });
        // Cập nhật tên thành phố trong danh sách yêu thích nếu khác
        // (ví dụ: "Bình Định" -> "Quy Nhơn")
        // Đảm bảo tên có dấu
        final actualCityName = weather.cityName;
        final cityNameWithAccents = cityName;
        if (actualCityName != cityNameWithAccents &&
            _favoriteCities.contains(cityName)) {
          await _favoriteService.removeFavoriteCity(cityName);
          // Xóa cả tên có dấu nếu có
          if (_favoriteCities.contains(cityNameWithAccents)) {
            await _favoriteService.removeFavoriteCity(cityNameWithAccents);
          }
          if (!await _favoriteService.isFavorite(actualCityName)) {
            await _favoriteService.addFavoriteCity(actualCityName);
          }
          _loadFavoriteCities();
        }
        // Lưu lịch sử
        await _historyService.saveWeatherHistory(weather);
        // Kiểm tra cảnh báo
        _alerts = WeatherAlertService.checkAlerts(weather, forecast);
        _checkFavoriteStatus();
        return;
      }

      // Thử lấy thời tiết bằng tọa độ trước (chính xác hơn)
      final position = await _weatherService.getCurrentPosition();

      if (position != null) {
        try {
          // Dùng tọa độ để lấy thời tiết (tránh vấn đề với tên địa danh)
          final weather = await _weatherService.getWeatherByLocation(
            position.latitude,
            position.longitude,
          );
          final forecast = await _weatherService.getForecastByLocation(
            position.latitude,
            position.longitude,
          );
          setState(() {
            _weather = weather;
            _forecast = forecast;
            _isLoading = false;
          });
          // Lưu lịch sử
          await _historyService.saveWeatherHistory(weather);
          // Kiểm tra cảnh báo
          _alerts = WeatherAlertService.checkAlerts(weather, forecast);
          _checkFavoriteStatus();
          return;
        } catch (e) {
          print('Lỗi lấy thời tiết theo tọa độ: $e');
        }
      }

      // Nếu không lấy được bằng tọa độ, thử dùng tên thành phố
      String defaultCityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(defaultCityName);
      final forecast = await _weatherService.getForecast(defaultCityName);
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
      // Lưu lịch sử
      await _historyService.saveWeatherHistory(weather);
      // Kiểm tra cảnh báo
      _alerts = WeatherAlertService.checkAlerts(weather, forecast);
      _checkFavoriteStatus();
    } catch (e) {
      print('Lỗi: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải dữ liệu thời tiết. Vui lòng thử lại.';
      });
    }
  }

  // Kiểm tra trạng thái yêu thích
  Future<void> _checkFavoriteStatus() async {
    if (_weather?.cityName != null) {
      final cityName = _weather!.cityName;
      // Kiểm tra cả tên có dấu và không dấu
      final isFav =
          await _favoriteService.isFavorite(cityName) ||
          await _favoriteService.isFavorite(
            cityName.toLowerCase().replaceAll(
              RegExp(
                r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
              ),
              '',
            ),
          );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  // Toggle favorite
  Future<void> _toggleFavorite() async {
    if (_weather?.cityName == null) return;

    // Tên thành phố đã được chuyển đổi sang có dấu trong Weather model
    final cityName = _weather!.cityName;

    if (_isFavorite) {
      // Xóa cả tên có dấu và không dấu nếu có
      await _favoriteService.removeFavoriteCity(cityName);
      // Tìm và xóa các biến thể không dấu
      final favoriteCities = await _favoriteService.getFavoriteCities();
      for (final favCity in favoriteCities) {
        final favCityWithAccents = OpenWeatherMapCities.getDisplayName(
          OpenWeatherMapCities.getApiName(favCity),
        );
        if (favCityWithAccents == cityName && favCity != cityName) {
          await _favoriteService.removeFavoriteCity(favCity);
        }
      }
    } else {
      await _favoriteService.addFavoriteCity(cityName);
    }
    _loadFavoriteCities();
    _checkFavoriteStatus();
  }

  // Load danh sách thành phố yêu thích và đảm bảo tên có dấu
  Future<void> _loadFavoriteCities() async {
    final cities = await _favoriteService.getFavoriteCities();
    // Cập nhật tên có dấu cho tất cả thành phố
    final updatedCities = <String>[];
    for (final city in cities) {
      final cityWithAccents = OpenWeatherMapCities.getDisplayName(
        OpenWeatherMapCities.getApiName(city),
      );
      updatedCities.add(cityWithAccents);
      // Nếu tên đã thay đổi, cập nhật trong storage
      if (cityWithAccents != city) {
        await _favoriteService.removeFavoriteCity(city);
        if (!updatedCities.contains(cityWithAccents)) {
          await _favoriteService.addFavoriteCity(cityWithAccents);
        }
      }
    }
    setState(() {
      _favoriteCities = updatedCities;
    });
  }

  // Mở trang tìm kiếm
  void _openSearchPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchCityPage(
          onCitySelected: (cityName) {
            _fetchWeather(cityName);
          },
        ),
      ),
    );
    // Reload danh sách yêu thích sau khi quay lại
    _loadFavoriteCities();
  }

  @override
  void initState() {
    super.initState();
    // Gọi dữ liệu ngay khi khởi động app
    _fetchWeather();
    _loadFavoriteCities();
    // Tự động cập nhật mỗi 30 phút
    _autoUpdateTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      _fetchWeather();
    });
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    super.dispose();
  }

  // Hàm tạo gradient background dựa trên thời tiết (giống hình - bầu trời xanh)
  BoxDecoration _getBackgroundGradient() {
    final condition = (_weather?.mainCondition ?? 'clear').toLowerCase();

    switch (condition) {
      case 'clear':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2), // Bright blue sky (top)
              Color(0xFF6BB3E8), // Sky blue (middle)
              Color(0xFF87CEEB), // Light sky blue (bottom)
            ],
          ),
        );
      case 'clouds':
      case 'mist':
      case 'fog':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5A8FC8), // Cloudy blue (top)
              Color(0xFF7AA8D4), // Medium blue (middle)
              Color(0xFF9BC0E0), // Light blue (bottom)
            ],
          ),
        );
      case 'rain':
      case 'drizzle':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A6FA5), // Rainy blue gray (top)
              Color(0xFF6B8FC5), // Medium gray blue (middle)
              Color(0xFF8CAFD5), // Light gray blue (bottom)
            ],
          ),
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF6BB3E8), Color(0xFF87CEEB)],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _getBackgroundGradient(),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.compare_arrows, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompareCitiesPage(),
                              ),
                            );
                          },
                          tooltip: 'So sánh thành phố',
                        ),
                        IconButton(
                          icon: Icon(Icons.bar_chart, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatisticsPage(),
                              ),
                            );
                          },
                          tooltip: 'Thống kê',
                        ),
                        IconButton(
                          icon: Icon(Icons.beach_access, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TourismPage(),
                              ),
                            );
                          },
                          tooltip: 'Du lịch',
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: _openSearchPage,
                      tooltip: 'Tìm kiếm thành phố',
                    ),
                  ],
                ),
              ),
              // Main weather content
              Expanded(
                child: Center(
                  child: _isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF3498DB)),
                            SizedBox(height: 20),
                            Text(
                              "Đang tải dữ liệu...",
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : _errorMessage != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Color(0xFFE74C3C),
                              size: 64,
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _fetchWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text('Thử lại'),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header Section - Cải thiện với icon và glassmorphism
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: Column(
                                  children: [
                                    // Tên thành phố và favorite
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _weather?.cityName ?? "Unknown",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _isFavorite
                                                ? Color(0xFFFF6B6B)
                                                : Colors.white,
                                            size: 28,
                                          ),
                                          onPressed: _toggleFavorite,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24),

                                    // Icon thời tiết lớn
                                    if (_weather != null)
                                      Image.network(
                                        _weather!.iconUrl,
                                        width: 120,
                                        height: 120,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.wb_sunny,
                                                color: Colors.white,
                                                size: 100,
                                              );
                                            },
                                      ),
                                    SizedBox(height: 16),

                                    // Nhiệt độ lớn
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_weather?.temperature.round() ?? 0}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 100,
                                            fontWeight: FontWeight.w300,
                                            height: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 12),
                                          child: Text(
                                            '°',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 50,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12),

                                    // Mô tả thời tiết
                                    Text(
                                      _getVietnameseDescription(
                                        _weather?.description ?? '',
                                      ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    SizedBox(height: 16),

                                    // Nhiệt độ cao/thấp trong ngày (từ forecast)
                                    if (_forecast != null) ...[
                                      Builder(
                                        builder: (context) {
                                          final todayMinMax = _forecast!
                                              .getTodayMinMaxTemp();
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Cao: ${todayMinMax['max']?.round() ?? 0}°',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Text(
                                                'Thấp: ${todayMinMax['min']?.round() ?? 0}°',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ] else ...[
                                      // Fallback nếu chưa có forecast
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Cao: ${_weather?.tempMax.round() ?? 0}°',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            'Thấp: ${_weather?.tempMin.round() ?? 0}°',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              // Cảnh báo thời tiết (phía trên dự báo theo giờ)
                              if (_alerts.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _alerts.map((alert) {
                                        final color =
                                            WeatherAlertService.getSeverityColor(
                                              alert.severity,
                                            );
                                        return Container(
                                          margin: EdgeInsets.only(right: 8),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: color,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                alert.icon,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                alert.message,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],

                              // Dự báo theo giờ (Horizontal scroll) - Có khung
                              if (_forecast != null) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dự báo theo giờ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _forecast!
                                                .getHourlyForecasts()
                                                .length,
                                            itemBuilder: (context, index) {
                                              final hourlyForecasts = _forecast!
                                                  .getHourlyForecasts();
                                              final hourly =
                                                  hourlyForecasts[index];
                                              final isNow =
                                                  index == 0 &&
                                                  hourly.date
                                                          .difference(
                                                            DateTime.now(),
                                                          )
                                                          .inHours <
                                                      1;
                                              return _buildHourlyForecastCard(
                                                hourly,
                                                index,
                                                isNow: isNow,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],

                              // Thông tin chi tiết - Card layout 2 cột
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    // Row 1: Cảm nhận và Gió
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoCard(
                                            'CẢM NHẬN',
                                            '${_weather?.feelsLike.round() ?? 0}°',
                                            Icons.thermostat,
                                            (_weather != null &&
                                                    (_weather!.feelsLike
                                                            .round() ==
                                                        _weather!.temperature
                                                            .round()))
                                                ? 'Giống với nhiệt độ thực tế'
                                                : 'Nhiệt độ cảm nhận ${_weather?.feelsLike.round() ?? 0}°',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInfoCard(
                                            'GIÓ',
                                            '${((_weather?.windSpeed ?? 0) * 3.6).round()} km/h',
                                            Icons.air,
                                            'Hướng ${_getWindDirection(_weather?.windDeg ?? 0)}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    // Row 2: Mặt trời và Độ ẩm
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoCard(
                                            'MẶT TRỜI LẶN',
                                            _formatTime(
                                              _weather?.sunset ??
                                                  DateTime.now(),
                                            ),
                                            Icons.wb_twilight,
                                            'Mọc: ${_formatTime(_weather?.sunrise ?? DateTime.now())}',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInfoCard(
                                            'ĐỘ ẨM',
                                            '${_weather?.humidity ?? 0}%',
                                            Icons.water_drop,
                                            'Điểm sương ${(_weather?.feelsLike ?? 0).round()}°',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    // Row 3: Tầm nhìn và Áp suất
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoCard(
                                            'TẦM NHÌN',
                                            '${((_weather?.visibility ?? 0) / 1000).toStringAsFixed(0)} km',
                                            Icons.visibility,
                                            'Nhìn hoàn toàn rõ',
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInfoCard(
                                            'ÁP SUẤT',
                                            '${_weather?.pressure ?? 0}',
                                            Icons.compress,
                                            'hPa',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),

                                    // Dự báo 10 ngày
                                    if (_forecast != null) ...[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'DỰ BÁO 5 NGÀY',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          children: _forecast!
                                              .getDailyForecasts()
                                              .take(10)
                                              .map(
                                                (daily) =>
                                                    _buildDailyForecastRow(
                                                      daily,
                                                    ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],

                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Favorite cities list - Đẹp hơn
              if (_favoriteCities.isNotEmpty &&
                  !_isLoading &&
                  _errorMessage == null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF6B6B).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Color(0xFFFF6B6B),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Thành phố yêu thích',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _favoriteCities.length,
                            itemBuilder: (context, index) {
                              final city = _favoriteCities[index];
                              // Đảm bảo hiển thị tên có dấu
                              final cityWithAccents =
                                  OpenWeatherMapCities.getDisplayName(
                                    OpenWeatherMapCities.getApiName(city),
                                  );
                              final isSelected =
                                  _weather?.cityName == cityWithAccents ||
                                  _weather?.cityName == city;
                              return Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: InkWell(
                                  // Dùng tên gốc để fetch (có thể không dấu)
                                  // Nhưng hiển thị tên có dấu
                                  onTap: () => _fetchWeather(city),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                Color(0xFF4A90E2),
                                                Color(0xFF357ABD),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.grey[400]?.withOpacity(
                                                  0.5,
                                                ) ??
                                                Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Color(
                                                  0xFF357ABD,
                                                ).withOpacity(0.5),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                                spreadRadius: 0,
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          cityWithAccents,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method để lấy tên ngày bằng tiếng Việt
  String _getDayName(DateTime date) {
    const days = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
    ];
    // date.weekday trả về 1-7 (1 = Monday, 7 = Sunday)
    // Chuyển đổi: 1 -> Thứ hai, 2 -> Thứ ba, ..., 7 -> Chủ nhật
    return days[date.weekday % 7];
  }

  // Helper method để format thời gian
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Chuyển đổi mô tả thời tiết sang tiếng Việt
  String _getVietnameseDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sunny')) {
      return 'Trời quang';
    } else if (desc.contains('cloud')) {
      return 'Có mây vài nơi';
    } else if (desc.contains('rain')) {
      return 'Có mưa';
    } else if (desc.contains('drizzle')) {
      return 'Mưa phùn';
    } else if (desc.contains('thunderstorm')) {
      return 'Có giông';
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return 'Có sương mù';
    } else if (desc.contains('snow')) {
      return 'Có tuyết';
    }
    return description;
  }

  // Lấy hướng gió
  String _getWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'B';
    if (degrees >= 22.5 && degrees < 67.5) return 'ĐB';
    if (degrees >= 67.5 && degrees < 112.5) return 'Đ';
    if (degrees >= 112.5 && degrees < 157.5) return 'ĐN';
    if (degrees >= 157.5 && degrees < 202.5) return 'N';
    if (degrees >= 202.5 && degrees < 247.5) return 'TN';
    if (degrees >= 247.5 && degrees < 292.5) return 'T';
    if (degrees >= 292.5 && degrees < 337.5) return 'TB';
    return 'N';
  }

  // Card dự báo theo giờ - Không có khung
  Widget _buildHourlyForecastCard(
    Forecast forecast,
    int index, {
    bool isNow = false,
  }) {
    return SizedBox(
      width: 85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isNow ? 'Bây giờ' : '${forecast.date.hour}:00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Image.network(
            forecast.iconUrl,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.wb_sunny, color: Colors.white, size: 30);
            },
          ),
          SizedBox(height: 8),
          Text(
            '${forecast.temp.round()}°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Card thông tin chi tiết - Đơn giản
  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Row dự báo 10 ngày - Đơn giản
  Widget _buildDailyForecastRow(Forecast forecast) {
    final isToday =
        forecast.date.day == DateTime.now().day &&
        forecast.date.month == DateTime.now().month;
    final dayName = isToday ? 'Hôm nay' : _getDayName(forecast.date);

    // Tính toán độ dài của temperature bar
    final minTemp = forecast.tempMin;
    final maxTemp = forecast.tempMax;
    final tempRange = maxTemp - minTemp;
    final maxPossibleRange = 40.0;
    final barWidthFactor = (tempRange / maxPossibleRange).clamp(0.2, 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Ngày
          SizedBox(
            width: 90,
            child: Text(
              dayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Icon
          Image.network(
            forecast.iconUrl,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.wb_sunny, color: Colors.white, size: 30);
            },
          ),
          SizedBox(width: 12),
          // Nhiệt độ thấp
          SizedBox(
            width: 40,
            child: Text(
              '${forecast.tempMin.round()}°',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 12),
          // Temperature bar đơn giản
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: barWidthFactor,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Nhiệt độ cao
          SizedBox(
            width: 40,
            child: Text(
              '${forecast.tempMax.round()}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
