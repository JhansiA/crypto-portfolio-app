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
      var doc_id = queryDocumentSnapshot.id;
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      portfolioDetails[doc_id] = data['portfolioName'];
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

  static Future<void> createPortfolio(String uid, String portfolioname) async {
    await _firestore.collection("PortfolioDetails").doc().set({
      'UID': uid ,
      'portfolioName' : portfolioname ,
    });
  }

  static Future<void> setCryptoList(String docId, var coin) async {
      await _firestore.collection("CryptoCoins").doc().set({
        'portfolioID': docId,
        'CoinCode': coin.coinCode,
        'coinName' :coin.coinName,
        'coinIcon' :coin.coinIcon,
        'coinID'  : coin.coinID,
      });
  }

  static Future<void> deleteCryptoCoin (String portfolioID, var coin) async {
    var eventsQuery = await _firestore.collection('CryptoCoins')
        .where('portfolioID',isEqualTo: portfolioID).where('coinID',isEqualTo: coin).get();
    if(eventsQuery.size != 0){
      for (var queryDocumentSnapshot in eventsQuery.docs) {
        var doc_id = queryDocumentSnapshot.id;
        _firestore.collection('CryptoCoins').doc(doc_id).delete();
      }}
  }
}