import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import '../services/weather_service.dart';
import '../services/favorite_city_service.dart';
import 'search_city_page.dart';

class CompareCitiesPage extends StatefulWidget {
  const CompareCitiesPage({super.key});

  @override
  State<CompareCitiesPage> createState() => _CompareCitiesPageState();
}

class _CompareCitiesPageState extends State<CompareCitiesPage> {
  final _weatherService = WeatherService('d6c025fbb03c620a08c8548eecfd142b');
  final _favoriteService = FavoriteCityService();
  List<String> _selectedCities = [];
  Map<String, Weather?> _weatherData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCities();
  }

  Future<void> _loadFavoriteCities() async {
    final favorites = await _favoriteService.getFavoriteCities();
    setState(() {
      _selectedCities = favorites.take(3).toList(); // Tối đa 3 thành phố
    });
    if (_selectedCities.isNotEmpty) {
      _compareCities();
    }
  }

  Future<void> _compareCities() async {
    setState(() {
      _isLoading = true;
      _weatherData.clear();
    });

    for (final cityName in _selectedCities) {
      try {
        final weather = await _weatherService.getWeather(cityName);
        setState(() {
          _weatherData[cityName] = weather;
        });
      } catch (e) {
        print('Lỗi khi lấy thời tiết cho $cityName: $e');
        setState(() {
          _weatherData[cityName] = null;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectCity(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchCityPage(
          onCitySelected: (cityName) {
            setState(() {
              if (index < _selectedCities.length) {
                _selectedCities[index] = cityName;
              } else {
                if (_selectedCities.length < 3) {
                  _selectedCities.add(cityName);
                }
              }
            });
            _compareCities();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('So sánh thành phố'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF6BB3E8), Color(0xFF87CEEB)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _selectedCities.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.compare_arrows, size: 64, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có thành phố để so sánh',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thêm thành phố yêu thích để so sánh',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hướng dẫn
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Nhấn vào thành phố để thay đổi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút thêm/thay đổi thành phố
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        final cityName = index < _selectedCities.length
                            ? _selectedCities[index]
                            : null;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _selectCity(index),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: cityName != null
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cityName != null
                                        ? Icons.location_on
                                        : Icons.add_location_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      cityName ?? 'Thêm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (cityName != null) ...[
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),
                    // So sánh dữ liệu
                    ...List.generate(_selectedCities.length, (index) {
                      final cityName = _selectedCities[index];
                      final weather = _weatherData[cityName];
                      if (weather == null) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Không tìm thấy dữ liệu cho $cityName',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return _buildCityCard(weather);
                    }),
                  ],
                ),
              ),
      ),
      floatingActionButton: _selectedCities.isNotEmpty
          ? FloatingActionButton(
              onPressed: _compareCities,
              child: Icon(Icons.refresh),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  Widget _buildCityCard(Weather weather) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  weather.cityName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.network(weather.iconUrl, width: 50, height: 50),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildComparisonItem(
                'Nhiệt độ',
                '${weather.temperature.round()}°C',
                Icons.thermostat,
              ),
              _buildComparisonItem(
                'Cảm nhận',
                '${weather.feelsLike.round()}°C',
                Icons.wb_sunny,
              ),
              _buildComparisonItem(
                'Độ ẩm',
                '${weather.humidity}%',
                Icons.water_drop,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildComparisonItem(
                'Gió',
                '${weather.windSpeed.round()} km/h',
                Icons.air,
              ),
              _buildComparisonItem(
                'Áp suất',
                '${weather.pressure} hPa',
                Icons.compress,
              ),
              _buildComparisonItem(
                'Tầm nhìn',
                '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                Icons.visibility,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }
}
