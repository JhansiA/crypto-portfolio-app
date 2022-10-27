import 'package:http/http.dart' as http;
import 'dart:convert';

const String searchUrl = 'https://api.coingecko.com/api/v3/search?query';
const String coinPriceUrl = 'https://api.coingecko.com/api/v3/simple/price';
// ?ids=bitcoin-cash&vs_currencies=USD';

class CryptoApi {
//API call for All available coin List from coingecko

  Future<List<CoinData>> getAllCoinList() async {
    try {
      final response = await http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        List<CoinData> list = parseData(response.body);
        // print(list.length);
        return list;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  List<CoinData> parseData(String responseBody) {
    final parsed = jsonDecode(responseBody)['coins'].cast<Map<String, dynamic>>();
    return parsed.map<CoinData>((json) => CoinData.fromJson(json)).toList();
  }

  Future<Map<String,double>> getCoinData(selectedCurrency) async{
    Map<String,double> cryptoPrices = {};
    if(selectedCurrency.length != 0){
    String coins = selectedCurrency.join(",");
     // late String price;
      String requestURL = '$coinPriceUrl?ids=$coins&vs_currencies=USD';
      http.Response response = await http.get(Uri.parse(requestURL));
      if(response.statusCode==200){
        var decodedData = jsonDecode(response.body);
        for (var coin in selectedCurrency) {
          cryptoPrices[coin] = decodedData[coin]['usd'].toDouble();
          // .toStringAsFixed(3);
          // cryptoPrices[crypto] = price.toStringAsFixed(0);
        }
      }
      else{print(response.statusCode);}}
    return cryptoPrices;
  }
}
// bitcoin.usd
// rate
class CoinData {
  String coinName;
  String coinCode;
  String coinIcon;
  String coinID;

  CoinData({
    required this.coinName,
    required this.coinCode,
    required this.coinIcon,
    required this.coinID,
  });

  factory CoinData.fromJson(Map<String, dynamic> json) {
    return CoinData(
      coinName: json['name'] as String,
      coinCode: json['symbol'] as String,
      coinIcon: json['thumb'] as String,
      coinID: json['id'] as String,
    );
  }
}