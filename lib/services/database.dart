import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class Database{
  late User loggedInUser;

  User getCurrentUser(){
      final user = _auth.currentUser;
      if(user != null) {
        loggedInUser = user;
      }
      return loggedInUser;
    }

  static Future<Map<String,String>> getPortfolioInfo(userID) async{
    Map<String,String> portfolioDetails ={};
    var eventsQuery = await _firestore.collection('PortfolioDetails')
          .where('UID',isEqualTo: userID).get();
    if(eventsQuery.size != 0){
    for (var queryDocumentSnapshot in eventsQuery.docs) {
      var docId = queryDocumentSnapshot.id;
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      portfolioDetails[docId] = data['portfolioName'];
    }
    }
    return portfolioDetails;
  }

  static Future<Map<String,dynamic>> getPortfolioCoinInfo(portfolioID) async{
    Map<String,dynamic> coinDetails ={};
    var eventsQuery = await _firestore.collection('CryptoCoins')
        .where('portfolioID',isEqualTo: portfolioID).get();
    // coinDetails = eventsQuery.docs as Map<String, String>;
    if(eventsQuery.size != 0){
    for (var queryDocumentSnapshot in eventsQuery.docs) {
      Map<String,dynamic> data = queryDocumentSnapshot.data();
      coinDetails[data['coinID'].toString()]= data;
    }}
    return coinDetails;
  }

  static Future<void> createPortfolio(String uid, String portfolioName) async {
    await _firestore.collection("PortfolioDetails").doc().set({
      'UID': uid ,
      'portfolioName' : portfolioName ,
    });
  }

  static Future<void> setCryptoList(String docId, var coin) async {
      await _firestore.collection("CryptoCoins").doc().set({
        'portfolioID': docId,
        'coinCode': coin.coinCode,
        'coinName' :coin.coinName,
        'coinIcon' :coin.coinIcon,
        'coinID'  : coin.coinID,
        'totalQuantity' : 0,
        'totalCost' : 0,
        'averagePrice' : 0,
      });
  }

  static Future<void> addTransactions (String docId, String coin,double coinPrice,double quantity,double cost,String type,String date) async {
    await _firestore.collection("CoinTransactions").doc().set({
      'portfolioID': docId,
      'coin': coin,
      'coinPrice' :coinPrice,
      'cost' :cost,
      'quantity'  : quantity,
      'transactionType'  : type,
      'date'  : date,
      'timeStamp': Timestamp.now(),
    });
  }

  static Future<void> updateCryptoCoin (String portfolioId, String coin,double coinPrice,double quantity,double cost,String type) async {
    var eventsQuery = await _firestore.collection('CryptoCoins')
        .where('portfolioID',isEqualTo: portfolioId).where('coinCode',isEqualTo: coin).get();
    if(eventsQuery.size != 0){
      for (var queryDocumentSnapshot in eventsQuery.docs) {
        String docId = queryDocumentSnapshot.id;
        Map<String,dynamic> data = queryDocumentSnapshot.data();

        double totalQuantity = (type == 'Buy') ? data['totalQuantity']+quantity :data['totalQuantity']-quantity;
        double totalCost = (type == 'Buy') ? data['totalCost']+cost :data['totalCost']-cost;
        double averagePrice = double.parse((totalCost / totalQuantity).toStringAsFixed(3));

        _firestore.collection('CryptoCoins').doc(docId)
            .update({"totalQuantity":totalQuantity,"totalCost":totalCost,"averagePrice":averagePrice});
      }
    }
  }

  static Future<void> deleteCryptoCoin (String portfolioID, var coin, var coinCode) async {
    var eventsQuery = await _firestore.collection('CryptoCoins')
        .where('portfolioID',isEqualTo: portfolioID).where('coinID',isEqualTo: coin).get();
    if(eventsQuery.size != 0){
      for (var queryDocumentSnapshot in eventsQuery.docs) {
        var docId = queryDocumentSnapshot.id;
        _firestore.collection('CryptoCoins').doc(docId).delete();
      }}
    var eventsQuery1 = await _firestore.collection('CoinTransactions')
        .where('portfolioID',isEqualTo: portfolioID).where('coin',isEqualTo: coinCode).get();
    if(eventsQuery1.size != 0){
      for (var queryDocumentSnapshot in eventsQuery1.docs) {
        var docId = queryDocumentSnapshot.id;
        _firestore.collection('CoinTransactions').doc(docId).delete();
      }}
  }

  static void deletePortfolio (String portfolioID) {
        _firestore.collection('PortfolioDetails').doc(portfolioID).delete();
  }

  static void updatePortfolio (String portfolioID, String title) {
    _firestore.collection('PortfolioDetails').doc(portfolioID)
        .update({"portfolioName":title});
  }
}