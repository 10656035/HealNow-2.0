import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDateString(String dateString) {
  DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  DateTime dateTime = inputFormat.parse(dateString, true).toLocal();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

class RumorDetailPage extends StatefulWidget {
  final Map<String, dynamic> rumors;

  const RumorDetailPage({Key? key, required this.rumors}) : super(key: key);

  @override
  State<RumorDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<RumorDetailPage> {
  late String token;
  bool? isFavorite;

  @override
  void initState() {
    super.initState();

    loadToken().then((loadedToken) {
      token = loadedToken; // 在 Future 完成後設置 token
      // 取得收藏列表進行比對，以顯示收藏icon類型
      fetchSavedRumors().then((savedRumors) {
        setState(() {
          isFavorite = savedRumors
              .any((savedRumor) => savedRumor['id'] == widget.rumors['id']);
        });
      }).catchError((error) {
        print('Error fetching saved rumors: $error');
      });
    });
  }

  Future<String> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // 取得收藏列表
  Future<List<dynamic>> fetchSavedRumors() async {
    final url = Uri.parse('https://healnow.azurewebsites.net/opendatas/save_class/3');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load saved rumors');
    }
  }

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.parse(
        'https://healnow.azurewebsites.net/opendatas/save_class/3/${widget.rumors['id']}');
        
    http.Response response;

    // 如果 isFavorite 是 true，執行移除收藏
    if (isFavorite == true) {
      response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } else {
      // 如果 isFavorite 是 false，執行新增收藏
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    }

    if (response.statusCode == 200) {
      setState(() {
        // 改變收藏icon
        isFavorite = !(isFavorite ?? false);
      });
    } else {
      print('Error updating favorite status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '闢謠內容',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                isFavorite == true ? Icons.bookmark : Icons.bookmark_border),
            onPressed: toggleFavoriteStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailItem(Icons.star_half, widget.rumors['title'],
                formatDateString(widget.rumors['publish_date'])),
            Divider(),
            detailItem(Icons.my_library_books, '內文',
                widget.rumors['content'].replaceAll('。 ', '。\n\n')),
            Divider(),
            detailItem(Icons.language, '連結', widget.rumors['url']),
          ],
        ),
      ),
    );
  }

  Widget detailItem(IconData icon, String title, String? value) {
    String displayValue = (value == null || value.isEmpty) ? '未提供' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Icon(icon),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(displayValue),
          ),
        ],
      ),
    );
  }
}
