import 'package:flutter/material.dart';
import '../services/weather_history_service.dart';
import '../services/favorite_city_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _historyService = WeatherHistoryService();
  final _favoriteService = FavoriteCityService();
  Map<String, dynamic> _statistics = {};
  String? _selectedCity;
  List<String> _favoriteCities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await _favoriteService.getFavoriteCities();
    setState(() {
      _favoriteCities = favorites;
      if (_favoriteCities.isNotEmpty && _selectedCity == null) {
        _selectedCity = _favoriteCities.first;
      }
    });

    await _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _historyService.getStatistics(_selectedCity);
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      appBar: AppBar(
        title: Text('Thống kê thời tiết'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_favoriteCities.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list),
              onSelected: (city) {
                setState(() {
                  _selectedCity = city;
                });
                _loadStatistics();
              },
              itemBuilder: (context) => _favoriteCities
                  .map(
                    (city) => PopupMenuItem<String>(
                      value: city,
                      child: Row(
                        children: [
                          Icon(
                            _selectedCity == city ? Icons.check : null,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(city),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF6BB3E8), Color(0xFF87CEEB)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _statistics['totalDays'] == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có dữ liệu thống kê',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sử dụng app để tích lũy dữ liệu',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _selectedCity ?? 'Chưa chọn thành phố',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${_statistics['totalDays']} ngày',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Nhiệt độ
                    _buildStatCard('Nhiệt độ', Icons.thermostat, [
                      _buildStatItem(
                        'Trung bình',
                        '${_statistics['avgTemp'].toStringAsFixed(1)}°C',
                        Colors.orange,
                      ),
                      _buildStatItem(
                        'Cao nhất',
                        '${_statistics['maxTemp'].toStringAsFixed(1)}°C',
                        Colors.red,
                      ),
                      _buildStatItem(
                        'Thấp nhất',
                        '${_statistics['minTemp'].toStringAsFixed(1)}°C',
                        Colors.blue,
                      ),
                    ]),
                    SizedBox(height: 16),
                    // Thời tiết
                    _buildStatCard('Thời tiết', Icons.wb_sunny, [
                      _buildStatItem(
                        'Nắng',
                        '${_statistics['sunnyDays']} ngày',
                        Colors.yellow,
                      ),
                      _buildStatItem(
                        'Mưa',
                        '${_statistics['rainyDays']} ngày',
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Nhiều mây',
                        '${_statistics['cloudyDays']} ngày',
                        Colors.grey,
                      ),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
