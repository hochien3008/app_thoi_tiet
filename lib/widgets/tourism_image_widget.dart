import 'package:flutter/material.dart';

/// Widget để hiển thị ảnh du lịch, tự động phát hiện local asset hoặc network image
class TourismImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const TourismImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  /// Kiểm tra xem imageUrl có phải là local asset không
  static bool isLocalAsset(String url) {
    return url.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    if (isLocalAsset(imageUrl)) {
      // Sử dụng Image.asset cho ảnh local
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              );
        },
      );
    } else {
      // Sử dụng Image.network cho ảnh từ internet
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
        },
      );
    }
  }
}

