import 'dart:convert';

import 'package:crypto_price/models/coin_price.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class API {
  static const API_CRYPTO_PRICE = "https://api.coindesk.com/v1/bpi/currentprice.json";
  static final dio = Dio();

  static Future<Map<String, CoinPrice>> getCoinPrices() async {
    final response = await dio.get(API_CRYPTO_PRICE);
    final responJson = jsonDecode(response.data);
    final result = <String, CoinPrice>{};
    if (responJson["time"] != null) {
      final updatedAt = DateTime.parse(responJson["time"]["updatedISO"]).toUtc().millisecondsSinceEpoch ~/ 1000;
      final usdPrice = Decimal.fromJson(responJson["bpi"]["USD"]["rate_float"].toString());
      final gbpPrice = Decimal.fromJson(responJson["bpi"]["GBP"]["rate_float"].toString());
      final eurPrice = Decimal.fromJson(responJson["bpi"]["EUR"]["rate_float"].toString());

      result["USD"] = CoinPrice(symbol: 'BTC', currency: 'USD', rate: usdPrice, updatedAt: updatedAt);
      result["GBP"] = CoinPrice(symbol: 'BTC', currency: 'GBP', rate: gbpPrice, updatedAt: updatedAt);
      result["EUR"] = CoinPrice(symbol: 'BTC', currency: 'EUR', rate: eurPrice, updatedAt: updatedAt);
    }

    return result;
  }
}