import 'package:flutter/material.dart';
import 'record_screen.dart';
import 'history_screen.dart'; // 稍后会创建这个文件

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iGree - 同意记录'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '欢迎使用 iGree',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40), // 增加间距
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('创建新的同意记录'),
              onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const RecordScreen()),
                 );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20), // 增加间距
            TextButton(
              onPressed: () {
                // 导航到查看历史记录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              child: const Text('查看历史记录'),
            )
          ],
        ),
      ),
    );
  }
}
