import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tourism_service.dart';

class FavoriteAttractionService {
  static const String _favoriteKey = 'favorite_attractions';

  // Lưu điểm du lịch yêu thích
  Future<bool> addFavorite(String attractionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteIds();
      
      if (!favorites.contains(attractionId)) {
        favorites.add(attractionId);
        final favoritesJson = jsonEncode(favorites);
        return await prefs.setString(_favoriteKey, favoritesJson);
      }
      return true;
    } catch (e) {
      print('Lỗi khi lưu điểm du lịch yêu thích: $e');
      return false;
    }
  }

  // Xóa điểm du lịch yêu thích
  Future<bool> removeFavorite(String attractionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteIds();
      favorites.remove(attractionId);
      final favoritesJson = jsonEncode(favorites);
      return await prefs.setString(_favoriteKey, favoritesJson);
    } catch (e) {
      print('Lỗi khi xóa điểm du lịch yêu thích: $e');
      return false;
    }
  }

  // Kiểm tra có yêu thích không
  Future<bool> isFavorite(String attractionId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(attractionId);
  }

  // Lấy danh sách ID yêu thích
  Future<List<String>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoriteKey);
      if (favoritesJson == null) {
        return [];
      }
      final List<dynamic> favorites = jsonDecode(favoritesJson);
      return favorites.cast<String>();
    } catch (e) {
      print('Lỗi khi lấy danh sách yêu thích: $e');
      return [];
    }
  }

  // Lấy danh sách điểm du lịch yêu thích
  Future<List<TouristAttraction>> getFavoriteAttractions() async {
    final favoriteIds = await getFavoriteIds();
    final attractions = <TouristAttraction>[];
    
    for (final id in favoriteIds) {
      final attraction = TourismService.getAttractionById(id);
      if (attraction != null) {
        attractions.add(attraction);
      }
    }
    
    return attractions;
  }
}

