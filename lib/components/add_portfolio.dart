import 'package:crypto_portfolio_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';

class AddPortfolio extends StatelessWidget {
  AddPortfolio({required this.onPressed});

  // final Color colour;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      SizedBox(
      height: 200,
      width: 200,
      child: SvgPicture.asset("images/add_coin.svg"),),
      SizedBox(height: defaultPadding*2,),
      Text('Add a new coin to get started!',
        style: kTitleTextStyle.copyWith(fontWeight: FontWeight.normal,fontSize: 24),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: defaultPadding*2,),
      Container(
        alignment: Alignment.center,
        child: RoundedButton(title: 'Add to portfolio', onPressed: onPressed),
      ),
      ],
    );
  }
}