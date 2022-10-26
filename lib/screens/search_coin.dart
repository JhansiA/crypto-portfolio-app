import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:favorite_button/favorite_button.dart';
import 'portfolio_screen.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'package:crypto_portfolio_app/services/database.dart';
import 'package:crypto_portfolio_app/services/cryptoAPI.dart';

class SearchCoin extends StatefulWidget {
  static const String id = 'search_coin_screen';
  SearchCoin({this.portfolioData});
  final portfolioData;

  @override
  SearchCoinState createState() => SearchCoinState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      const Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class SearchCoinState extends State<SearchCoin> {
  final _debouncer = Debouncer();
  List<CoinData> allCoinList = [];
  List<CoinData> userCoinLists = [];
  List<String> coinList = [];

  @override
  void initState() {
    super.initState();
    CryptoApi().getAllCoinList().then((subjectFromServer) {
      setState(() {
        allCoinList = subjectFromServer;
      });
    });
  }
  Future<void> getCoinData(id) async {
    //To get crypto coin details available for portfolio
    if(id != null) {
      var data = await Database.getPortfolioCoinInfo(id);
      setState(() {
        coinList = data.keys.toList();
      });
    }
  }
  //Main Widget
  @override
  Widget build(BuildContext context) {
    final routeData =
    ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    final portfolioData = routeData.entries.elementAt(0).key;

    getCoinData(portfolioData);
    Map<String,bool> isChecked = {for (var item in coinList) item : true};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor,size: 35,),
          onPressed: () {
            Navigator.pushNamed(context, PortfolioScreen.id);
          },
        ),
        title: const Text(
          'Search',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Column(
        children: <Widget>[
          //Search Bar to List of typed Subject
          Container(
            padding: const EdgeInsets.all(15),
            child: TextField(
              cursorColor: kPrimaryColor,
              textInputAction: TextInputAction.search,
              decoration: kTextFieldDecoration.copyWith(prefixIcon:
              const InkWell(focusColor: kPrimaryColor,child: Icon(Icons.search,color: kPrimaryColor,),),
                hintText: 'Search for a coin',),
              onChanged: (value) {
                _debouncer.run(() {
                  setState(() {
                    value.isNotEmpty? userCoinLists = allCoinList
                        .where(
                          (u) => (u.coinName.toLowerCase().contains(
                            value.toLowerCase(),
                      )),
                    ).toList(): userCoinLists = [];
                  });
                });
              },
            ),
          ),
          userCoinLists.isNotEmpty? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 0),
              itemCount: userCoinLists.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      leading: Image.network(userCoinLists[index].coinIcon,height: 40,),
                      title: Text(
                        userCoinLists[index].coinName,
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        userCoinLists[index].coinCode,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: StarButton(
                        isStarred: isChecked.containsKey(userCoinLists[index].coinID)? true:
                        false,
                        iconSize: 40,
                        iconColor: kPrimaryColor,
                        valueChanged: (onChanged) {
                          // true: add coin info with portfolio id
                          onChanged? {
                          setState(() {
                            Database.setCryptoList(portfolioData, userCoinLists[index]);
                          })
                          } : //false: delete coin info for that portfolio id
                          {showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text('Remove Coin',style: kTitleTextStyle.copyWith(fontSize: 24),textAlign: TextAlign.center,),
                              content: const Text('Are you sure you want to remove this coin? Any transactions associated with this coin will also be removed',
                                style: kCardTextStyle,),
                              actions: <Widget>[
                                RoundedButton(
                                  onPressed: () {
                                    //TODO: restore checkbox status after pressing cancel
                                    Navigator.pop(context, 'Cancel');
                                    },
                                  title: 'Cancel',
                                ),
                                RoundedButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'OK');
                                    setState(() {
                                      Database.deleteCryptoCoin(portfolioData, userCoinLists[index].coinID);
                                    });
                                    },
                                  title: 'Ok',
                                ),
                              ],
                            ),
                          )
                        };
                        }
                      ),
                    ),
                    const Divider(color: kTextColor2,thickness: 1.0,),
                  ],
                );
              },
            ),
          ):
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
