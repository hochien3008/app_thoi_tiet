import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import 'tourism_image_service.dart';

class TouristAttraction {
  final String id;
  final String name;
  final String city;
  final String description;
  final String category; // 'beach', 'mountain', 'cultural', 'nature', 'urban'
  final String bestSeason; // 'spring', 'summer', 'autumn', 'winter', 'all'
  final IconData icon;
  final double latitude;
  final double longitude;
  final String imageUrl;

  TouristAttraction({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.category,
    required this.bestSeason,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  // Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'description': description,
      'category': category,
      'bestSeason': bestSeason,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }

  // Create from Map
  factory TouristAttraction.fromJson(Map<String, dynamic> json) {
    return TouristAttraction(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      description: json['description'],
      category: json['category'],
      bestSeason: json['bestSeason'],
      icon: _getIconFromCategory(json['category']),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  static IconData _getIconFromCategory(String category) {
    switch (category) {
      case 'beach':
        return Icons.beach_access;
      case 'mountain':
        return Icons.landscape;
      case 'cultural':
        return Icons.temple_buddhist;
      case 'nature':
        return Icons.forest;
      case 'urban':
        return Icons.location_city;
      default:
        return Icons.place;
    }
  }
}

class TourismService {
  // Danh sách điểm du lịch phổ biến ở Việt Nam với đầy đủ thông tin
  static final List<TouristAttraction> _attractions = [
    // Hà Nội
    TouristAttraction(
      id: 'hanoi-ho-hoan-kiem',
      name: 'Hồ Hoàn Kiếm',
      city: 'Hà Nội',
      description: 'Trái tim của thủ đô, nơi lý tưởng để đi dạo và thư giãn',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.water,
      latitude: 21.0285,
      longitude: 105.8542,
      imageUrl: TourismImageService.getImageUrl('hanoi-ho-hoan-kiem', 'cultural', 'Hồ Hoàn Kiếm'),
    ),
    TouristAttraction(
      id: 'hanoi-van-mieu',
      name: 'Văn Miếu - Quốc Tử Giám',
      city: 'Hà Nội',
      description: 'Di tích lịch sử văn hóa quan trọng, nơi thờ Khổng Tử',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.temple_buddhist,
      latitude: 21.0278,
      longitude: 105.8342,
      imageUrl: TourismImageService.getImageUrl('hanoi-van-mieu', 'cultural', 'Văn Miếu - Quốc Tử Giám'),
    ),
    TouristAttraction(
      id: 'hanoi-pho-co',
      name: 'Phố cổ Hà Nội',
      city: 'Hà Nội',
      description: 'Khu phố cổ với 36 phố phường, nơi mua sắm và ẩm thực',
      category: 'urban',
      bestSeason: 'all',
      icon: Icons.store,
      latitude: 21.0333,
      longitude: 105.8500,
      imageUrl: TourismImageService.getImageUrl('hanoi-pho-co', 'urban', 'Phố cổ Hà Nội'),
    ),
    TouristAttraction(
      id: 'hanoi-lang-bac',
      name: 'Lăng Chủ tịch Hồ Chí Minh',
      city: 'Hà Nội',
      description: 'Nơi an nghỉ của Bác Hồ, di tích lịch sử quan trọng',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.account_balance,
      latitude: 21.0369,
      longitude: 105.8344,
      imageUrl: TourismImageService.getImageUrl('hanoi-lang-bac', 'cultural', 'Lăng Chủ tịch Hồ Chí Minh'),
    ),
    TouristAttraction(
      id: 'hanoi-chua-mot-cot',
      name: 'Chùa Một Cột',
      city: 'Hà Nội',
      description: 'Ngôi chùa độc đáo với kiến trúc một cột, biểu tượng Hà Nội',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.temple_buddhist,
      latitude: 21.0317,
      longitude: 105.8322,
      imageUrl: TourismImageService.getImageUrl('hanoi-chua-mot-cot', 'cultural', 'Chùa Một Cột'),
    ),
    TouristAttraction(
      id: 'hanoi-ho-tay',
      name: 'Hồ Tây',
      city: 'Hà Nội',
      description: 'Hồ lớn nhất Hà Nội, nơi thư giãn và ngắm cảnh đẹp',
      category: 'nature',
      bestSeason: 'all',
      icon: Icons.water,
      latitude: 21.0500,
      longitude: 105.8167,
      imageUrl: TourismImageService.getImageUrl('hanoi-ho-tay', 'nature', 'Hồ Tây'),
    ),

    // Hồ Chí Minh
    TouristAttraction(
      id: 'hcm-ben-nha-rong',
      name: 'Bến Nhà Rồng',
      city: 'Hồ Chí Minh',
      description: 'Bảo tàng Hồ Chí Minh, nơi Bác ra đi tìm đường cứu nước',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.museum,
      latitude: 10.7686,
      longitude: 106.7053,
      imageUrl: TourismImageService.getImageUrl('hcm-ben-nha-rong', 'cultural', 'Bến Nhà Rồng'),
    ),
    TouristAttraction(
      id: 'hcm-cho-ben-thanh',
      name: 'Chợ Bến Thành',
      city: 'Hồ Chí Minh',
      description: 'Chợ truyền thống nổi tiếng, nơi mua sắm và ẩm thực',
      category: 'urban',
      bestSeason: 'all',
      icon: Icons.shopping_bag,
      latitude: 10.7720,
      longitude: 106.6983,
      imageUrl: TourismImageService.getImageUrl('hcm-cho-ben-thanh', 'urban', 'Chợ Bến Thành'),
    ),
    TouristAttraction(
      id: 'hcm-nha-tho-duc-ba',
      name: 'Nhà thờ Đức Bà',
      city: 'Hồ Chí Minh',
      description: 'Nhà thờ cổ kính, biểu tượng của Sài Gòn',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.church,
      latitude: 10.7797,
      longitude: 106.6992,
      imageUrl: TourismImageService.getImageUrl('hcm-nha-tho-duc-ba', 'cultural', 'Nhà thờ Đức Bà'),
    ),
    TouristAttraction(
      id: 'hcm-pho-di-bo',
      name: 'Phố đi bộ Nguyễn Huệ',
      city: 'Hồ Chí Minh',
      description: 'Khu vực đi bộ sầm uất, nhiều hoạt động giải trí',
      category: 'urban',
      bestSeason: 'all',
      icon: Icons.directions_walk,
      latitude: 10.7756,
      longitude: 106.7019,
      imageUrl: TourismImageService.getImageUrl('hcm-pho-di-bo', 'urban', 'Phố đi bộ Nguyễn Huệ'),
    ),
    TouristAttraction(
      id: 'hcm-dinh-doc-lap',
      name: 'Dinh Độc Lập',
      city: 'Hồ Chí Minh',
      description: 'Di tích lịch sử quan trọng, nơi kết thúc chiến tranh',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.account_balance,
      latitude: 10.7770,
      longitude: 106.6950,
      imageUrl: TourismImageService.getImageUrl('hcm-dinh-doc-lap', 'cultural', 'Dinh Độc Lập'),
    ),
    TouristAttraction(
      id: 'hcm-bitexco',
      name: 'Tòa nhà Bitexco',
      city: 'Hồ Chí Minh',
      description: 'Tòa nhà cao nhất Sài Gòn, có đài quan sát trên tầng 49',
      category: 'urban',
      bestSeason: 'all',
      icon: Icons.business,
      latitude: 10.7717,
      longitude: 106.7042,
      imageUrl: TourismImageService.getImageUrl('hcm-bitexco', 'urban', 'Tòa nhà Bitexco'),
    ),

    // Đà Nẵng
    TouristAttraction(
      id: 'danang-my-khe',
      name: 'Bãi biển Mỹ Khê',
      city: 'Đà Nẵng',
      description: 'Bãi biển đẹp nhất Việt Nam, lý tưởng cho tắm biển',
      category: 'beach',
      bestSeason: 'summer',
      icon: Icons.beach_access,
      latitude: 16.0544,
      longitude: 108.2422,
      imageUrl: TourismImageService.getImageUrl('danang-my-khe', 'beach', 'Bãi biển Mỹ Khê'),
    ),
    TouristAttraction(
      id: 'danang-cau-rong',
      name: 'Cầu Rồng',
      city: 'Đà Nẵng',
      description: 'Cây cầu biểu tượng của Đà Nẵng, phun lửa vào cuối tuần',
      category: 'urban',
      bestSeason: 'all',
      icon: Icons.architecture,
      latitude: 16.0600,
      longitude: 108.2267,
      imageUrl: TourismImageService.getImageUrl('danang-cau-rong', 'urban', 'Cầu Rồng'),
    ),
    TouristAttraction(
      id: 'danang-ba-na',
      name: 'Bà Nà Hills',
      city: 'Đà Nẵng',
      description: 'Khu du lịch trên núi, có cáp treo dài nhất thế giới',
      category: 'mountain',
      bestSeason: 'spring',
      icon: Icons.landscape,
      latitude: 15.9981,
      longitude: 107.9992,
      imageUrl: TourismImageService.getImageUrl('danang-ba-na', 'mountain', 'Bà Nà Hills'),
    ),
    TouristAttraction(
      id: 'danang-linh-ung',
      name: 'Chùa Linh Ứng',
      city: 'Đà Nẵng',
      description: 'Ngôi chùa với tượng Phật Quan Âm cao 67m, nhìn ra biển',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.temple_buddhist,
      latitude: 16.0950,
      longitude: 108.2500,
      imageUrl: TourismImageService.getImageUrl('danang-linh-ung', 'cultural', 'Chùa Linh Ứng'),
    ),
    TouristAttraction(
      id: 'danang-non-nuoc',
      name: 'Làng đá Non Nước',
      city: 'Đà Nẵng',
      description: 'Làng nghề điêu khắc đá truyền thống nổi tiếng',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.handyman,
      latitude: 16.0167,
      longitude: 108.2500,
      imageUrl: TourismImageService.getImageUrl('danang-non-nuoc', 'cultural', 'Làng đá Non Nước'),
    ),

    // Huế
    TouristAttraction(
      id: 'hue-dai-noi',
      name: 'Đại Nội Huế',
      city: 'Huế',
      description: 'Kinh thành cổ, di sản văn hóa thế giới UNESCO',
      category: 'cultural',
      bestSeason: 'spring',
      icon: Icons.castle,
      latitude: 16.4681,
      longitude: 107.5761,
      imageUrl: TourismImageService.getImageUrl('hue-dai-noi', 'cultural', 'Đại Nội Huế'),
    ),
    TouristAttraction(
      id: 'hue-lang-tu-duc',
      name: 'Lăng Tự Đức',
      city: 'Huế',
      description: 'Lăng tẩm đẹp nhất của các vua Nguyễn',
      category: 'cultural',
      bestSeason: 'spring',
      icon: Icons.temple_hindu,
      latitude: 16.4333,
      longitude: 107.5667,
      imageUrl: TourismImageService.getImageUrl('hue-lang-tu-duc', 'cultural', 'Lăng Tự Đức'),
    ),
    TouristAttraction(
      id: 'hue-lang-khai-dinh',
      name: 'Lăng Khải Định',
      city: 'Huế',
      description: 'Lăng tẩm với kiến trúc độc đáo, kết hợp Đông Tây',
      category: 'cultural',
      bestSeason: 'spring',
      icon: Icons.temple_hindu,
      latitude: 16.4167,
      longitude: 107.5833,
      imageUrl: TourismImageService.getImageUrl('hue-lang-khai-dinh', 'cultural', 'Lăng Khải Định'),
    ),
    TouristAttraction(
      id: 'hue-song-huong',
      name: 'Sông Hương',
      city: 'Huế',
      description: 'Dòng sông thơ mộng chảy qua thành phố Huế',
      category: 'nature',
      bestSeason: 'spring',
      icon: Icons.water,
      latitude: 16.4667,
      longitude: 107.5833,
      imageUrl: TourismImageService.getImageUrl('hue-song-huong', 'nature', 'Sông Hương'),
    ),

    // Hội An
    TouristAttraction(
      id: 'hoian-pho-co',
      name: 'Phố cổ Hội An',
      city: 'Hội An',
      description: 'Phố cổ được UNESCO công nhận, đèn lồng rực rỡ',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.lightbulb,
      latitude: 15.8801,
      longitude: 108.3380,
      imageUrl: TourismImageService.getImageUrl('hoian-pho-co', 'cultural', 'Phố cổ Hội An'),
    ),
    TouristAttraction(
      id: 'hoian-an-bang',
      name: 'Bãi biển An Bàng',
      city: 'Hội An',
      description: 'Bãi biển hoang sơ, yên tĩnh, lý tưởng để nghỉ dưỡng',
      category: 'beach',
      bestSeason: 'summer',
      icon: Icons.beach_access,
      latitude: 15.8833,
      longitude: 108.3500,
      imageUrl: TourismImageService.getImageUrl('hoian-an-bang', 'beach', 'Bãi biển An Bàng'),
    ),
    TouristAttraction(
      id: 'hoian-cau-nhat-ban',
      name: 'Chùa Cầu Nhật Bản',
      city: 'Hội An',
      description: 'Cây cầu cổ do người Nhật xây dựng, biểu tượng Hội An',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.architecture,
      latitude: 15.8772,
      longitude: 108.3281,
      imageUrl: TourismImageService.getImageUrl('hoian-cau-nhat-ban', 'cultural', 'Chùa Cầu Nhật Bản'),
    ),

    // Nha Trang
    TouristAttraction(
      id: 'nhatrang-vinpearl',
      name: 'Vinpearl Land',
      city: 'Nha Trang',
      description: 'Khu vui chơi giải trí trên đảo, có cáp treo vượt biển',
      category: 'beach',
      bestSeason: 'summer',
      icon: Icons.attractions,
      latitude: 12.2383,
      longitude: 109.1967,
      imageUrl: TourismImageService.getImageUrl('nhatrang-vinpearl', 'beach', 'Vinpearl Land'),
    ),
    TouristAttraction(
      id: 'nhatrang-thap-ba',
      name: 'Tháp Bà Ponagar',
      city: 'Nha Trang',
      description: 'Tháp Chăm cổ, di tích văn hóa quan trọng',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.temple_buddhist,
      latitude: 12.2650,
      longitude: 109.1933,
      imageUrl: TourismImageService.getImageUrl('nhatrang-thap-ba', 'cultural', 'Tháp Bà Ponagar'),
    ),
    TouristAttraction(
      id: 'nhatrang-bai-tranh',
      name: 'Bãi biển Trần Phú',
      city: 'Nha Trang',
      description: 'Bãi biển dài đẹp, trung tâm thành phố Nha Trang',
      category: 'beach',
      bestSeason: 'summer',
      icon: Icons.beach_access,
      latitude: 12.2383,
      longitude: 109.1967,
      imageUrl: TourismImageService.getImageUrl('nhatrang-bai-tranh', 'beach', 'Bãi biển Trần Phú'),
    ),
    TouristAttraction(
      id: 'nhatrang-vinpearl-safari',
      name: 'Vinpearl Safari',
      city: 'Nha Trang',
      description: 'Vườn thú safari lớn nhất Việt Nam',
      category: 'nature',
      bestSeason: 'all',
      icon: Icons.forest,
      latitude: 12.2383,
      longitude: 109.1967,
      imageUrl: TourismImageService.getImageUrl('nhatrang-vinpearl-safari', 'nature', 'Vinpearl Safari'),
    ),

    // Đà Lạt
    TouristAttraction(
      id: 'dalat-ho-xuan-huong',
      name: 'Hồ Xuân Hương',
      city: 'Đà Lạt',
      description: 'Hồ nước đẹp giữa trung tâm thành phố',
      category: 'nature',
      bestSeason: 'all',
      icon: Icons.water,
      latitude: 11.9431,
      longitude: 108.4261,
      imageUrl: TourismImageService.getImageUrl('dalat-ho-xuan-huong', 'nature', 'Hồ Xuân Hương'),
    ),
    TouristAttraction(
      id: 'dalat-thung-lung-tinh-yeu',
      name: 'Thung lũng Tình Yêu',
      city: 'Đà Lạt',
      description: 'Khu du lịch lãng mạn, nhiều hoa và cảnh đẹp',
      category: 'nature',
      bestSeason: 'spring',
      icon: Icons.local_florist,
      latitude: 11.9167,
      longitude: 108.4167,
      imageUrl: TourismImageService.getImageUrl('dalat-thung-lung-tinh-yeu', 'nature', 'Thung lũng Tình Yêu'),
    ),
    TouristAttraction(
      id: 'dalat-dinh-bao-dai',
      name: 'Dinh Bảo Đại',
      city: 'Đà Lạt',
      description: 'Cung điện mùa hè của vua Bảo Đại',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.castle,
      latitude: 11.9333,
      longitude: 108.4333,
      imageUrl: TourismImageService.getImageUrl('dalat-dinh-bao-dai', 'cultural', 'Dinh Bảo Đại'),
    ),
    TouristAttraction(
      id: 'dalat-chua-linh-phong',
      name: 'Chùa Linh Phong',
      city: 'Đà Lạt',
      description: 'Ngôi chùa cổ với kiến trúc độc đáo',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.temple_buddhist,
      latitude: 11.9333,
      longitude: 108.4167,
      imageUrl: TourismImageService.getImageUrl('dalat-chua-linh-phong', 'cultural', 'Chùa Linh Phong'),
    ),
    TouristAttraction(
      id: 'dalat-vuon-hoa',
      name: 'Vườn hoa Đà Lạt',
      city: 'Đà Lạt',
      description: 'Vườn hoa đẹp với nhiều loài hoa đặc trưng Đà Lạt',
      category: 'nature',
      bestSeason: 'spring',
      icon: Icons.local_florist,
      latitude: 11.9333,
      longitude: 108.4333,
      imageUrl: TourismImageService.getImageUrl('dalat-vuon-hoa', 'nature', 'Vườn hoa Đà Lạt'),
    ),

    // Phú Quốc
    TouristAttraction(
      id: 'phuquoc-bai-sao',
      name: 'Bãi Sao',
      city: 'Phú Quốc',
      description: 'Bãi biển đẹp với cát trắng mịn, nước trong xanh',
      category: 'beach',
      bestSeason: 'winter',
      icon: Icons.beach_access,
      latitude: 10.2167,
      longitude: 103.9833,
      imageUrl: TourismImageService.getImageUrl('phuquoc-bai-sao', 'beach', 'Bãi Sao'),
    ),
    TouristAttraction(
      id: 'phuquoc-vuon-quoc-gia',
      name: 'Vườn Quốc gia Phú Quốc',
      city: 'Phú Quốc',
      description: 'Rừng nguyên sinh, đa dạng sinh học',
      category: 'nature',
      bestSeason: 'winter',
      icon: Icons.forest,
      latitude: 10.3333,
      longitude: 103.9167,
      imageUrl: TourismImageService.getImageUrl('phuquoc-vuon-quoc-gia', 'nature', 'Vườn Quốc gia Phú Quốc'),
    ),
    TouristAttraction(
      id: 'phuquoc-bai-dai',
      name: 'Bãi Dài',
      city: 'Phú Quốc',
      description: 'Bãi biển dài đẹp, hoang sơ',
      category: 'beach',
      bestSeason: 'winter',
      icon: Icons.beach_access,
      latitude: 10.2833,
      longitude: 103.9500,
      imageUrl: TourismImageService.getImageUrl('phuquoc-bai-dai', 'beach', 'Bãi Dài'),
    ),
    TouristAttraction(
      id: 'phuquoc-nha-tu-phu-quoc',
      name: 'Nhà tù Phú Quốc',
      city: 'Phú Quốc',
      description: 'Di tích lịch sử, nơi giam giữ tù binh thời chiến tranh',
      category: 'cultural',
      bestSeason: 'all',
      icon: Icons.museum,
      latitude: 10.2833,
      longitude: 103.9833,
      imageUrl: TourismImageService.getImageUrl('phuquoc-nha-tu-phu-quoc', 'cultural', 'Nhà tù Phú Quốc'),
    ),

    // Sapa
    TouristAttraction(
      id: 'sapa-fansipan',
      name: 'Đỉnh Fansipan',
      city: 'Sapa',
      description: 'Nóc nhà Đông Dương, đỉnh núi cao nhất Việt Nam',
      category: 'mountain',
      bestSeason: 'spring',
      icon: Icons.landscape,
      latitude: 22.3075,
      longitude: 103.7750,
      imageUrl: TourismImageService.getImageUrl('sapa-fansipan', 'mountain', 'Đỉnh Fansipan'),
    ),
    TouristAttraction(
      id: 'sapa-cat-cat',
      name: 'Bản Cát Cát',
      city: 'Sapa',
      description: 'Bản làng dân tộc H\'Mông, văn hóa truyền thống',
      category: 'cultural',
      bestSeason: 'spring',
      icon: Icons.home,
      latitude: 22.3333,
      longitude: 103.8167,
      imageUrl: TourismImageService.getImageUrl('sapa-cat-cat', 'cultural', 'Bản Cát Cát'),
    ),
    TouristAttraction(
      id: 'sapa-thac-bac',
      name: 'Thác Bạc',
      city: 'Sapa',
      description: 'Thác nước đẹp, cao hơn 200m',
      category: 'nature',
      bestSeason: 'spring',
      icon: Icons.water,
      latitude: 22.3500,
      longitude: 103.8333,
      imageUrl: TourismImageService.getImageUrl('sapa-thac-bac', 'nature', 'Thác Bạc'),
    ),

    // Mũi Né
    TouristAttraction(
      id: 'muine-sand-dunes',
      name: 'Đồi cát Mũi Né',
      city: 'Mũi Né',
      description: 'Đồi cát đỏ và trắng độc đáo, nơi chụp ảnh đẹp',
      category: 'nature',
      bestSeason: 'winter',
      icon: Icons.landscape,
      latitude: 10.9333,
      longitude: 108.2833,
      imageUrl: TourismImageService.getImageUrl('muine-sand-dunes', 'nature', 'Đồi cát Mũi Né'),
    ),
    TouristAttraction(
      id: 'muine-fairy-stream',
      name: 'Suối Tiên',
      city: 'Mũi Né',
      description: 'Dòng suối đẹp với đá nhiều màu sắc',
      category: 'nature',
      bestSeason: 'winter',
      icon: Icons.water,
      latitude: 10.9500,
      longitude: 108.2667,
      imageUrl: TourismImageService.getImageUrl('muine-fairy-stream', 'nature', 'Suối Tiên'),
    ),
  ];

  // Lấy danh sách điểm du lịch theo thành phố
  static List<TouristAttraction> getAttractionsByCity(String cityName) {
    return _attractions
        .where((attraction) =>
            attraction.city.toLowerCase() == cityName.toLowerCase())
        .toList();
  }

  // Lấy điểm du lịch theo ID
  static TouristAttraction? getAttractionById(String id) {
    try {
      return _attractions.firstWhere((attraction) => attraction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy tất cả điểm du lịch
  static List<TouristAttraction> getAllAttractions() {
    return _attractions;
  }

  // Gợi ý hoạt động ngoài trời dựa trên thời tiết
  static List<String> getActivitySuggestions(Weather weather) {
    final suggestions = <String>[];
    final condition = weather.mainCondition.toLowerCase();
    final temp = weather.temperature;
    final windSpeed = weather.windSpeed;

    // Dựa trên nhiệt độ
    if (temp >= 25 && temp <= 35) {
      if (condition.contains('clear') || condition.contains('sun')) {
        suggestions.add('🏖️ Tắm biển - Thời tiết nắng đẹp, nhiệt độ lý tưởng');
        suggestions.add('🏃 Chạy bộ buổi sáng - Nhiệt độ vừa phải');
        suggestions.add('🚴 Đạp xe - Gió nhẹ, trời quang');
      }
    }

    if (temp >= 20 && temp <= 28) {
      suggestions.add('🚶 Đi dạo - Thời tiết mát mẻ, dễ chịu');
      suggestions.add('📸 Chụp ảnh ngoài trời - Ánh sáng đẹp');
    }

    if (temp < 20) {
      suggestions.add('☕ Tham quan trong nhà - Thời tiết lạnh');
      suggestions.add('🏛️ Tham quan bảo tàng - Tránh lạnh');
    }

    // Dựa trên điều kiện thời tiết
    if (condition.contains('rain') || condition.contains('drizzle')) {
      suggestions.add('☔ Tham quan trong nhà - Trời mưa');
      suggestions.add('🏛️ Tham quan bảo tàng - Tránh mưa');
      suggestions.add('🛍️ Mua sắm trong trung tâm thương mại');
    }

    if (condition.contains('cloud')) {
      suggestions.add('🚶 Đi dạo - Trời mát, có mây che nắng');
      suggestions.add('📸 Chụp ảnh - Ánh sáng dịu nhẹ');
    }

    if (windSpeed > 15) {
      suggestions.add('⚠️ Tránh hoạt động ngoài trời - Gió mạnh');
    }

    // Gợi ý chung
    if (suggestions.isEmpty) {
      suggestions.add('🚶 Đi dạo khám phá thành phố');
      suggestions.add('📸 Chụp ảnh lưu niệm');
    }

    return suggestions;
  }

  // Kiểm tra thời tiết có lý tưởng cho du lịch không
  static Map<String, dynamic> getTravelWeatherRating(Weather weather) {
    final condition = weather.mainCondition.toLowerCase();
    final temp = weather.temperature;
    final windSpeed = weather.windSpeed;
    final humidity = weather.humidity;

    int score = 0;
    String rating = 'Tốt';
    String description = '';

    // Đánh giá nhiệt độ (20-30°C là lý tưởng)
    if (temp >= 20 && temp <= 30) {
      score += 3;
    } else if (temp >= 15 && temp < 20 || temp > 30 && temp <= 35) {
      score += 2;
    } else {
      score += 1;
    }

    // Đánh giá điều kiện thời tiết
    if (condition.contains('clear') || condition.contains('sun')) {
      score += 3;
      description = 'Trời nắng đẹp';
    } else if (condition.contains('cloud')) {
      score += 2;
      description = 'Có mây, mát mẻ';
    } else if (condition.contains('rain')) {
      score += 1;
      description = 'Có mưa';
    }

    // Đánh giá gió
    if (windSpeed < 10) {
      score += 2;
    } else if (windSpeed < 20) {
      score += 1;
    }

    // Đánh giá độ ẩm
    if (humidity >= 40 && humidity <= 70) {
      score += 1;
    }

    // Xác định rating
    if (score >= 8) {
      rating = 'Xuất sắc';
      description = 'Thời tiết hoàn hảo cho du lịch!';
    } else if (score >= 6) {
      rating = 'Tốt';
      description = 'Thời tiết tốt, phù hợp cho du lịch';
    } else if (score >= 4) {
      rating = 'Khá';
      description = 'Thời tiết khá, có thể đi du lịch';
    } else {
      rating = 'Không lý tưởng';
      description = 'Thời tiết không thuận lợi cho du lịch';
    }

    return {
      'score': score,
      'rating': rating,
      'description': description,
      'maxScore': 9,
    };
  }

  // Gợi ý thời điểm du lịch tốt nhất theo mùa
  static String getBestTravelTime(String cityName) {
    final cityLower = cityName.toLowerCase();
    
    if (cityLower.contains('hà nội') || cityLower.contains('hanoi')) {
      return 'Mùa thu (tháng 9-11): Thời tiết mát mẻ, dễ chịu nhất';
    } else if (cityLower.contains('hồ chí minh') || cityLower.contains('ho chi minh') || cityLower.contains('sài gòn')) {
      return 'Mùa khô (tháng 12-4): Ít mưa, nắng đẹp';
    } else if (cityLower.contains('đà nẵng') || cityLower.contains('da nang')) {
      return 'Mùa hè (tháng 5-8): Nắng đẹp, lý tưởng cho tắm biển';
    } else if (cityLower.contains('huế')) {
      return 'Mùa xuân (tháng 2-4): Thời tiết mát mẻ, ít mưa';
    } else if (cityLower.contains('hội an')) {
      return 'Quanh năm: Khí hậu ôn hòa, đặc biệt đẹp vào mùa thu';
    } else if (cityLower.contains('nha trang')) {
      return 'Mùa khô (tháng 1-8): Nắng đẹp, lý tưởng cho biển';
    } else if (cityLower.contains('đà lạt') || cityLower.contains('da lat')) {
      return 'Quanh năm: Khí hậu mát mẻ, đặc biệt đẹp vào mùa xuân';
    } else if (cityLower.contains('phú quốc') || cityLower.contains('phu quoc')) {
      return 'Mùa khô (tháng 11-3): Nắng đẹp, ít mưa';
    } else if (cityLower.contains('sapa')) {
      return 'Mùa xuân (tháng 3-5) và mùa thu (tháng 9-11): Thời tiết đẹp nhất';
    } else if (cityLower.contains('mũi né') || cityLower.contains('mui ne')) {
      return 'Mùa khô (tháng 11-4): Nắng đẹp, ít mưa';
    }
    
    return 'Quanh năm: Khí hậu phù hợp cho du lịch';
  }
}
