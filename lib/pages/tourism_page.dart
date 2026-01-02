import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tourism_service.dart';
import '../services/weather_service.dart';
import '../services/favorite_attraction_service.dart';
import '../services/attraction_review_service.dart';
import '../model/weather_model.dart';
import '../widgets/tourism_image_widget.dart';
import 'search_city_page.dart';
import 'attraction_detail_page.dart';

class TourismPage extends StatefulWidget {
  final String? initialCity;

  const TourismPage({super.key, this.initialCity});

  @override
  State<TourismPage> createState() => _TourismPageState();
}

class _TourismPageState extends State<TourismPage> {
  final _weatherService = WeatherService('d6c025fbb03c620a08c8548eecfd142b');
  final _favoriteService = FavoriteAttractionService();
  final _reviewService = AttractionReviewService();
  String? _selectedCity;
  Weather? _currentWeather;
  List<TouristAttraction> _attractions = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null && widget.initialCity!.isNotEmpty) {
      // Sử dụng thành phố từ trang thời tiết
      setState(() {
        _selectedCity = widget.initialCity;
      });
      _loadCityData(widget.initialCity!);
    } else {
      // Nếu không có, lấy từ GPS
      _loadDefaultCity();
    }
  }

  Future<void> _loadDefaultCity() async {
    try {
      final cityName = await _weatherService.getCurrentCity();
      setState(() {
        _selectedCity = cityName;
      });
      await _loadCityData(cityName);
    } catch (e) {
      print('Lỗi khi lấy thành phố mặc định: $e');
    }
  }

  Future<void> _loadCityData(String cityName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy thời tiết hiện tại
      final weather = await _weatherService.getWeather(cityName);

      // Lấy điểm du lịch - sử dụng tên thành phố từ weather để đảm bảo khớp
      final cityForAttractions = weather.cityName;
      final attractions = TourismService.getAttractionsByCity(
        cityForAttractions,
      );

      // Lấy danh sách favorite
      final favoriteIds = await _favoriteService.getFavoriteIds();

      setState(() {
        _currentWeather = weather;
        _attractions = attractions;
        _favoriteIds = favoriteIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchCityPage(
          onCitySelected: (cityName) {
            setState(() {
              _selectedCity = cityName;
            });
            _loadCityData(cityName);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      appBar: AppBar(
        title: Text('Du lịch'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chọn thành phố
                    GestureDetector(
                      onTap: _selectCity,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedCity ?? 'Chọn thành phố',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Đánh giá thời tiết du lịch
                    if (_currentWeather != null) ...[
                      _buildWeatherRatingCard(),
                      SizedBox(height: 24),
                    ],

                    // Gợi ý hoạt động
                    if (_currentWeather != null) ...[
                      _buildActivitySuggestions(),
                      SizedBox(height: 24),
                    ],

                    // Điểm du lịch
                    Text(
                      'Điểm du lịch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_attractions.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có thông tin điểm du lịch cho thành phố này',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ..._attractions.map(
                        (attraction) => _buildAttractionCard(attraction),
                      ),

                    SizedBox(height: 24),

                    // Gợi ý thời điểm du lịch
                    if (_selectedCity != null) _buildBestTravelTimeCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWeatherRatingCard() {
    if (_currentWeather == null) return SizedBox.shrink();

    final rating = TourismService.getTravelWeatherRating(_currentWeather!);
    final score = rating['score'] as int;
    final maxScore = rating['maxScore'] as int;
    final ratingText = rating['rating'] as String;
    final description = rating['description'] as String;

    Color ratingColor;
    IconData ratingIcon;
    switch (ratingText) {
      case 'Xuất sắc':
        ratingColor = Colors.green;
        ratingIcon = Icons.star;
        break;
      case 'Tốt':
        ratingColor = Colors.blue;
        ratingIcon = Icons.check_circle;
        break;
      case 'Khá':
        ratingColor = Colors.orange;
        ratingIcon = Icons.info;
        break;
      default:
        ratingColor = Colors.red;
        ratingIcon = Icons.warning;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ratingIcon, color: ratingColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá thời tiết du lịch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      ratingText,
                      style: TextStyle(
                        color: ratingColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score / maxScore,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
                  minHeight: 8,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '$score/$maxScore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySuggestions() {
    if (_currentWeather == null) return SizedBox.shrink();

    final suggestions = TourismService.getActivitySuggestions(
      _currentWeather!,
      cityName: _selectedCity,
      attractions: _attractions,
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow, size: 24),
              SizedBox(width: 12),
              Text(
                'Gợi ý hoạt động',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(TouristAttraction attraction) {
    final isFavorite = _favoriteIds.contains(attraction.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttractionDetailPage(attraction: attraction),
          ),
        );
        // Reload favorites sau khi quay lại
        final favoriteIds = await _favoriteService.getFavoriteIds();
        setState(() {
          _favoriteIds = favoriteIds.toSet();
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  TourismImageWidget(
                    imageUrl: attraction.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      height: 180,
                      color: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.image, color: Colors.white70, size: 50),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        if (isFavorite) {
                          await _favoriteService.removeFavorite(attraction.id);
                        } else {
                          await _favoriteService.addFavorite(attraction.id);
                        }
                        final favoriteIds = await _favoriteService
                            .getFavoriteIds();
                        setState(() {
                          _favoriteIds = favoriteIds.toSet();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Thông tin
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          attraction.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nút mở bản đồ
                      IconButton(
                        icon: Icon(Icons.map, color: Colors.white),
                        onPressed: () => _openGoogleMaps(attraction),
                        tooltip: 'Xem trên bản đồ',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    attraction.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryLabel(attraction.category),
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getSeasonLabel(attraction.bestSeason),
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      Spacer(),
                      // Hiển thị rating trung bình
                      FutureBuilder<double>(
                        future: _reviewService.getAverageRating(attraction.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data! > 0) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  snapshot.data!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(TouristAttraction attraction) async {
    final lat = attraction.latitude;
    final lng = attraction.longitude;

    // Thử nhiều cách mở bản đồ
    List<String> urls = [
      // Google Maps app (Android)
      'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(attraction.name)})',
      // Google Maps app (iOS)
      'comgooglemaps://?q=$lat,$lng&center=$lat,$lng&zoom=14',
      // Google Maps web
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      // Fallback: Google Maps web với tên địa điểm
      'https://www.google.com/maps?q=$lat,$lng',
    ];

    bool launched = false;
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        // Tiếp tục thử URL tiếp theo
        continue;
      }
    }

    if (!launched) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở bản đồ. Vui lòng cài đặt Google Maps.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildBestTravelTimeCard() {
    final bestTime = TourismService.getBestTravelTime(_selectedCity ?? '');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Thời điểm du lịch tốt nhất',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            bestTime,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'beach':
        return '🏖️ Biển';
      case 'mountain':
        return '⛰️ Núi';
      case 'cultural':
        return '🏛️ Văn hóa';
      case 'nature':
        return '🌲 Thiên nhiên';
      case 'urban':
        return '🏙️ Đô thị';
      default:
        return category;
    }
  }

  String _getSeasonLabel(String season) {
    switch (season) {
      case 'spring':
        return '🌸 Mùa xuân';
      case 'summer':
        return '☀️ Mùa hè';
      case 'autumn':
        return '🍂 Mùa thu';
      case 'winter':
        return '❄️ Mùa đông';
      case 'all':
        return '📅 Quanh năm';
      default:
        return season;
    }
  }
}
