import 'package:crypto_portfolio_app/screens/portfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  String firstName = '';
  String lastName = '';
  bool showSpinner = false;

  //This method is used to create the user in firestore
  Future<void> createUser(String uid, String firstname, String lastname, String email) async {
    //Creates the user doc named whatever the user uid is in te collection "users"
    //and adds the user data
    await _firestore.collection("UserDetails").doc(uid).set({
      'FirstName': firstname ,
      'LastName' : lastname ,
      'Email': email,
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        color: kPrimaryColor,
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 48.0,
                ),
                const Text('Create your account',style: kTitleTextStyle),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  children: [Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('First name',style: kInputTitleTextStyle,),
                        TextField (
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.center,
                        cursorColor: kPrimaryColor,
                        onChanged: (value) {
                          firstName = value;
                        },
                        decoration: kTextFieldDecoration,
                      ),
                      ],
                    ),
                  ),
                SizedBox(width: 8.0,),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last name',style: kInputTitleTextStyle),
                      TextField(
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.center,
                      cursorColor: kPrimaryColor,
                      onChanged: (value) {
                        lastName = value;
                      },
                      decoration: kTextFieldDecoration,
                    ),
                  ],
                  ),
                ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                const Text('Email address',style: kInputTitleTextStyle,),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  cursorColor: kPrimaryColor,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration,
                ),
                Text('Your email address will be used as your username to login to the crypto portfolio',
                  style: kInputTitleTextStyle.copyWith(fontWeight: FontWeight.normal,fontSize: 12),),
                SizedBox(
                  height: 15.0,
                ),
                const Text('Password',style: kInputTitleTextStyle,),
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
                Container(
                  alignment: Alignment.centerRight,
                  child: RoundedButton( onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      if(newUser != null){
                        createUser(newUser.user!.uid, firstName, lastName, email);
                        Navigator.pushNamed(context, PortfolioScreen.id);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    }
                    catch(e){
                      print(e);
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  },
                      title: 'Register'),
                ),
              ],
            )],
          ),
        ),
      ),
    );
  }
}

