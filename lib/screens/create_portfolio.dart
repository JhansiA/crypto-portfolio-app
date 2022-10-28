import 'package:crypto_portfolio_app/screens/search_coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto_portfolio_app/components/add_portfolio.dart';
import 'package:crypto_portfolio_app/services/database.dart';

late User loggedInUser;

class CreatePortfolio extends StatefulWidget {
  @override
  State<CreatePortfolio> createState() => _CreatePortfolioState();
}

class _CreatePortfolioState extends State<CreatePortfolio> {
  late String portfolioName;
  Map<String,String> portfoliodata = {};
  Map<String,dynamic> coinDetails = {};

  final _text = TextEditingController();

  bool _validate = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loggedInUser = Database().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: SvgPicture.asset("images/crypto_portfolio.svg"),),

          Padding(padding: const EdgeInsets.only(top: 50),
            child: Container(
                alignment: Alignment.center,
                child: RoundedButton(title: '   Create portfolio   ', onPressed: (){
                  showModalBottomSheet(
                    backgroundColor: kBackgroundColor,
                      context: context,
                      isDismissible: false,
                      isScrollControlled: true,
                      builder: (context) => SafeArea(
                        child: Container(
                          child: newPortfolio(),
                        ),
                      )
                  );
                })),
          ),
        ],
      ),
    );
  }

  Widget newPortfolio() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Portfolio Name',style: kInputTitleTextStyle,),
              TextField(
                controller: _text,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                cursorColor: kPrimaryColor,
                onChanged: (value) {
                  portfolioName = value;
                },
                decoration: kTextFieldDecoration,
              ),
              _validate? Text('* Enter portfolio name',
                style: kInputTitleTextStyle.copyWith(fontWeight: FontWeight.normal,color: Colors.redAccent),
              ) :SizedBox(height: defaultPadding*2,),
              AddPortfolio(onPressed: () async {
                setState(() {
                  if(_text.text.isEmpty) {
                    _validate = _text.text.isEmpty;
                  }
                });
                //TODO: check logic if already name exists in DB for this user
                Database.createPortfolio(loggedInUser.uid, portfolioName);
                portfoliodata = await Database.getPortfolioInfo(loggedInUser.uid);
                Navigator.pushNamed(context, SearchCoin.id, arguments: portfoliodata);
              })
            ],
          ),
        );
      }
    );
  }
}
