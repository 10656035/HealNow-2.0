import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'news_info.dart';
import 'data/dbhelper.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(createDatabaseConnection());
    _loadAllData(); // 初始化時載入所有資料
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 載入所有數據
  Future<void> _loadAllData() async {
    await _databaseHelper.openConnection();
    final data = await _databaseHelper.fetchNewsData();
    await _databaseHelper.closeConnection();

    print(data);

    setState(() {
      _allData = data;
      _searchResults = data;
      isLoading = false;
    });
  }

  Future<void> _searchData(String searchTerm) async {
    if (searchTerm.isEmpty) {
      // 如果搜索文本為空，顯示所有資料
      setState(() {
        _searchResults = _allData;
      });
    } else {
      final results = _allData.where((item) =>
          item['title'].toLowerCase().contains(searchTerm.toLowerCase()));

      setState(() {
        _searchResults = results.toList();
      });
    }
  }

  void _navigateToDetailPage(String itemTitle, int itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsInfoPage(title: itemTitle, id: itemId),
      ),
    );
  }

  final List<IconData> randomIcons = [
    Icons.newspaper,
    Icons.menu_book,
    Icons.local_library,
    Icons.email
  ];

  // 獲取隨機圖示的方法
  IconData getRandomIcon() {
    final random = Random();
    final randomIndex = random.nextInt(randomIcons.length);
    return randomIcons[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 243, 251),
      appBar: AppBar(
        title: const Text(
          '食藥新聞',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 94, 190, 250),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '輸入搜尋文字',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchData(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final id = _searchResults[index]['id'];
                      final title = _searchResults[index]['title'];
                      final publishDate = _searchResults[index]['publish_date'];
                      final permitDateFormat = DateFormat('yyyy-MM-dd');
                      final formatpublishDate = permitDateFormat.format(publishDate);

                      return Column(children: [
                        ListTile(
                          leading: Icon(getRandomIcon(),
                              color: const Color.fromARGB(255, 22, 50, 255)),
                          title: Text('$title'),
                          subtitle: Text(formatpublishDate),
                          onTap: () {
                            _navigateToDetailPage(title, id);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(height: 1, color: Colors.grey),
                        ),
                      ]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
