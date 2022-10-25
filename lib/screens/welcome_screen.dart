import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding,vertical: 200),
        child: Column(
            children: [const Text('Welcome to',style: TextStyle(
              color: kTextColor, fontSize: 32,fontWeight: FontWeight.bold,
            ),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text('Crypto',style: TextStyle(
                color: kTextColorTitle, fontSize: 32,fontWeight: FontWeight.bold,
              )),
                Text('Portfolio',style: TextStyle(
                  color: kPrimaryColor, fontSize: 32,fontWeight: FontWeight.bold,
                )),
            ],
        ),
              const SizedBox(height: 30,),
              RoundedButton(title: 'Sign in', onPressed: (){
                Navigator.pushNamed(context, SigninScreen.id);
              }),
              RoundedButton(title: 'Sign up', onPressed: (){
                Navigator.pushNamed(context, SignupScreen.id);
              }),
          ],
      ),
      ),
    );
  }
}
