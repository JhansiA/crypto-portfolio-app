import 'package:crypto_portfolio_app/screens/search_coin.dart';
import 'package:crypto_portfolio_app/screens/signin_screen.dart';
import 'package:crypto_portfolio_app/screens/transaction_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:crypto_portfolio_app/screens/create_portfolio.dart';
import 'package:crypto_portfolio_app/services/database.dart';
import 'package:crypto_portfolio_app/services/cryptoAPI.dart';
import 'package:crypto_portfolio_app/components/add_portfolio.dart';
import 'package:crypto_portfolio_app/screens/add_transaction.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'package:intl/intl.dart';

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
  Map<String,double> price = {};
  double? totalBalance ;
  double? totalProfitLoss ;
  bool showSpinner = false;
  final _text = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loggedInUser = Database().getCurrentUser();
    getProfileDetails();
  }
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }
  void getProfileDetails() async{
    setState(() {
      showSpinner = true;
    });
    await getPortfolio(loggedInUser.uid);
    await getCoinData(portfolioID);
    await getData(coinDetails.keys.toList());
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> getPortfolio(id) async {
    //To get portfolio details
    var result = await Database.getPortfolioInfo(id);
    if(result.isNotEmpty) {
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

  List<double?> calculateBalance(){
    double? balance;
    double? pl;
    if(coinDetails.isNotEmpty && price.isNotEmpty){
      for(var coin in coinDetails.keys){
        double holdings = ((price[coin]??0) * coinDetails[coin]['totalQuantity']);
        balance = (balance ??0) + holdings;
        pl = (pl??0) + holdings - coinDetails[coin]['totalCost']+coinDetails[coin]['totalProceedings'];
      }
    }
    return [balance,pl];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
        color: kBackgroundColor,
        progressIndicator: CircularProgressIndicator(color: kPrimaryColor,),
        inAsyncCall: showSpinner,
        child:
            showSpinner== false?
            portfolioData.isEmpty? CreatePortfolio() : loadPortfolio():
            Container(),
      ),
      ),
    );
  }

  Widget loadPortfolio(){
    List<double?> portfolioValue = calculateBalance();
    return Padding(
      padding: const EdgeInsets.only(left: 5,right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: IconButton(
              icon: const Icon(Icons.logout_outlined, color: kPrimaryColor,size: 30,),
              onPressed: () {
                _auth.signOut();
                // Navigator.pushNamed(context, SigninScreen.id);
                Navigator.pushNamedAndRemoveUntil(context, SigninScreen.id, (route) => false);
              },
            ),
            title: Text(
              portfolioName.toString(),
              style: kTitleTextStyle,
              textAlign: TextAlign.center,
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
                  Text(NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(portfolioValue[0]??0),
                    style: kCardTextStyle.copyWith(fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  ListTile(
                    title: const Text(
                      'Total Profit/Loss',
                      style: kCardTextStyle,
                    ),
                    trailing: (portfolioValue[1]??0) >= 0? Text(NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(portfolioValue[1]??0),
                        style: TextStyle(color: Colors.green, fontSize: 20,fontWeight: FontWeight.bold,
                    )):
                    Text(NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 2).format(portfolioValue[1]??0),
                      style: TextStyle(color: Colors.red, fontSize: 20,fontWeight: FontWeight.bold,)
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: coinDetails.isNotEmpty?
              _displayCryptoTable():
                Padding(
                  padding: const EdgeInsets.only(top: defaultPadding),
                  child: AddPortfolio(onPressed: () async {
                    Navigator.pushNamed(context, SearchCoin.id, arguments: portfolioData);
                  }),
                )
            ),
          ),
        ],
      ),
    );
  }
  Widget _displayCryptoTable(){
    List<String> columnList = ['COIN','PRICE','HOLDINGS',''];
    return DataTable(
      showCheckboxColumn: false,
      //TODO: Sorting
      // sortColumnIndex: 1,
      // sortAscending: true,
      columnSpacing: 40,
      dataRowHeight: 60,
        columns: columnList.map((String column) => DataColumn(
          label: Expanded(
            child: Text(
              column,
              style: kTitleTextStyle.copyWith(fontSize: 16),
            ),
          ),
        ),
        ).toList(),
        rows: coinDetails.entries.map((element) => _createRows(element.value,price[element.key]?? 0)).toList()
    );
  }

  DataRow _createRows(Map<String,dynamic> coindetails, double coinprice ) {
    double holdings = (coinprice * coindetails['totalQuantity']);
    // totalBalance = (totalBalance??0) + holdings ;
    // print(totalBalance); //TODO: check with sri how to update
    return
      DataRow(
          onSelectChanged: (newValue){
            Navigator.pushNamed(context, CoinTransactions.id, arguments: [portfolioID,coindetails,holdings]);
          },
          cells: [
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(coindetails['coinIcon'],height: 30,),
            Text(
              coindetails['coinCode'],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        )),
        DataCell(Container(
          alignment: Alignment.centerLeft,
          child: Text(
            NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 4).format(coinprice),
            style: const TextStyle(fontSize: 16),
          ),
        )),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              NumberFormat.simpleCurrency(locale: 'en-US',decimalDigits: 3).format(holdings),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
                '${coindetails['totalQuantity']} ${coindetails['coinCode']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        )),
        DataCell(IconButton(
          icon: const Icon(Icons.add, color: kPrimaryColor,size: 20,),
          onPressed: () {
            Navigator.pushNamed(context, AddTransaction.id, arguments: [coindetails['coinCode'],portfolioID]);
          },
        ))
      ]);
  }

  Widget _showDialog(){
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
                    showModalBottomSheet(
                      backgroundColor: kBackgroundColor,
                        context: context,
                        isDismissible: false,
                        isScrollControlled: true,
                        builder: (context) => SafeArea(
                          child: Container(
                            child: renameProfile(),
                          ),
                        )
                    );
                  }, child: const Text('Rename',style: kInputTitleTextStyle,))
                ],
              ),
              const Divider(color: kTextColor2,thickness: 0.5,),
              SizedBox(
                width: 320.0,
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: kPrimaryColor,size: 20),
                    TextButton(onPressed: (){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: kBackgroundColor,
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
                        child: const Text('Delete this Portfolio',style: kInputTitleTextStyle,))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget renameProfile(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kPrimaryColor,size: 30,),
                  onPressed: () {
                      Navigator.pop(context);
                    },
              ),
              title:Text('Edit Portfolio Name',style: kTitleTextStyle.copyWith(fontSize: 24),)),
          const SizedBox(height: 10,),
          const Text('Portfolio Name',style: kInputTitleTextStyle,),
          TextField(
            textAlign: TextAlign.center,
            cursorColor: kPrimaryColor,
            controller: _text,
            onChanged: (text) {
            },
            decoration: kTextFieldDecoration,
          ),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: RoundedButton(
                onPressed: () {
                  // print(_text.text);
                  Database.updatePortfolio(portfolioID!, _text.text);
                  _text.clear();
                  Navigator.popAndPushNamed(context, PortfolioScreen.id);
                },
                title: 'Update Portfolio',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
