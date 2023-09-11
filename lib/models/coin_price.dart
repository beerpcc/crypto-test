import 'package:crypto_price/utils/database_util.dart';
import 'package:crypto_price/utils/util.dart';
import 'package:decimal/decimal.dart';
import 'package:sqflite/sqflite.dart';

class CoinPrice {
  final int? id;
  final String symbol;
  final String currency;
  final Decimal rate;
  final int updatedAt;

  const CoinPrice({
    this.id,
    required this.symbol,
    required this.currency,
    required this.rate,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'currency': currency,
      'rate': rate.toDouble(),
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'CoinPrice{id: $id, symbol: $symbol, currency: $currency, rate: $rate, updated_at: $updatedAt}';
  }
}