import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'heal_now.db');

    // 開啟連線
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // 關閉連線
  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }

  void _onCreate(Database db, int version) async {
    // 建立資料表
    await db.execute('''
      CREATE TABLE mood (
        id INTEGER PRIMARY KEY,
        content TEXT,
        mood_id INTEGER,
        ai_reply TEXT
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // 新增
  Future<int> insertData(Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient.insert('mood', data);
  }

  // 編輯
  Future<int> updateData(Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient.update(
      'mood',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // 取得所有資料
  Future<List<Map<String, dynamic>>> getAllData() async {
    var dbClient = await db;
    return await dbClient.query('mood');
  }
}
