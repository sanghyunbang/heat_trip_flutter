import 'package:flutter/material.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({super.key});

  final List<Map<String, dynamic>> dummyExpenses = const [
    {
      "date": "2025-07-28",
      "category": "교통",
      "description": "기차 티켓",
      "amount": 45000,
    },
    {
      "date": "2025-07-29",
      "category": "음식",
      "description": "저녁 식사",
      "amount": 22000,
    },
    {
      "date": "2025-07-30",
      "category": "숙박",
      "description": "호텔 1박",
      "amount": 95000,
    },
  ];

  //총액 계산하는 부분
  int _calculateTotalAmount() {
    return dummyExpenses.fold(0, (sum, item) => sum + (item['amount'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final int totalAmount = _calculateTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 지출 내역'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyExpenses.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final expense = dummyExpenses[index];
          return ListTile(
            leading: Icon(Icons.attach_money, color: Colors.green[700]),
            title: Text('${expense["description"]} (${expense["category"]})'),
            subtitle: Text(expense["date"]),
            trailing: Text(
              '${expense["amount"]}원',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: const Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '총 사용 금액',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${totalAmount.toString()}원',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
