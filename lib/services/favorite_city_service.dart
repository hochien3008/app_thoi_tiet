import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCityService {
  static const String _favoritesKey = 'favorite_cities';

  // Lấy danh sách thành phố yêu thích
  Future<List<String>> getFavoriteCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citiesJson = prefs.getStringList(_favoritesKey);
      return citiesJson ?? [];
    } catch (e) {
      print('Lỗi khi lấy danh sách thành phố yêu thích: $e');
      return [];
    }
  }

  // Thêm thành phố vào danh sách yêu thích
  Future<bool> addFavoriteCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cities = await getFavoriteCities();

      // Kiểm tra xem thành phố đã tồn tại chưa
      if (cities.contains(cityName)) {
        return false; // Đã tồn tại
      }

      cities.add(cityName);
      return await prefs.setStringList(_favoritesKey, cities);
    } catch (e) {
      print('Lỗi khi thêm thành phố yêu thích: $e');
      return false;
    }
  }

  // Xóa thành phố khỏi danh sách yêu thích
  Future<bool> removeFavoriteCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cities = await getFavoriteCities();
      cities.remove(cityName);
      return await prefs.setStringList(_favoritesKey, cities);
    } catch (e) {
      print('Lỗi khi xóa thành phố yêu thích: $e');
      return false;
    }
  }

  // Kiểm tra xem thành phố có trong danh sách yêu thích không
  Future<bool> isFavorite(String cityName) async {
    try {
      final cities = await getFavoriteCities();
      return cities.contains(cityName);
    } catch (e) {
      print('Lỗi khi kiểm tra thành phố yêu thích: $e');
      return false;
    }
  }
}
