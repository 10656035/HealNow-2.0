import 'package:flutter/material.dart';
import 'home.dart';
import 'map.dart';
void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Title'),
      ),
      body: const Myhome(), // 將首頁視圖添加到主頁面
      drawer: const AppDrawer(), // 使用全局抽屜
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // 關閉抽屜
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('首頁'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
            // onTap: () {
            //   navigateToPage(context, MyApp());
            // },
          ),
          ListTile(
            title: const Text('闢謠專區'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('身體安全的新聞'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('藥局地圖'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
