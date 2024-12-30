import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/top_nav.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdateMemoPage extends StatefulWidget {
  final DateTime selectedDate;
  final dynamic memo;

  const UpdateMemoPage({
    Key? key,
    required this.selectedDate,
    required this.memo,
  }) : super(key: key);

  @override
  _UpdateMemoPageState createState() => _UpdateMemoPageState();
}

class _UpdateMemoPageState extends State<UpdateMemoPage> {
  late TextEditingController _nameController;
  late TextEditingController _everyController;
  late TextEditingController _memoController;
  bool _alarmEnabled = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.memo['user_calendar_name']);
    _everyController = TextEditingController(text: widget.memo['user_calendar_every']);
    _memoController = TextEditingController(text: widget.memo['user_calendar_memo']);
    _alarmEnabled = widget.memo['user_calendar_list'] ?? false;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await _storage.read(key: 'user_id');
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _updateMemo() async {
    if (_userId == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/update_alarm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'user_calendar_name': _nameController.text,
          'user_calendar_every': _everyController.text,
          'user_calendar_memo': _memoController.text,
          'user_calendar_date': widget.selectedDate.toIso8601String().split('T')[0],
          'user_calendar_list': _alarmEnabled,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람이 성공적으로 수정되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to update memo: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람 수정 실패')),
        );
      }
    } catch (error) {
      print('Error updating memo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _deleteMemo() async {
    if (_userId == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/deactivate_alarm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'user_calendar_date': widget.selectedDate.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람이 삭제되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to delete memo: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람 삭제 실패')),
        );
      }
    } catch (error) {
      print('Error deleting memo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavigationSection(
        title: '알람 수정',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.selectedDate.year}년 ${widget.selectedDate.month}월 ${widget.selectedDate.day}일',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '알림 이름'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _everyController,
              decoration: const InputDecoration(labelText: '반복 주기'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '메모 내용'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('알림 활성화', style: TextStyle(fontSize: 16)),
                CupertinoSwitch(
                  value: _alarmEnabled,
                  activeColor: CupertinoColors.activeGreen,
                  trackColor: CupertinoColors.inactiveGray,
                  thumbColor: CupertinoColors.white,
                  onChanged: (value) {
                    setState(() {
                      _alarmEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _deleteMemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('삭제'),
                ),
                ElevatedButton(
                  onPressed: _updateMemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('수정 완료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
