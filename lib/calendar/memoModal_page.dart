import 'package:flutter/material.dart';

class MemoModalPage extends StatelessWidget {
  final DateTime selectedDate; // 선택된 날짜
  final String alarmName; // 알람 이름
  final String alarmFrequency; // 반복 주기
  final String alarmMemo; // 알람 메모
  final VoidCallback onViewAll; // 메모 전체보기 콜백

  const MemoModalPage({
    Key? key,
    required this.selectedDate,
    required this.alarmName,
    required this.alarmFrequency,
    required this.alarmMemo,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: onViewAll, // 메모 전체보기 페이지로 이동
                  child: const Text('메모 전체보기'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: '알림 이름',
                border: OutlineInputBorder(),
                hintText: alarmName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: '알림 설정',
                border: OutlineInputBorder(),
                hintText: alarmFrequency,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '알림 메모',
                border: OutlineInputBorder(),
                hintText: alarmMemo,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // 모달 닫기
                  child: const Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}