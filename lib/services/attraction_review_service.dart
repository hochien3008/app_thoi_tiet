import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttractionReview {
  final String attractionId;
  final String userName;
  final double rating; // 1-5
  final String comment;
  final DateTime dateTime;

  AttractionReview({
    required this.attractionId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'attractionId': attractionId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory AttractionReview.fromJson(Map<String, dynamic> json) {
    return AttractionReview(
      attractionId: json['attractionId'],
      userName: json['userName'],
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
    );
  }
}

class AttractionReviewService {
  static const String _reviewsKey = 'attraction_reviews';

  // Lưu review
  Future<bool> saveReview(AttractionReview review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviews = await getReviews();
      reviews.add(review);
      final reviewsJson = jsonEncode(reviews.map((r) => r.toJson()).toList());
      return await prefs.setString(_reviewsKey, reviewsJson);
    } catch (e) {
      print('Lỗi khi lưu review: $e');
      return false;
    }
  }

  // Lấy tất cả reviews
  Future<List<AttractionReview>> getReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString(_reviewsKey);
      if (reviewsJson == null) {
        return [];
      }
      final List<dynamic> reviews = jsonDecode(reviewsJson);
      return reviews.map((json) => AttractionReview.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy reviews: $e');
      return [];
    }
  }

  // Lấy reviews theo điểm du lịch
  Future<List<AttractionReview>> getReviewsByAttraction(String attractionId) async {
    final reviews = await getReviews();
    return reviews
        .where((review) => review.attractionId == attractionId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Mới nhất trước
  }

  // Tính điểm đánh giá trung bình
  Future<double> getAverageRating(String attractionId) async {
    final reviews = await getReviewsByAttraction(attractionId);
    if (reviews.isEmpty) {
      return 0.0;
    }
    final totalRating = reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / reviews.length;
  }

  // Lấy số lượng reviews
  Future<int> getReviewCount(String attractionId) async {
    final reviews = await getReviewsByAttraction(attractionId);
    return reviews.length;
  }
}

