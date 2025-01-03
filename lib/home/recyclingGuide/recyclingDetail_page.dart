import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecyclingDetailPage extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  const RecyclingDetailPage({required this.subcategoryId, required this.subcategoryName, Key? key}) : super(key: key);

  @override
  _RecyclingDetailPageState createState() => _RecyclingDetailPageState();
}

class _RecyclingDetailPageState extends State<RecyclingDetailPage> {
  Map<String, dynamic>? detail;
  bool isLoading = true;

  // 상세 데이터를 API로 가져오기
  Future<void> fetchDetail() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8001/detail/${widget.subcategoryId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          detail = json.decode(response.body).first; // API 응답에서 첫 번째 데이터 사용
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcategoryName), // 전달받은 카테고리 이름을 제목으로 설정
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail != null) ...[
              Image.network(detail!['guide_img'], fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(detail!['guide_content'], style: const TextStyle(fontSize: 16)),
            ] else
              const Text('No details available'),
          ],
        ),
      ),
    );
  }
}
