import 'package:flutter/material.dart';

class SavedMemoPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<dynamic> memoList; // 메모 리스트

  const SavedMemoPage({
    Key? key,
    required this.selectedDate,
    required this.memoList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 메모'),
      ),
      body: ListView.builder(
        itemCount: memoList.length,
        itemBuilder: (context, index) {
          final memo = memoList[index];
          return Card(
            child: ListTile(
              title: Text(memo['user_calendar_name']),
              subtitle: Text(memo['user_calendar_memo']),
              trailing: Text(memo['user_calendar_every']),
            ),
          );
        },
      ),
    );
  }
}
