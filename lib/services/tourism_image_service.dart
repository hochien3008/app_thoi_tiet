class TourismImageService {
  // Mapping từ ID điểm du lịch đến ảnh local trong assets/images
  // Ưu tiên sử dụng ảnh local cho tất cả các thành phố (trừ Phú Quốc và Mũi Né)
  static final Map<String, String> _localImagePaths = {
    // Hà Nội
    'hanoi-ho-hoan-kiem': 'assets/images/Ho_hoan_kiem_HN.jpg',
    'hanoi-van-mieu': 'assets/images/Van_mieu_quoc_tu_giam_HN.webp',
    'hanoi-pho-co': 'assets/images/Pho_co_HN.jpg',
    'hanoi-lang-bac': 'assets/images/Lang_chu_tich_Ho_Chi_Minh_HN.jpg',
    'hanoi-chua-mot-cot': 'assets/images/Chua_mot_cot_HN.jpg',
    'hanoi-ho-tay': 'assets/images/Ho_tay_HN.jpg',

    // Hồ Chí Minh
    'hcm-ben-nha-rong': 'assets/images/Ben_nha_rong_HCM.jpg',
    'hcm-cho-ben-thanh': 'assets/images/Cho_Ben_Thanh_HCM.jpg',
    'hcm-dinh-doc-lap': 'assets/images/Dinh_doc_lap_HCM.jpg',
    'hcm-nha-tho-duc-ba': 'assets/images/Nha_tho_duc_ba_HMC.jpg',
    'hcm-pho-di-bo': 'assets/images/Pho_di_bo_nguyen_hue_HCM.jpg',
    'hcm-bitexco': 'assets/images/toa_nha_bitexco_HCM.jpg',

    // Đà Nẵng
    'danang-my-khe': 'assets/images/Bai_bien_my_khe_DN.webp',
    'danang-cau-rong': 'assets/images/Cau_rong_DN.jpg',
    'danang-ba-na': 'assets/images/Ba_na_hills_DN.jpg',
    'danang-linh-ung': 'assets/images/Chua_linh_ung_DN.jpg',
    'danang-non-nuoc': 'assets/images/Lang_da_non_nuoc_DN.jpg',

    // Huế
    'hue-dai-noi': 'assets/images/Dai_noi_Hue.jpg',
    'hue-lang-khai-dinh': 'assets/images/Lang_Khai_Dinh_Hue.jpg',
    'hue-lang-tu-duc': 'assets/images/Lang_tu_duc_Hue.JPG',
    'hue-song-huong': 'assets/images/song_huong_hue.jpg',

    // Hội An
    'hoian-pho-co': 'assets/images/Pho_co_Hoi_an.jpeg',
    'hoian-an-bang': 'assets/images/Bai_bien_An_bang_HA.jpeg',
    'hoian-cau-nhat-ban': 'assets/images/Chua_cau_nhat_ban_HA.jpg',

    // Nha Trang
    'nhatrang-vinpearl': 'assets/images/Vinperl_land_NhaTrang.jpg',
    'nhatrang-thap-ba': 'assets/images/Thap_ba_ponagar_NT.jpg',
    'nhatrang-bai-tranh': 'assets/images/Bai_bien_tran_phu_NT.jpg',
    'nhatrang-vinpearl-safari': 'assets/images/Vinpearl-safari-Nha-Trang.jpg',

    // Đà Lạt
    'dalat-ho-xuan-huong': 'assets/images/ho-xuan-huong-da-lat.png',
    'dalat-thung-lung-tinh-yeu': 'assets/images/Thung-lung-tinh-yeu-DL.jpg',
    'dalat-dinh-bao-dai': 'assets/images/dinh-bao-dai-DL.webp',
    'dalat-chua-linh-phong': 'assets/images/chua-linh-phong-DL.jpg',
    'dalat-vuon-hoa': 'assets/images/vuon-hoa-thanh-pho-da-lat.jpg',

    // Sapa
    'sapa-fansipan': 'assets/images/dinh-fansipan-Sapa.png',
    'sapa-cat-cat': 'assets/images/Ban-cat-cat-Sapa.jpg',
    'sapa-thac-bac': 'assets/images/Thac-bac-Sapa.jpg',
  };

  // Lấy URL ảnh cho điểm du lịch
  static String getImageUrl(String attractionId, String category, String name) {
    // Chỉ sử dụng ảnh local
    if (_localImagePaths.containsKey(attractionId)) {
      return _localImagePaths[attractionId]!;
    }

    // Nếu không có ảnh local, trả về chuỗi rỗng
    // Widget sẽ tự xử lý hiển thị placeholder hoặc icon
    return '';
  }
}
