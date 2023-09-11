import 'package:flutter/foundation.dart';

class Util {
  static bool isValidPinCode(String code) {

    // validate length
    if (code.length < 6) return false;

    int contiguousCount = 0;
    int sequenceCount = 0;
    int duplicatedPairCount = 0;
    int? prevNumber;
    for (String currentChar in code.split('')) {
      final int currentNumber = int.parse(currentChar);
      if (prevNumber != null) {

        // validate contiguous
        if (currentNumber == prevNumber) {
          contiguousCount++;
        } else {
          contiguousCount = 0;
        }

        // validate sequence
        if (currentNumber == prevNumber - 1 || currentNumber == prevNumber + 1) {
          sequenceCount++;
        } else {
          sequenceCount = 0;
        }

        // validate duplicated pair
        if (currentNumber == prevNumber) {
          duplicatedPairCount++;
        }
      }

      if (contiguousCount > 1) {
        return false;
      } else if (sequenceCount > 1) {
        return false;
      } else if (duplicatedPairCount > 2){
        return false;
      }

      prevNumber = currentNumber;
    }

    return true;
  }

  static List<int> generateFibonacci({List<int> result = const [], int amount = 0}) {
    var tmpResult = [...result];
    if (tmpResult.isEmpty) {
      tmpResult.addAll([0, 1]);
    }

    tmpResult.add(tmpResult[tmpResult.length - 1] + tmpResult[tmpResult.length - 2]);
    if (tmpResult.length >= amount) return tmpResult;

    return generateFibonacci(result: tmpResult, amount: amount);
  }

  static List<int> generatePrimeNumber(int amount) {
    var result = <int>[];
    int i = 0;

    outer:
    while(result.length < amount) {
      i++;
      if (i == 0 || i == 1) continue outer;
      for (int j = 2; j < i; j++) {
        if (i % j == 0) continue outer;
      }

      result.add(i);
    }

    return result;
  }

  static List<int> filterArray(List<int> first, List<int> second) {
    var result = <int>[];
    for (var i in first) {
      for (var j in second) {
        if (i == j) {
          result.add(i);
          break;
        }
      }
    }

    return result;
  }
}