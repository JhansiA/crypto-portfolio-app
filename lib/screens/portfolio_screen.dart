import 'package:crypto_portfolio_app/screens/search_coin.dart';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:crypto_portfolio_app/screens/create_portfolio.dart';
import 'package:crypto_portfolio_app/services/database.dart';
import 'package:crypto_portfolio_app/services/cryptoAPI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_portfolio_app/components/add_portfolio.dart';
import 'package:crypto_portfolio_app/screens/add_transaction.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';

final _firestore = FirebaseFirestore.instance;
// String? portfolioName;
// String? portfolioID;
// Map<String,String> portfolioData = {};

class PortfolioScreen extends StatefulWidget {
  static const String id = 'portfolio_screen';
  const PortfolioScreen({Key? key}) : super(key: key);


  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();

}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String? portfolioName;
  String? portfolioID;
  Map<String,String> portfolioData = {};
  Map<String,dynamic> coinDetails = {};
  Map<String,String> price = {};
  // bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    loggedInUser = Database().getCurrentUser();
    getProfileDetails();
  }

  void getProfileDetails() async{
    // setState(() {
    //   showSpinner = true;
    // });
    await getPortfolio(loggedInUser.uid);
    await getCoinData(portfolioID);
    await getData(coinDetails.keys.toList());
    // setState(() {
    //   showSpinner = false;
    // });
  }

  Future<void> getPortfolio(id) async {
    //To get portfolio details
    var result = await Database.getPortfolioInfo(id);
    if(result.length != 0) {
      setState(() {
        portfolioData = result;
        portfolioName = result.entries
            .elementAt(0)
            .value;
        portfolioID = result.entries
            .elementAt(0)
            .key;
      });
    }
  }

  Future<void> getCoinData(id) async {
    //To get crypto coin details available for portfolio
    if(id != null) {
      var data = await Database.getPortfolioCoinInfo(id);
      setState(() {
        coinDetails = data;
      });
    }
  }

  Future<void> getData(coin) async {
    //API call to get latest price for crypto coins
    if(coin.length != 0) {
      var data = await CryptoApi().getCoinData(coin);
      setState(() {
        price = data;
        // showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: portfolioData.isEmpty? CreatePortfolio() :
              TopFixedWidget(),
      ),
    );
  }

  Widget TopFixedWidget(){
    return Padding(
      padding: const EdgeInsets.only(left: 5,right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text(
              portfolioName.toString(),
              style: kTitleTextStyle,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: kPrimaryColor,size: 30,),
              onPressed: () {
                Navigator.pushNamed(context, SearchCoin.id, arguments: portfolioData);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Card(
              color: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: const Text(
                      'Your balance (USD)',
                      style: kCardTextStyle,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: kTextColor,size: 25,),
                      onPressed: () {
                        showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _showDialog();
                        });
                      }
                    ),
                  ),
                  Text('200000.99',style: kCardTextStyle.copyWith(fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ListTile(
                    title: Text(
                      'Total Profit/Loss',
                      style: kCardTextStyle,
                    ),
                    trailing: Text('1555.99',style: kCardTextStyle),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: coinDetails.isNotEmpty?
              _displayCryptoTable():
                AddPortfolio(onPressed: () async {
                  Navigator.pushNamed(context, SearchCoin.id, arguments: portfolioData);
                })
            ),
          ),
        ],
      ),
    );
  }
  Widget _displayCryptoTable(){
    return DataTable(
      //TODO: Sorting
      // sortColumnIndex: 1,
      // sortAscending: true,
      columnSpacing: 40,
      dataRowHeight: 60,
        columns: <DataColumn>[
      DataColumn(
        label: Expanded(
          child: Text(
            'COIN',
            style: kTitleTextStyle.copyWith(fontSize: 16),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'PRICE',
            style: kTitleTextStyle.copyWith(fontSize: 16),
          ),
        ),
        numeric: true,
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'HOLDINGS',
            style: kTitleTextStyle.copyWith(fontSize: 16),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            '',
            style: kTitleTextStyle.copyWith(fontSize: 16),
          ),
        ),
      ),
    ],
        rows: coinDetails.entries.map((element) => _createRows(element.value,price[element.key]??'0')).toList()
    );
  }
  DataRow _createRows(Map<String,dynamic> coindetails, String coinprice ) {
    return
      DataRow(cells: [
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(coindetails['coinIcon'],height: 30,),
            Text(
              coindetails['CoinCode'],
              style: TextStyle(fontSize: 12),
            ),
          ],
        )),
        DataCell(Text(
          '\$$coinprice',
          style: TextStyle(fontSize: 16),
        )),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '\$$coinprice',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              coindetails['CoinCode'],
              style: TextStyle(fontSize: 14),
            ),
          ],
        )),
        DataCell(IconButton(
          icon: const Icon(Icons.add, color: kPrimaryColor,size: 20,),
          onPressed: () {
            Navigator.pushNamed(context, AddTransaction.id, arguments: coindetails['CoinCode']);
          },
        ))
      ]);
  }

  Widget _showDialog(){
    var newTitle;
    return Dialog(
      alignment: Alignment.bottomCenter,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20.0)),
      child: Container(
        color: kBackgroundColor,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, color: kPrimaryColor,size: 20),
                  TextButton(onPressed: (){
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        actionsAlignment: MainAxisAlignment.center,
                        insetPadding: EdgeInsets.symmetric(vertical: 200),
                        title: Text('Edit Portfolio',style: kTitleTextStyle.copyWith(fontSize: 24),textAlign: TextAlign.center,),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Portfolio Name',style: kInputTitleTextStyle,),
                            TextField(
                              textAlign: TextAlign.center,
                              cursorColor: kPrimaryColor,
                              controller: TextEditingController()..text = portfolioName!,
                              onChanged: (text) {
                                newTitle = text;
                              },
                              decoration: kTextFieldDecoration,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          RoundedButton(
                            onPressed: () {
                                Database.updatePortfolio(portfolioID!, newTitle);
                                Navigator.popAndPushNamed(context, PortfolioScreen.id);
                            },
                            title: 'Update Portfolio',
                          ),
                        ],
                      ),
                    );
                  }, child: Text('Rename',style: kInputTitleTextStyle,))
                ],
              ),
              Divider(color: kTextColor2,thickness: 0.5,),
              SizedBox(
                width: 320.0,
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: kPrimaryColor,size: 20),
                    TextButton(onPressed: (){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          // title: Text('Remove Coin',style: kTitleTextStyle.copyWith(fontSize: 24),textAlign: TextAlign.center,),
                          content: Text('Are you sure you want to delete "$portfolioName" ?',
                            style: kCardTextStyle,),
                          actions: <Widget>[
                            RoundedButton(
                              onPressed: () {
                                Navigator.pop(context, 'Cancel');
                              },
                              title: 'Cancel',
                            ),
                            RoundedButton(
                              onPressed: () {
                                  Database.deletePortfolio(portfolioID!);
                                  Navigator.popAndPushNamed(context, PortfolioScreen.id);
                              },
                              title: 'Ok',
                            ),
                          ],
                        ),
                      );
                      },
                        child: Text('Delete this Portfolio',style: kInputTitleTextStyle,))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
