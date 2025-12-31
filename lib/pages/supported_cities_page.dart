import 'package:flutter/material.dart';
import '../services/openweathermap_cities.dart';

/// Trang hiển thị danh sách các tên thành phố được OpenWeatherMap API hỗ trợ
class SupportedCitiesPage extends StatelessWidget {
  const SupportedCitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final allSupportedNames = OpenWeatherMapCities.getAllSupportedNames();
    final mapping = OpenWeatherMapCities.provinceToCityMapping;

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        title: const Text('Tên thành phố được hỗ trợ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin chung
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tổng số: ${allSupportedNames.length} tên thành phố',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'API OpenWeatherMap thường nhận diện tên thành phố bằng tiếng Anh (không dấu) hoặc tên thành phố chính của tỉnh/thành phố.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Danh sách tên thành phố được hỗ trợ trực tiếp
                const Text(
                  'Tên thành phố được hỗ trợ trực tiếp:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allSupportedNames.map((name) {
                        return Chip(
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[50],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mapping từ tỉnh sang thành phố
                const Text(
                  'Mapping từ tỉnh/thành phố sang tên được hỗ trợ:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mapping.length,
                    itemBuilder: (context, index) {
                      final entry = mapping.entries.elementAt(index);
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Text(
                          entry.value,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

