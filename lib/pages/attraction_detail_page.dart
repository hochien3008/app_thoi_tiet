import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/tourism_service.dart';
import '../services/favorite_attraction_service.dart';
import '../services/attraction_review_service.dart';
import '../widgets/tourism_image_widget.dart';

class AttractionDetailPage extends StatefulWidget {
  final TouristAttraction attraction;

  const AttractionDetailPage({super.key, required this.attraction});

  @override
  State<AttractionDetailPage> createState() => _AttractionDetailPageState();
}

class _AttractionDetailPageState extends State<AttractionDetailPage> {
  final _favoriteService = FavoriteAttractionService();
  final _reviewService = AttractionReviewService();
  bool _isFavorite = false;
  double _averageRating = 0.0;
  int _reviewCount = 0;
  List<AttractionReview> _reviews = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isFav = await _favoriteService.isFavorite(widget.attraction.id);
    final avgRating = await _reviewService.getAverageRating(widget.attraction.id);
    final reviewCount = await _reviewService.getReviewCount(widget.attraction.id);
    final reviews = await _reviewService.getReviewsByAttraction(widget.attraction.id);

    setState(() {
      _isFavorite = isFav;
      _averageRating = avgRating;
      _reviewCount = reviewCount;
      _reviews = reviews;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.attraction.id);
    } else {
      await _favoriteService.addFavorite(widget.attraction.id);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.attraction.latitude;
    final lng = widget.attraction.longitude;
    final name = Uri.encodeComponent(widget.attraction.name);
    
    // Thử nhiều cách mở bản đồ (ưu tiên app, sau đó web)
    List<String> urls = [
      // Google Maps app (Android) - geo scheme
      'geo:$lat,$lng?q=$lat,$lng($name)',
      // Google Maps app (Android/iOS) - comgooglemaps scheme
      'comgooglemaps://?q=$lat,$lng&center=$lat,$lng&zoom=14',
      // Google Maps web với tên địa điểm
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name',
      // Fallback: Google Maps web đơn giản
      'https://www.google.com/maps?q=$lat,$lng',
    ];

    bool launched = false;
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        // Thử mở trực tiếp, không kiểm tra canLaunchUrl vì có thể trả về sai
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          launched = true;
          break;
        } catch (e) {
          // Nếu không mở được, thử URL tiếp theo
          continue;
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
            content: Text('Không thể mở bản đồ. Vui lòng cài đặt Google Maps hoặc trình duyệt web.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showAddReviewDialog() async {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Thêm đánh giá'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Tên của bạn'),
                ),
                SizedBox(height: 16),
                Text('Đánh giá: ${selectedRating.toStringAsFixed(1)}'),
                Slider(
                  value: selectedRating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRating = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: 'Nhận xét'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final review = AttractionReview(
                    attractionId: widget.attraction.id,
                    userName: nameController.text,
                    rating: selectedRating,
                    comment: commentController.text,
                    dateTime: DateTime.now(),
                  );
                  await _reviewService.saveReview(review);
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      body: CustomScrollView(
        slivers: [
          // App bar với ảnh
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue,
            flexibleSpace: FlexibleSpaceBar(
              background: TourismImageWidget(
                imageUrl: widget.attraction.imageUrl,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: Colors.blue,
                  child: Icon(Icons.image, color: Colors.white, size: 100),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: _isFavorite ? Colors.red : Colors.white,
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          // Nội dung
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A90E2), Color(0xFF6BB3E8), Color(0xFF87CEEB)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên và thông tin cơ bản
                    Text(
                      widget.attraction.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 18),
                        SizedBox(width: 4),
                        Text(
                          widget.attraction.city,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Rating
                    if (_averageRating > 0)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 24),
                          SizedBox(width: 8),
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '($_reviewCount đánh giá)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    // Mô tả
                    Text(
                      widget.attraction.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Thông tin chi tiết
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            _getCategoryLabel(widget.attraction.category),
                            Icons.category,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoChip(
                            _getSeasonLabel(widget.attraction.bestSeason),
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Nút mở bản đồ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: Icon(Icons.map),
                        label: Text('Xem trên Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đánh giá ($_reviewCount)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddReviewDialog,
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text('Thêm đánh giá', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_reviews.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có đánh giá nào. Hãy là người đầu tiên!',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ..._reviews.map((review) => _buildReviewCard(review)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(AttractionReview review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (review.comment.isNotEmpty)
            Text(
              review.comment,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          SizedBox(height: 8),
          Text(
            _formatDate(review.dateTime),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

