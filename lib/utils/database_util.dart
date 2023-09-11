import 'package:crypto_price/models/coin_price.dart';
import 'package:decimal/decimal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtil {
  static Database? database;
  static Future<Database> init() async {
    if (database != null) return database!;
    database = await openDatabase(
      join(await getDatabasesPath(), 'crypto.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE coin_prices(id INTEGER PRIMARY KEY, symbol TEXT, currency TEXT, rate NUMERIC, updated_at INTEGER, UNIQUE(symbol, currency, updated_at) ON CONFLICT REPLACE)',
        );
      },
      version: 1,
    );

    return database!;
  }

  static Future<void> createCoinPrice(CoinPrice coinPrice) async {
    final db = await DatabaseUtil.init();
    await db.insert('coin_prices', coinPrice.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CoinPrice>> listCoinPrices(String currency) async {
    final db = await DatabaseUtil.init();
    final List<Map<String, dynamic>> maps = await db.query('coin_prices', where: "currency = ?", whereArgs: [currency], orderBy: "updated_at DESC");

    return List.generate(maps.length, (i) {
      return CoinPrice(
        id: maps[i]['id'],
        symbol: maps[i]['symbol'],
        currency: maps[i]['currency'],
        rate: Decimal.parse("${maps[i]['rate']}"),
        updatedAt: maps[i]['updated_at'],
      );
    });
  }
}