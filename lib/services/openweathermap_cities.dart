/// Danh sách các tên thành phố Việt Nam được OpenWeatherMap API hỗ trợ
///
/// API OpenWeatherMap thường nhận diện các tên thành phố bằng tiếng Anh (không dấu)
/// hoặc tên thành phố chính của tỉnh/thành phố đó.
class OpenWeatherMapCities {
  /// Danh sách các tên thành phố được API hỗ trợ trực tiếp
  static const List<String> supportedCityNames = [
    // Thành phố trực thuộc Trung ương
    'Hanoi', // Hà Nội
    'Ho Chi Minh City', // Hồ Chí Minh (có thể dùng "Ho Chi Minh" hoặc "Saigon")
    'Ho Chi Minh', // Hồ Chí Minh
    'Saigon', // Sài Gòn (tên cũ)
    'Da Nang', // Đà Nẵng
    'Turan', // Đà Nẵng (tên khác)
    'Hai Phong', // Hải Phòng
    'Can Tho', // Cần Thơ
    // Các thành phố/tỉnh lỵ phổ biến
    'Ha Long', // Hạ Long (Quảng Ninh)
    'Hue', // Huế (Thừa Thiên Huế)
    'Nha Trang', // Nha Trang (Khánh Hòa)
    'Da Lat', // Đà Lạt (Lâm Đồng)
    'Vung Tau', // Vũng Tàu (Bà Rịa - Vũng Tàu)
    'Phan Thiet', // Phan Thiết (Bình Thuận)
    'Quy Nhon', // Quy Nhơn (Bình Định)
    'Hoi An', // Hội An (Quảng Nam)
    'Dong Hoi', // Đồng Hới (Quảng Bình)
    'Dong Ha', // Đông Hà (Quảng Trị)
    'Quang Ngai', // Quảng Ngãi
    'Tuy Hoa', // Tuy Hòa (Phú Yên)
    'Buon Ma Thuot', // Buôn Ma Thuột (Đắk Lắk)
    'Dak Nong', // Đắk Nông
    'Pleiku', // Pleiku (Gia Lai)
    'Kon Tum', // Kon Tum
    'Rach Gia', // Rạch Giá (Kiên Giang)
    'Long Xuyen', // Long Xuyên (An Giang)
    'My Tho', // Mỹ Tho (Tiền Giang)
    'Cao Lanh', // Cao Lãnh (Đồng Tháp)
    'Thu Dau Mot', // Thủ Dầu Một (Bình Dương)
    'Dong Xoai', // Đồng Xoài (Bình Phước)
    'Bien Hoa', // Biên Hòa (Đồng Nai)
    'Vinh', // Vinh (Nghệ An)
    'Thanh Hoa', // Thanh Hóa
    'Ha Tinh', // Hà Tĩnh
    'Nam Dinh', // Nam Định
    'Thai Binh', // Thái Bình
    'Hai Duong', // Hải Dương
    'Hung Yen', // Hưng Yên
    'Bac Ninh', // Bắc Ninh
    'Thai Nguyen', // Thái Nguyên
    'Lang Son', // Lạng Sơn
    'Lao Cai', // Lào Cai
    'Yen Bai', // Yên Bái
    'Tuyen Quang', // Tuyên Quang
    'Cao Bang', // Cao Bằng
    'Bac Kan', // Bắc Kạn
    'Ha Giang', // Hà Giang
    'Dien Bien Phu', // Điện Biên Phủ (Điện Biên)
    'Lai Chau', // Lai Châu
    'Son La', // Sơn La
    'Hoa Binh', // Hòa Bình
    'Phu Tho', // Phú Thọ
    'Vinh Yen', // Vĩnh Yên (Vĩnh Phúc)
    'Bac Giang', // Bắc Giang
    'Ninh Binh', // Ninh Bình
    'Phan Rang', // Phan Rang (Ninh Thuận)
    'Ca Mau', // Cà Mau
    'Bac Lieu', // Bạc Liêu
    'Soc Trang', // Sóc Trăng
    'Tra Vinh', // Trà Vinh
    'Ben Tre', // Bến Tre
    'Tay Ninh', // Tây Ninh
    'Long An', // Long An
    'Tien Giang', // Tiền Giang
    'Dong Thap', // Đồng Tháp
    'An Giang', // An Giang
    'Kien Giang', // Kiên Giang
    'Can Tho', // Cần Thơ
    'Hau Giang', // Hậu Giang
  ];

  /// Mapping từ tên tỉnh/thành phố Việt Nam sang tên được API hỗ trợ
  static const Map<String, String> provinceToCityMapping = {
    // Thành phố trực thuộc Trung ương
    'Hà Nội': 'Hanoi',
    'Ha Noi': 'Hanoi',
    'Hồ Chí Minh': 'Ho Chi Minh City',
    'Ho Chi Minh': 'Ho Chi Minh City',
    'Sài Gòn': 'Saigon',
    'Sai Gon': 'Saigon',
    'Đà Nẵng': 'Da Nang',
    'Da Nang': 'Da Nang',
    'Hải Phòng': 'Hai Phong',
    'Hai Phong': 'Hai Phong',
    'Cần Thơ': 'Can Tho',
    'Can Tho': 'Can Tho',

    // Các tỉnh
    'Quảng Ninh': 'Ha Long',
    'Quang Ninh': 'Ha Long',
    'Thừa Thiên Huế': 'Hue',
    'Thua Thien Hue': 'Hue',
    'Khánh Hòa': 'Nha Trang',
    'Khanh Hoa': 'Nha Trang',
    'Lâm Đồng': 'Da Lat',
    'Lam Dong': 'Da Lat',
    'Bà Rịa - Vũng Tàu': 'Vung Tau',
    'Ba Ria - Vung Tau': 'Vung Tau',
    'Bình Thuận': 'Phan Thiet',
    'Binh Thuan': 'Phan Thiet',
    'Bình Định': 'Quy Nhon',
    'Binh Dinh': 'Quy Nhon',
    'Quảng Nam': 'Hoi An',
    'Quang Nam': 'Hoi An',
    'Quảng Bình': 'Dong Hoi',
    'Quang Binh': 'Dong Hoi',
    'Quảng Trị': 'Dong Ha',
    'Quang Tri': 'Dong Ha',
    'Quảng Ngãi': 'Quang Ngai',
    'Quang Ngai': 'Quang Ngai',
    'Phú Yên': 'Tuy Hoa',
    'Phu Yen': 'Tuy Hoa',
    'Đắk Lắk': 'Buon Ma Thuot',
    'Dak Lak': 'Buon Ma Thuot',
    'Đắk Nông': 'Dak Nong',
    'Dak Nong': 'Dak Nong',
    'Gia Lai': 'Pleiku',
    'Kon Tum': 'Kon Tum',
    'Kiên Giang': 'Rach Gia',
    'Kien Giang': 'Rach Gia',
    'An Giang': 'Long Xuyen',
    'Tiền Giang': 'My Tho',
    'Tien Giang': 'My Tho',
    'Đồng Tháp': 'Cao Lanh',
    'Dong Thap': 'Cao Lanh',
    'Bình Dương': 'Thu Dau Mot',
    'Binh Duong': 'Thu Dau Mot',
    'Bình Phước': 'Dong Xoai',
    'Binh Phuoc': 'Dong Xoai',
    'Đồng Nai': 'Bien Hoa',
    'Dong Nai': 'Bien Hoa',
    'Nghệ An': 'Vinh',
    'Nghe An': 'Vinh',
    'Thanh Hóa': 'Thanh Hoa',
    'Thanh Hoa': 'Thanh Hoa',
    'Hà Tĩnh': 'Ha Tinh',
    'Ha Tinh': 'Ha Tinh',
    'Ninh Thuận': 'Phan Rang',
    'Ninh Thuan': 'Phan Rang',
    'Vĩnh Phúc': 'Vinh Yen',
    'Vinh Phuc': 'Vinh Yen',
    'Vĩnh Yên': 'Vinh Yen',
  };

  /// Lấy danh sách tất cả các tên thành phố được hỗ trợ (bao gồm cả mapping)
  static List<String> getAllSupportedNames() {
    final allNames = <String>[...supportedCityNames];
    allNames.addAll(provinceToCityMapping.values.toSet());
    return allNames.toSet().toList()..sort();
  }

  /// Mapping từ tên API (không dấu) sang tên tiếng Việt có dấu để hiển thị
  static const Map<String, String> apiNameToVietnamese = {
    // Thành phố trực thuộc Trung ương
    'Hanoi': 'Hà Nội',
    'Ho Chi Minh City': 'Hồ Chí Minh',
    'Ho Chi Minh': 'Hồ Chí Minh',
    'Saigon': 'Sài Gòn',
    'Da Nang': 'Đà Nẵng',
    'Turan': 'Đà Nẵng',
    'Hai Phong': 'Hải Phòng',
    'Can Tho': 'Cần Thơ',

    // Các thành phố/tỉnh lỵ
    'Ha Long': 'Hạ Long',
    'Hue': 'Huế',
    'Nha Trang': 'Nha Trang', // Tên riêng, không có dấu
    'Da Lat': 'Đà Lạt',
    'Vung Tau': 'Vũng Tàu',
    'Phan Thiet': 'Phan Thiết',
    'Quy Nhon': 'Quy Nhơn',
    'Hoi An': 'Hội An',
    'Dong Hoi': 'Đồng Hới',
    'Dong Ha': 'Đông Hà',
    'Quang Ngai': 'Quảng Ngãi',
    'Tuy Hoa': 'Tuy Hòa',
    'Buon Ma Thuot': 'Buôn Ma Thuột',
    'Dak Nong': 'Đắk Nông',
    'Pleiku': 'Pleiku', // Tên riêng, không có dấu
    'Kon Tum': 'Kon Tum', // Tên riêng, không có dấu
    'Rach Gia': 'Rạch Giá',
    'Long Xuyen': 'Long Xuyên',
    'My Tho': 'Mỹ Tho',
    'Cao Lanh': 'Cao Lãnh',
    'Thu Dau Mot': 'Thủ Dầu Một',
    'Dong Xoai': 'Đồng Xoài',
    'Bien Hoa': 'Biên Hòa',
    'Vinh': 'Vinh', // Tên riêng, không có dấu
    'Thanh Hoa': 'Thanh Hóa',
    'Ha Tinh': 'Hà Tĩnh',
    'Nam Dinh': 'Nam Định',
    'Thai Binh': 'Thái Bình',
    'Hai Duong': 'Hải Dương',
    'Hung Yen': 'Hưng Yên',
    'Bac Ninh': 'Bắc Ninh',
    'Thai Nguyen': 'Thái Nguyên',
    'Lang Son': 'Lạng Sơn',
    'Lao Cai': 'Lào Cai',
    'Yen Bai': 'Yên Bái',
    'Tuyen Quang': 'Tuyên Quang',
    'Cao Bang': 'Cao Bằng',
    'Bac Kan': 'Bắc Kạn',
    'Ha Giang': 'Hà Giang',
    'Dien Bien Phu': 'Điện Biên Phủ',
    'Lai Chau': 'Lai Châu',
    'Son La': 'Sơn La',
    'Hoa Binh': 'Hòa Bình',
    'Phu Tho': 'Phú Thọ',
    'Vinh Yen': 'Vĩnh Yên',
    'Bac Giang': 'Bắc Giang',
    'Ninh Binh': 'Ninh Bình',
    'Phan Rang': 'Phan Rang', // Tên riêng, không có dấu
    'Ca Mau': 'Cà Mau',
    'Bac Lieu': 'Bạc Liêu',
    'Soc Trang': 'Sóc Trăng',
    'Tra Vinh': 'Trà Vinh',
    'Ben Tre': 'Bến Tre',
    'Tay Ninh': 'Tây Ninh',
    'Long An': 'Long An', // Tên riêng, không có dấu
    'Tien Giang': 'Tiền Giang',
    'Dong Thap': 'Đồng Tháp',
    'An Giang': 'An Giang',
    'Kien Giang': 'Kiên Giang',
    'Hau Giang': 'Hậu Giang',
  };

  /// Lấy tên hiển thị từ tên API
  /// Các tên riêng không dấu (Nha Trang, Pleiku, Vinh, Phan Rang, Kon Tum, Long An) giữ nguyên
  /// Các tỉnh khác hiển thị có dấu
  static String getDisplayName(String apiName) {
    // Danh sách các tên riêng không dấu - giữ nguyên khi hiển thị
    const preservedNames = {
      'Nha Trang',
      'Pleiku',
      'Vinh',
      'Phan Rang',
      'Kon Tum',
      'Long An',
    };

    // Nếu là tên riêng không dấu, giữ nguyên
    if (preservedNames.contains(apiName)) {
      return apiName;
    }

    // Các tỉnh khác: lấy từ apiNameToVietnamese (đã có dấu)
    return apiNameToVietnamese[apiName] ?? apiName;
  }

  /// Lấy danh sách các tên thành phố để hiển thị gợi ý
  /// Chỉ hiển thị tên thành phố thực sự được API hỗ trợ, không hiển thị tên tỉnh
  /// Sử dụng getDisplayName để hiển thị có dấu (trừ các tên riêng không dấu)
  static List<String> getVietnameseCityNames() {
    final vietnameseNames = <String>{};

    // Lấy tất cả các tên thành phố từ apiNameToVietnamese
    // Sử dụng getDisplayName để lấy tên hiển thị (có dấu cho các tỉnh, giữ nguyên cho tên riêng)
    for (final entry in apiNameToVietnamese.entries) {
      final apiName = entry.key;
      final displayName = getDisplayName(apiName);
      vietnameseNames.add(displayName);
    }

    return vietnameseNames.toList()..sort();
  }

  /// Tìm kiếm thành phố theo query (trả về tên tiếng Việt có dấu)
  static List<String> searchCities(String query) {
    final queryLower = query.toLowerCase();
    final allNames = getVietnameseCityNames();

    return allNames.where((name) {
      final nameLower = name.toLowerCase();
      final nameWithoutAccents = removeVietnameseAccents(nameLower);
      final queryWithoutAccents = removeVietnameseAccents(queryLower);

      return nameLower.contains(queryLower) ||
          nameWithoutAccents.contains(queryWithoutAccents);
    }).toList();
  }

  /// Loại bỏ dấu tiếng Việt (public để sử dụng ở các service khác)
  static String removeVietnameseAccents(String str) {
    const Map<String, String> vietnameseToEnglish = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
    };

    String result = str;
    vietnameseToEnglish.forEach((vietnamese, english) {
      result = result.replaceAll(vietnamese, english);
      result = result.replaceAll(
        vietnamese.toUpperCase(),
        english.toUpperCase(),
      );
    });
    return result;
  }

  /// Lấy tên API từ tên tiếng Việt (để gửi lên API)
  static String getApiName(String vietnameseName) {
    // Kiểm tra trong mapping tỉnh -> thành phố
    final mapped = provinceToCityMapping[vietnameseName];
    if (mapped != null) {
      return mapped;
    }

    // Kiểm tra trong reverse mapping (tên tiếng Việt -> tên API)
    for (final entry in apiNameToVietnamese.entries) {
      if (entry.value == vietnameseName) {
        return entry.key;
      }
    }

    // Nếu không tìm thấy, trả về tên không dấu
    return removeVietnameseAccents(vietnameseName);
  }
}
