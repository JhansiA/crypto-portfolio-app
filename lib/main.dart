import 'package:crypto_portfolio_app/screens/transaction_history.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/portfolio_screen.dart';
import 'screens/search_coin.dart';
import 'screens/add_transaction.dart';
import 'constants.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CryptoPortfolio());
}

class CryptoPortfolio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      initialRoute : WelcomeScreen.id,
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        WelcomeScreen.id : (context) => WelcomeScreen(),
        SigninScreen.id: (context) => SigninScreen(),
        SignupScreen.id: (context) => SignupScreen(),
        PortfolioScreen.id: (context) => PortfolioScreen(),
        SearchCoin.id: (context) => SearchCoin(),
        AddTransaction.id: (context) => AddTransaction(),
        CoinTransactions.id: (context) => CoinTransactions(),
      },
    );
  }
}
