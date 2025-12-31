// Danh sách các thành phố/tỉnh phổ biến ở Việt Nam
class VietnamCities {
  static const List<String> cities = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Hải Phòng',
    'Cần Thơ',
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bạc Liêu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cao Bằng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Tĩnh',
    'Hải Dương',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
    // Thêm một số thành phố phổ biến khác
    'Vũng Tàu',
    'Nha Trang',
    'Huế',
    'Quy Nhơn',
    'Quy Nhon', // Biến thể không dấu
    'Qui Nhon', // Biến thể với chữ "i" (từ API)
    'Phan Thiết',
    'Vinh',
    'Buôn Ma Thuột',
    'Pleiku',
    'Rạch Giá',
    'Long Xuyên',
    'Mỹ Tho',
    'Tân An',
    'Cao Lãnh',
    'Sa Đéc',
    // Thêm các biến thể tên thành phố (API có thể trả về format khác)
    'Ho Chi Minh City',
    'Ho Chi Minh',
    'Hanoi',
    'Ha Noi',
    'Da Nang',
    'Hai Phong',
    'Can Tho',
    'Hue',
    'Nha Trang',
    'Vung Tau',
    'Quy Nhon',
    'Qui Nhon', // Biến thể với chữ "i"
    'Phan Thiet',
    'Buon Ma Thuot',
    'My Tho',
    'Rach Gia',
    'Long Xuyen',
    'Cao Lanh',
    'Sa Dec',
    'Thanh Hoa',
    'Thai Nguyen',
    'Thai Binh',
    'Nam Dinh',
    'Hai Duong',
    'Hung Yen',
    'Ha Nam',
    'Ninh Binh',
    'Bac Ninh',
    'Bac Giang',
    'Phu Tho',
    'Vinh Phuc',
    'Yen Bai',
    'Tuyen Quang',
    'Lao Cai',
    'Lai Chau',
    'Dien Bien',
    'Son La',
    'Hoa Binh',
    'Lang Son',
    'Cao Bang',
    'Ha Giang',
    'Bac Kan',
    'Quang Ninh',
    'Quang Binh',
    'Quang Tri',
    'Thua Thien Hue',
    'Quang Nam',
    'Quang Ngai',
    'Binh Dinh',
    'Phu Yen',
    'Khanh Hoa',
    'Ninh Thuan',
    'Binh Thuan',
    'Kon Tum',
    'Gia Lai',
    'Dak Lak',
    'Dak Nong',
    'Lam Dong',
    'Binh Phuoc',
    'Tay Ninh',
    'Binh Duong',
    'Dong Nai',
    'Ba Ria Vung Tau',
    'Long An',
    'Tien Giang',
    'Ben Tre',
    'Tra Vinh',
    'Vinh Long',
    'Dong Thap',
    'An Giang',
    'Kien Giang',
    'Can Tho',
    'Hau Giang',
    'Soc Trang',
    'Bac Lieu',
    'Ca Mau',
  ];

  // Lọc danh sách thành phố theo từ khóa
  static List<String> searchCities(String query) {
    if (query.isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    final vietnameseQuery = _removeVietnameseAccents(lowerQuery);

    // Lọc và loại bỏ trùng lặp
    final Set<String> uniqueCities = {};

    for (final city in cities) {
      final lowerCity = city.toLowerCase();
      final vietnameseCity = _removeVietnameseAccents(lowerCity);

      // Tìm kiếm theo tên gốc hoặc tên không dấu
      if (lowerCity.contains(lowerQuery) ||
          vietnameseCity.contains(vietnameseQuery)) {
        uniqueCities.add(city);
      }
    }

    return uniqueCities.toList();
  }

  // Chuyển đổi tên thành phố không dấu (từ API) sang tên có dấu (để hiển thị)
  static String getCityNameWithAccents(String cityNameWithoutAccents) {
    // Xử lý đặc biệt cho Qui/Quy Nhon -> Quy Nhơn
    final lowerInput = cityNameWithoutAccents.toLowerCase().trim();
    if (lowerInput == 'qui nhon' || lowerInput == 'quy nhon') {
      return 'Quy Nhơn';
    }

    // Nếu tên đã có dấu, trả về luôn
    // Loại bỏ các từ như "City", "Province" ở cuối
    String cleanedInput = lowerInput
        .replaceAll(RegExp(r'\s+city$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+province$', caseSensitive: false), '')
        .trim();

    final inputWithoutAccents = _removeVietnameseAccents(cleanedInput);

    // Tìm trong danh sách thành phố - ưu tiên tên có dấu
    String? bestMatchWithoutAccents;

    for (final city in cities) {
      final lowerCity = city.toLowerCase();
      final cityWithoutAccents = _removeVietnameseAccents(lowerCity);

      // So sánh không phân biệt hoa thường và không dấu
      if (inputWithoutAccents == cityWithoutAccents ||
          cleanedInput == lowerCity ||
          lowerInput == lowerCity) {
        // Ưu tiên tên có dấu (có ký tự đặc biệt tiếng Việt)
        if (city != _removeVietnameseAccents(city)) {
          // Tên có dấu - ưu tiên cao nhất
          if (!city.contains('City') && city.length > 0) {
            return city;
          }
        } else if (bestMatchWithoutAccents == null) {
          // Tên không dấu - chỉ dùng nếu chưa có match nào
          if (!city.contains('City') && city.length > 0) {
            bestMatchWithoutAccents = city;
          }
        }
      }
    }

    // Nếu có match (dù không dấu), trả về
    if (bestMatchWithoutAccents != null) {
      return bestMatchWithoutAccents;
    }

    // Nếu không tìm thấy, thử tìm một phần (partial match)
    for (final city in cities) {
      final lowerCity = city.toLowerCase();
      final cityWithoutAccents = _removeVietnameseAccents(lowerCity);

      // Kiểm tra nếu input chứa tên thành phố hoặc ngược lại
      if (inputWithoutAccents.contains(cityWithoutAccents) ||
          cityWithoutAccents.contains(inputWithoutAccents)) {
        if (cityWithoutAccents.length >= 3) {
          // Chỉ match nếu đủ dài
          return city;
        }
      }
    }

    // Nếu không tìm thấy, trả về tên gốc
    return cityNameWithoutAccents;
  }

  // Loại bỏ dấu tiếng Việt để tìm kiếm dễ hơn
  static String _removeVietnameseAccents(String str) {
    const Map<String, String> vietnameseToEnglish = {
      'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
      'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
      'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
      'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
      'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
      'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
      'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
      'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
      'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
      'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
      'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
      'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
      'đ': 'd',
      // Uppercase versions
      'À': 'A', 'Á': 'A', 'Ạ': 'A', 'Ả': 'A', 'Ã': 'A',
      'Â': 'A', 'Ầ': 'A', 'Ấ': 'A', 'Ậ': 'A', 'Ẩ': 'A', 'Ẫ': 'A',
      'Ă': 'A', 'Ằ': 'A', 'Ắ': 'A', 'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
      'È': 'E', 'É': 'E', 'Ẹ': 'E', 'Ẻ': 'E', 'Ẽ': 'E',
      'Ê': 'E', 'Ề': 'E', 'Ế': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
      'Ì': 'I', 'Í': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
      'Ò': 'O', 'Ó': 'O', 'Ọ': 'O', 'Ỏ': 'O', 'Õ': 'O',
      'Ô': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ộ': 'O', 'Ổ': 'O', 'Ỗ': 'O',
      'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O', 'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
      'Ù': 'U', 'Ú': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U',
      'Ư': 'U', 'Ừ': 'U', 'Ứ': 'U', 'Ự': 'U', 'Ử': 'U', 'Ữ': 'U',
      'Ỳ': 'Y', 'Ý': 'Y', 'Ỵ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y',
      'Đ': 'D',
    };

    String result = str;
    vietnameseToEnglish.forEach((vietnamese, english) {
      result = result.replaceAll(vietnamese, english);
    });
    return result;
  }
}
