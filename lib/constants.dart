import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFA259FF);
const kBackgroundColor = Color(0xFF202124);
const kTextColor = Color(0xFFD9D9D9);
const kTextColor2 = Color(0xFF989898);
const kTextColorTitle = Color(0xFF8DEF91);

const double defaultPadding = 16.0;

const kTitleTextStyle = TextStyle(
  color: kTextColor, fontSize: 32,fontWeight: FontWeight.bold,
);

const kCardTextStyle = TextStyle(
  color: kTextColor, fontSize: 16,fontWeight: FontWeight.normal,
);

const kInputTitleTextStyle = TextStyle(
  color: kTextColor2, fontSize: 16,fontWeight: FontWeight.bold,
);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kTextColor2, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kTextColor2, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);