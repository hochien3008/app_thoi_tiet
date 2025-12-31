class TourismImageService {
  // Mapping từ ID điểm du lịch đến ảnh local trong assets/images
  // Ưu tiên sử dụng ảnh local cho Huế và Hồ Chí Minh
  static final Map<String, String> _localImagePaths = {
    // Hồ Chí Minh - sử dụng ảnh local
    'hcm-ben-nha-rong': 'assets/images/Ben_nha_rong_HCM.jpg',
    'hcm-cho-ben-thanh': 'assets/images/Cho_Ben_Thanh_HCM.jpg',
    'hcm-dinh-doc-lap': 'assets/images/Dinh_doc_lap_HCM.jpg',
    'hcm-nha-tho-duc-ba': 'assets/images/Nha_tho_duc_ba_HMC.jpg',
    'hcm-pho-di-bo': 'assets/images/Pho_di_bo_nguyen_hue_HCM.jpg',
    'hcm-bitexco': 'assets/images/toa_nha_bitexco_HCM.jpg',
    
    // Huế - sử dụng ảnh local
    'hue-dai-noi': 'assets/images/Dai_noi_Hue.jpg',
    'hue-lang-khai-dinh': 'assets/images/Lang_Khai_Dinh_Hue.jpg',
    'hue-lang-tu-duc': 'assets/images/Lang_tu_duc_Hue.JPG',
    'hue-song-huong': 'assets/images/song_huong_hue.jpg',
  };

  // Mapping từ ID điểm du lịch đến từ khóa tìm kiếm ảnh phù hợp
  // Sử dụng Unsplash Source API với từ khóa cụ thể cho từng điểm du lịch
  static final Map<String, String> _imageKeywords = {
    // Hà Nội
    'hanoi-ho-hoan-kiem': 'hoan-kiem-lake,vietnam,water',
    'hanoi-van-mieu': 'temple,vietnam,ancient,confucius',
    'hanoi-pho-co': 'old-street,vietnam,hanoi,traditional',
    'hanoi-lang-bac': 'mausoleum,vietnam,monument,ho-chi-minh',
    'hanoi-chua-mot-cot': 'one-pillar-pagoda,vietnam,buddhist-temple',
    'hanoi-ho-tay': 'west-lake,vietnam,water,scenic',

    // Hồ Chí Minh
    'hcm-ben-nha-rong': 'museum,vietnam,ho-chi-minh,historical',
    'hcm-cho-ben-thanh': 'market,vietnam,shopping,traditional-market',
    'hcm-nha-tho-duc-ba': 'cathedral,church,vietnam,saigon',
    'hcm-pho-di-bo': 'pedestrian-street,urban,vietnam,nightlife',
    'hcm-dinh-doc-lap': 'independence-palace,vietnam,historical',
    'hcm-bitexco': 'skyscraper,modern-building,vietnam,saigon',

    // Đà Nẵng
    'danang-my-khe': 'beach,vietnam,da-nang,tropical',
    'danang-cau-rong': 'dragon-bridge,vietnam,architecture,night',
    'danang-ba-na': 'mountain,cable-car,vietnam,resort',
    'danang-linh-ung': 'buddha-statue,temple,vietnam,coastal',
    'danang-non-nuoc': 'stone-sculpture,craft,vietnam,traditional',

    // Huế
    'hue-dai-noi': 'imperial-citadel,ancient,vietnam,unesco',
    'hue-lang-tu-duc': 'tomb,ancient-architecture,vietnam,royal',
    'hue-lang-khai-dinh': 'tomb,architecture,vietnam,royal',
    'hue-song-huong': 'river,vietnam,scenic,romantic',

    // Hội An
    'hoian-pho-co': 'ancient-town,lanterns,vietnam,unesco',
    'hoian-an-bang': 'beach,paradise,vietnam,pristine',
    'hoian-cau-nhat-ban': 'japanese-bridge,ancient,vietnam,historical',

    // Nha Trang
    'nhatrang-vinpearl': 'island-resort,amusement-park,vietnam',
    'nhatrang-thap-ba': 'cham-tower,ancient-temple,vietnam',
    'nhatrang-bai-tranh': 'beach,coast,vietnam,tropical',
    'nhatrang-vinpearl-safari': 'zoo,animals,safari,vietnam',

    // Đà Lạt
    'dalat-ho-xuan-huong': 'lake,mountain,vietnam,scenic',
    'dalat-thung-lung-tinh-yeu': 'valley,flowers,romantic,vietnam',
    'dalat-dinh-bao-dai': 'palace,colonial-architecture,vietnam',
    'dalat-chua-linh-phong': 'buddhist-temple,architecture,vietnam',
    'dalat-vuon-hoa': 'flower-garden,colorful,vietnam,spring',

    // Phú Quốc
    'phuquoc-bai-sao': 'tropical-beach,paradise,vietnam,white-sand',
    'phuquoc-vuon-quoc-gia': 'tropical-forest,jungle,vietnam',
    'phuquoc-bai-dai': 'long-beach,pristine,vietnam,tropical',
    'phuquoc-nha-tu-phu-quoc': 'historical-site,war-museum,vietnam',

    // Sapa
    'sapa-fansipan': 'mountain-peak,summit,vietnam,highest',
    'sapa-cat-cat': 'village,ethnic-minority,vietnam,hmong',
    'sapa-thac-bac': 'waterfall,mountain,vietnam,scenic',

    // Mũi Né
    'muine-sand-dunes': 'sand-dunes,desert,vietnam,red-sand',
    'muine-fairy-stream': 'stream,colorful-rocks,vietnam,nature',
  };

  // Mapping photo ID từ Pexels cho từng điểm du lịch (ảnh chất lượng cao, phù hợp)
  static final Map<String, String> _pexelsPhotoIds = {
    // Hà Nội - Lakes & Water
    'hanoi-ho-hoan-kiem': '2901209', // Lake
    'hanoi-ho-tay': '2901209',
    'hue-song-huong': '2901209',
    'dalat-ho-xuan-huong': '2901209',
    
    // Temples & Cultural
    'hanoi-van-mieu': '1578662996442',
    'hanoi-chua-mot-cot': '1547036967',
    'hanoi-lang-bac': '1559827260',
    'hcm-nha-tho-duc-ba': '1515542622106',
    'hcm-dinh-doc-lap': '1559827260',
    'hcm-ben-nha-rong': '1559827260',
    'danang-linh-ung': '1547036967',
    'danang-non-nuoc': '1578662996442',
    'hue-dai-noi': '1578662996442',
    'hue-lang-tu-duc': '1547036967',
    'hue-lang-khai-dinh': '1547036967',
    'hoian-pho-co': '1528181304800',
    'hoian-cau-nhat-ban': '1518568814500',
    'nhatrang-thap-ba': '1547036967',
    'dalat-chua-linh-phong': '1547036967',
    'phuquoc-nha-tu-phu-quoc': '1559827260',
    'sapa-cat-cat': '1528181304800',
    
    // Urban & Streets
    'hanoi-pho-co': '1528181304800',
    'hcm-cho-ben-thanh': '1556911220',
    'hcm-pho-di-bo': '1514565131',
    'hcm-bitexco': '1480714378408',
    'danang-cau-rong': '1518568814500',
    
    // Beaches
    'danang-my-khe': '1507525428034',
    'hoian-an-bang': '1507525428034',
    'nhatrang-vinpearl': '1507525428034',
    'nhatrang-bai-tranh': '1507525428034',
    'phuquoc-bai-sao': '1507525428034',
    'phuquoc-bai-dai': '1507525428034',
    
    // Mountains & Nature
    'danang-ba-na': '1506905925346',
    'sapa-fansipan': '1506905925346',
    'sapa-thac-bac': '1506905925346',
    'dalat-thung-lung-tinh-yeu': '1506905925346',
    'dalat-vuon-hoa': '1506905925346',
    'phuquoc-vuon-quoc-gia': '1506905925346',
    'nhatrang-vinpearl-safari': '1506905925346',
    'muine-sand-dunes': '1506905925346',
    'muine-fairy-stream': '1506905925346',
    
    // Palaces & Historical
    'dalat-dinh-bao-dai': '1578662996442',
  };

  // Lấy URL ảnh cho điểm du lịch
  // Sử dụng nhiều nguồn với fallback
  static String getImageUrl(String attractionId, String category, String name) {
    // Ưu tiên 1: Sử dụng ảnh local từ assets/images (cho Huế và HCM)
    if (_localImagePaths.containsKey(attractionId)) {
      return _localImagePaths[attractionId]!;
    }

    // Ưu tiên 2: Sử dụng Pexels photo ID cụ thể (chất lượng cao, phù hợp)
    if (_pexelsPhotoIds.containsKey(attractionId)) {
      final photoId = _pexelsPhotoIds[attractionId]!;
      return _getPexelsImageUrl(photoId);
    }

    // Ưu tiên 3: Sử dụng từ khóa cụ thể từ mapping với Unsplash
    if (_imageKeywords.containsKey(attractionId)) {
      final keywords = _imageKeywords[attractionId]!;
      return _getUnsplashImageUrl(keywords);
    }

    // Fallback: Sử dụng từ khóa theo category
    final fallbackKeywords = _getKeywordsForCategory(category, name);
    return _getUnsplashImageUrl(fallbackKeywords);
  }

  // Lấy ảnh từ Unsplash Source API (miễn phí, không cần key)
  static String _getUnsplashImageUrl(String keywords) {
    // Unsplash Source API: https://source.unsplash.com/{width}x{height}/?{keywords}
    // Sử dụng từ khóa được encode
    final encodedKeywords = keywords.replaceAll(' ', ',').replaceAll(',,', ',');
    return 'https://source.unsplash.com/800x600/?$encodedKeywords';
  }

  // Lấy ảnh từ Pexels với photo ID cụ thể (chất lượng cao hơn)
  static String _getPexelsImageUrl(String photoId) {
    // Pexels Source API: https://images.pexels.com/photos/{id}/pexels-photo-{id}.jpeg
    return 'https://images.pexels.com/photos/$photoId/pexels-photo-$photoId.jpeg?auto=compress&cs=tinysrgb&w=800&h=600&fit=crop';
  }

  // Lấy từ khóa phù hợp theo category (fallback)
  static String _getKeywordsForCategory(String category, String name) {
    switch (category) {
      case 'beach':
        return 'tropical-beach,paradise,ocean,vietnam';
      case 'mountain':
        return 'mountain,summit,landscape,vietnam';
      case 'cultural':
        return 'temple,ancient,architecture,vietnam';
      case 'nature':
        return 'nature,scenic,landscape,vietnam';
      case 'urban':
        return 'city,urban,modern,vietnam';
      default:
        return 'vietnam,tourism,travel';
    }
  }

  // Lấy ảnh từ Pexels (backup option - cần API key cho production)
  static String getPexelsImage(String keywords) {
    // Pexels Source API không hỗ trợ search trực tiếp
    // Cần sử dụng Pexels API với key
    return _getUnsplashImageUrl(keywords); // Fallback về Unsplash
  }
}

