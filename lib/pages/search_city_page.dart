import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/favorite_city_service.dart';
import '../services/vietnam_cities.dart';

class SearchCityPage extends StatefulWidget {
  final Function(String) onCitySelected;

  const SearchCityPage({super.key, required this.onCitySelected});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService(
    'd6c025fbb03c620a08c8548eecfd142b',
  );
  final FavoriteCityService _favoriteService = FavoriteCityService();
  bool _isSearching = false;
  String? _errorMessage;
  List<String> _favoriteCities = [];
  List<String> _suggestions = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFavoriteCities();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _suggestions = VietnamCities.searchCities(query);
        _errorMessage = null;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _suggestions.isNotEmpty) {
      // Giữ lại suggestions một chút sau khi mất focus
    }
  }

  Future<void> _loadFavoriteCities() async {
    final cities = await _favoriteService.getFavoriteCities();
    setState(() {
      _favoriteCities = cities;
    });
  }

  Future<void> _searchCity() async {
    final cityName = _searchController.text.trim();
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên thành phố';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Thử lấy thời tiết để kiểm tra thành phố có tồn tại không
      await _weatherService.getWeather(cityName);

      // Nếu thành công, chọn thành phố này
      widget.onCitySelected(cityName);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage =
            'Không tìm thấy thành phố "$cityName". Vui lòng thử lại.';
      });
    }
  }

  Future<void> _toggleFavorite(String cityName) async {
    // Đảm bảo lưu tên có dấu
    final cityNameWithAccents = VietnamCities.getCityNameWithAccents(cityName);
    // Kiểm tra cả tên có dấu và không dấu
    final isFavorite =
        await _favoriteService.isFavorite(cityName) ||
        await _favoriteService.isFavorite(cityNameWithAccents);
    if (isFavorite) {
      // Xóa cả hai biến thể
      await _favoriteService.removeFavoriteCity(cityName);
      await _favoriteService.removeFavoriteCity(cityNameWithAccents);
    } else {
      // Lưu tên có dấu
      await _favoriteService.addFavoriteCity(cityNameWithAccents);
    }
    _loadFavoriteCities();
  }

  void _selectCity(String cityName) {
    widget.onCitySelected(cityName);
    Navigator.pop(context);
  }

  void _selectSuggestion(String cityName) {
    _searchController.text = cityName;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: cityName.length),
    );
    setState(() {
      _suggestions = [];
    });
    _focusNode.unfocus();
    // Tự động tìm kiếm sau khi chọn
    Future.delayed(Duration(milliseconds: 100), () {
      _searchCity();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFE0F6FF), // Light blue
              Color(0xFFFFF8DC), // Cornsilk
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Tìm kiếm thành phố',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: TextStyle(color: Color(0xFF2C3E50)),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thành phố...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF3498DB),
                          ),
                        ),
                        onSubmitted: (_) => _searchCity(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF3498DB),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isSearching ? null : _searchCity,
                        icon: _isSearching
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.search, color: Colors.white),
                        padding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              // Suggestions dropdown
              if (_suggestions.isNotEmpty && _focusNode.hasFocus)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length > 5
                        ? 5
                        : _suggestions.length,
                    itemBuilder: (context, index) {
                      final city = _suggestions[index];
                      return InkWell(
                        onTap: () => _selectSuggestion(city),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom:
                                  index <
                                      (_suggestions.length > 5
                                          ? 4
                                          : _suggestions.length - 1)
                                  ? BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 0.5,
                                    )
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF3498DB),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  city,
                                  style: TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFE74C3C).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Color(0xFFE74C3C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Favorite cities section
              if (_favoriteCities.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Thành phố yêu thích',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _favoriteCities.length,
                    itemBuilder: (context, index) {
                      final city = _favoriteCities[index];
                      // Chuyển đổi tên thành phố sang có dấu để hiển thị
                      final cityWithAccents =
                          VietnamCities.getCityNameWithAccents(city);
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_city,
                            color: Color(0xFF3498DB),
                          ),
                          title: Text(
                            cityWithAccents,
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE74C3C),
                                ),
                                onPressed: () => _toggleFavorite(city),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF3498DB),
                                ),
                                onPressed: () => _selectCity(city),
                              ),
                            ],
                          ),
                          onTap: () => _selectCity(city),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: Color(0xFF95A5A6),
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có thành phố yêu thích',
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tìm kiếm và thêm thành phố vào yêu thích',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
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
}
