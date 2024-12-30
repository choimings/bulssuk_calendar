import 'package:flutter/material.dart';
import 'updateMemo_page.dart'; // 수정 페이지 import
import 'package:http/http.dart' as http; // HTTP 요청
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedMemoPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<dynamic> initialMemoList; // 초기 메모 리스트

  const SavedMemoPage({
    Key? key,
    required this.selectedDate,
    required this.initialMemoList,
  }) : super(key: key);

  @override
  _SavedMemoPageState createState() => _SavedMemoPageState();
}

class _SavedMemoPageState extends State<SavedMemoPage> {
  late List<dynamic> memoList;

  @override
  void initState() {
    super.initState();
    memoList = widget.initialMemoList; // 초기 메모 리스트 설정
    _refreshMemoList(); // API를 호출해 메모 리스트 초기화
  }

  Future<void> _refreshMemoList() async {
    final storage = FlutterSecureStorage(); // Secure Storage 객체 생성
    String? userId = await storage.read(key: 'user_id'); // 저장된 user_id 읽기

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/date?user_id=$userId&user_calendar_date=${widget.selectedDate.toIso8601String().split('T')[0]}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedMemos = jsonDecode(response.body);
        setState(() {
          memoList = fetchedMemos; // 메모 리스트 업데이트
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메모를 불러오지 못했습니다: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching memos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget
                .selectedDate.day}일 메모'),
      ),
      body: memoList.isEmpty
          ? Center(child: Text('저장된 메모가 없습니다.', style: TextStyle(fontSize: 16)))
          : ListView.builder(
        itemCount: memoList.length,
        itemBuilder: (context, index) {
          final memo = memoList[index];
          return Card(
            child: ListTile(
              title: Text(memo['user_calendar_name']),
              subtitle: Text(memo['user_calendar_memo']),
              trailing: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateMemoPage(
                        memo: memo, // memo 객체 전달
                        selectedDate: widget.selectedDate,
                      ),
                    ),
                  );

                  if (result == true) {
                    _refreshMemoList(); // 데이터 갱신
                  }
                },
                child: const Text('수정'),
              ),
            ),
          );
        },
      ),
    );
  }
}