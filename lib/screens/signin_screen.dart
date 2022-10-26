import 'package:crypto_portfolio_app/screens/portfolio_screen.dart';
import 'package:crypto_portfolio_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SigninScreen extends StatefulWidget {

  static const String id = 'signin_screen';

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          color: kPrimaryColor,
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 48.0,
                  ),
                  const Text('Sign in',style: kTitleTextStyle),
                  const SizedBox(
                    height: 30.0,
                  ),
                  const Text('Email address / Username',style: kInputTitleTextStyle),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    cursorColor: kPrimaryColor,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: kTextFieldDecoration ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Text('Password',style: kInputTitleTextStyle),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    cursorColor: kPrimaryColor,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: kTextFieldDecoration,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  //TODO: add logic
                  Text('Forgot your password?',style: kInputTitleTextStyle.copyWith(color: kPrimaryColor,decoration: TextDecoration.underline),
                  ),

                  Container(
                    alignment: Alignment.centerRight,
                    child: RoundedButton( title: 'Sign in',
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          try{
                            final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                            if(user != null){
                              Navigator.pushNamed(context, PortfolioScreen.id);
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          }
                          catch(e){
                            setState(() {
                              showSpinner = false;
                            });
                            print(e);}
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                child: Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [Text('Don'"'"'t have an account?' ,style: kInputTitleTextStyle.copyWith(color: kTextColor,fontWeight: FontWeight.normal), ),
                  TextButton(onPressed: (){
                    Navigator.pushNamed(context, SignupScreen.id);
                  },
                    child: Text('Create here', style: kInputTitleTextStyle.copyWith(color: kPrimaryColor,decoration: TextDecoration.underline)),)]),

              ),
            ),
    ),
    );
  }
}
