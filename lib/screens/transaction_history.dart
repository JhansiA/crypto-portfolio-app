import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;

class CoinTransactions extends StatelessWidget {
  const CoinTransactions({Key? key}) : super(key: key);
  static const String id = 'transactions_history';

  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)?.settings.arguments as List<dynamic>;
    final portfolioId = data[0];
    final coinDetails = data[1];
    final holdingValue = data[2];
    final profitLoss = holdingValue - (coinDetails['totalCost']??0) + (coinDetails['totalProceedings']??0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor,size: 35,),
            onPressed: () {
            Navigator.pop(context);
              },
          ),
        title: Row(
          children: [
            Image.network(coinDetails['coinIcon'],height: 30,),
            const SizedBox(width: 8,),
            Text(
              '${coinDetails['coinName']} (${coinDetails['coinCode']})',
              style: const TextStyle(fontSize: 25, color: kTextColor),
            ),
          ],
        ),
        ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15,right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              // offset: Offset(-3.0,3.0),
              blurRadius: 20.0,
              spreadRadius: 4.0,
              )],
            ),
            child: Stack(children: [
              Positioned(
                child:Card(
                  color: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("images/Balance card.png"),
                      ),
                    ),
                  ),
                ),
            ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text('HOLDINGS VALUE',style: kInputTitleTextStyle.copyWith(fontSize: 14)),
                          Text(
                           NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(holdingValue),
                           style: const TextStyle(fontSize: 16),
                          ),],
                        ),
                       const SizedBox(width: 100,),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [Text('HOLDINGS',style: kInputTitleTextStyle.copyWith(fontSize: 14)),
                           Text(
                             '${coinDetails['totalQuantity']} ${coinDetails['coinCode']}',
                             style: const TextStyle(fontSize: 16),
                           ),],
                       ),
                     ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text('TOTAL COST',style: kInputTitleTextStyle.copyWith(fontSize: 14)),
                          Text(
                          NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(coinDetails['totalCost']),
                            style: const TextStyle(fontSize: 16),
                          ),],
                      ),
                        const SizedBox(width: 130,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text('AVERAGE NET COST',style: kInputTitleTextStyle.copyWith(fontSize: 14)),
                            Text(
                            NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(coinDetails['averageNetCost']??0),
                              style: const TextStyle(fontSize: 16),
                            ),],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('PROFIT/LOSS',style: kInputTitleTextStyle.copyWith(fontSize: 14)),
                        profitLoss < 0 ? Text(
                          NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(profitLoss??0),
                          style: const TextStyle(fontSize: 16,color: Colors.red,fontWeight: FontWeight.bold),
                        ):
                        Text(
                          NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(profitLoss??0),
                          style: const TextStyle(fontSize: 16,color: Colors.green,fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ]),
          ),
            const SizedBox(height: 20,),
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 20, color: kTextColor),
            ),
            TransactionsStream(portfolioId:portfolioId,coinCode:coinDetails['coinCode']),
          ],
        ),
      ),
    );
  }
}
class TransactionsStream extends StatelessWidget {
  TransactionsStream({ required this.portfolioId, required this.coinCode});
  final String portfolioId;
  final String coinCode;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('CoinTransactions')
          .where('portfolioID',isEqualTo: portfolioId).where('coin',isEqualTo: coinCode)
          .orderBy('timeStamp',descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
              backgroundColor: kPrimaryColor,
            ),
          );
        }
        final transactions = snapshot.data?.docs;
        List<TransactionRow> transactionsList = [];
        for (var transaction in transactions!) {
          final transactionType = transaction['transactionType'];
          final transactionQuantity = transaction['quantity'];
          final transactionCoin = transaction['coin'];
          final transactionCost = transaction['cost'];
          final transactionDate = transaction['date'];
          final time = transaction['timeStamp'].toDate().toString().characters.take(19).string;
          final transactionRow = TransactionRow(
            type: transactionType,
            quantity: transactionQuantity,
            coin: transactionCoin,
            cost: transactionCost,
            date: transactionDate,
            dateTime: time,
          );

          transactionsList.add(transactionRow);
        }
        return Expanded(
          child: snapshot.data?.docs.length == 0?
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text('No transactions are available!',style: TextStyle(fontSize: 18, color: kTextColor)),
          ):
          ListView(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            children: transactionsList,
          ),
        );
      },
    );
  }
}

class TransactionRow extends StatelessWidget {
  TransactionRow({ required this.type, required this.quantity, required this.coin, required this.cost, required this.date,required this.dateTime});

  final String type;
  final String coin;
  final double quantity;
  final double cost;
  final String date;
  final String dateTime;
  // final date = dateTime.toDate().toString().characters.take(19);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            leading: type.toLowerCase() == 'sell'?
            const Icon(Icons.arrow_back,color: Colors.red,):
            const Icon(Icons.arrow_forward,color: Colors.green,),
          title: Text(type,style: const TextStyle(fontSize: 16.0,color: Colors.white,),
            textAlign: TextAlign.start,
          ),
          subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(date)),style: const TextStyle(fontSize: 16.0,color: Colors.white,),
          ),
          trailing: Column(
            children: [
              Text('$quantity $coin',
                style: const TextStyle(fontSize: 16.0,color: Colors.white,),
              ),
              type.toLowerCase() == 'sell'?
              Text('Received: ${NumberFormat.compactSimpleCurrency(locale: 'en-US',decimalDigits: 2).format(cost)}',style: const TextStyle(fontSize: 16.0,color: Colors.white,)):
              Text('Paid: ${NumberFormat.compactSimpleCurrency(locale: 'en-US',decimalDigits: 2).format(cost)}',style: const TextStyle(fontSize: 16.0,color: Colors.white,)
              ),
            ],
          )
        ),
        const Divider(color: kTextColor2,thickness: 1,),
      ],
    );
  }
}

