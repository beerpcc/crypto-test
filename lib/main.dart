import 'package:crypto_price/models/coin_price.dart';
import 'package:crypto_price/utils/API.dart';
import 'package:crypto_price/utils/database_util.dart';
import 'package:crypto_price/utils/util.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> selectedCurrency = {'USD'};
  Map<String, CoinPrice>? coinPrices;
  Decimal? convertInputValue;
  int selectedTabIndex = 0;
  bool pincodeValid = false;
  List<CoinPrice> priceHistory = [];

  var firstArray = [1, 4, 7, 2, 8];
  var secondArray = [10, 2, 1, 9, 20];

  @override
  void initState() {
    updateCoinPrices();
    super.initState();
  }

  Future getCoinPrices() async {
    coinPrices = await API.getCoinPrices();

    if (coinPrices!.isNotEmpty) {
      for (CoinPrice coinPrice in coinPrices!.values) {
        debugPrint("${coinPrice}");
        await DatabaseUtil.createCoinPrice(coinPrice);
      }
    }
    priceHistory.clear();
    priceHistory = await DatabaseUtil.listCoinPrices(selectedCurrency.first);
    setState(() {});
  }

  Future updateCoinPrices() async {
    if (!mounted) return;
    debugPrint("Updating coin prices (${DateTime.now()})");

    await getCoinPrices();
    await Future.delayed(const Duration(minutes: 1));
    updateCoinPrices();
  }

  Widget cryptoPriceWidget() {
    Decimal? coinPriceRate = coinPrices?[selectedCurrency.first]?.rate;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: <Widget>[
        SegmentedButton<String>(
          segments: const <ButtonSegment<String>>[
            ButtonSegment<String>(value: 'USD', label: Text('USD')),
            ButtonSegment<String>(value: 'GBP', label: Text('GBP')),
            ButtonSegment<String>(value: 'EUR', label: Text('EUR')),
          ],
          selected: selectedCurrency,
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              selectedCurrency = newSelection;
              getCoinPrices();
            });
          },
          multiSelectionEnabled: false,
        ),
        SizedBox(height: 20,),
        Text("${coinPriceRate} ${selectedCurrency.first} = 1 BTC", style: TextStyle(fontSize: 22),),
        Divider(),
        Text("Convert ${selectedCurrency.first} to BTC", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 12,),
        SizedBox(
          width: 200,
          child: TextField(
            autofocus: false,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
              hintText: 'Input ${selectedCurrency.first}'
            ),
            onChanged: (text) {
              setState(() {
                convertInputValue = Decimal.tryParse(text);
              });
            },
          ),
        ),
        Text("= ${convertInputValue != null ? (convertInputValue!.toRational() * (Decimal.one/coinPriceRate!)).toDouble() : ''} BTC", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Divider(),
        Text("Price History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Column(
          children: priceHistory.map((coinPrice) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text("1 BTC = ${coinPrice.rate} ${coinPrice.currency} @ ${DateTime.fromMillisecondsSinceEpoch(coinPrice.updatedAt * 1000)}"),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget pincodeWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              autofocus: false,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
                hintText: 'Input Pincode'
              ),
              onChanged: (text) {
                setState(() {
                  pincodeValid = Util.isValidPinCode(text);
                });
              },
            ),
          ),
          pincodeValid ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: Colors.green,),
              Text("Valid", style: TextStyle(color: Colors.green, fontSize: 16),)
            ],
          ) : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close, color: Colors.red,),
              Text("Invalid", style: TextStyle(color: Colors.red, fontSize: 16),)
            ],
          )
        ],
      )
    );
  }

  Widget bonusWidget() {
    return Column(
      children: [
        Text("Fibonacci", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text("${Util.generateFibonacci(amount: 50)}"),
        Divider(),
        Text("Prime Number", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text("${Util.generatePrimeNumber(50)}"),
        Divider(),
        Text("Filter Array", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text("First: $firstArray"),
        Text("Second: $secondArray"),
        Text("Result: ${Util.filterArray(firstArray, secondArray)}"),
      ],
    );
  }

  Widget getWidget() {
    if (selectedTabIndex == 0) {
      return cryptoPriceWidget();
    } else if (selectedTabIndex == 1) {
      return pincodeWidget();
    } else {
      return bonusWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: getWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 14,
        selectedFontSize: 14,
        currentIndex: selectedTabIndex,
        onTap: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin_outlined), label: 'Crypto Price'),
          BottomNavigationBarItem(icon: Icon(Icons.pin), label: 'Validate Pincode'),
          BottomNavigationBarItem(icon: Icon(Icons.plus_one_rounded), label: 'Bonus')
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
