import 'package:crypto_portfolio_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:intl/intl.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';

class AddTransaction extends StatefulWidget {
  static const String id = 'transaction_screen';

  AddTransaction({Key? key}) : super(key: key);
  // AddTransaction({this.coinCode});
  // final coinCode;

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController dateInput = TextEditingController();
  TextEditingController totalEditingController = TextEditingController();
  TextEditingController quantityEditingController = TextEditingController();
  TextEditingController finalValue = TextEditingController();

  bool showFab = true;
  double? value;
  double? quantity;
  double? coinPrice;

  DateTime? date;
  String? finalprice ;


  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 0, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
    totalEditingController.addListener(() => setState(() {
      totalCalculated();
    }));
    quantityEditingController.addListener(() => setState(() {
      totalCalculated();
    }));
    finalValue.addListener(() => setState(() {
      // totalCalculated();
    }));
  }
  @override
  void dispose() {
    _tabController.dispose();
    dateInput.dispose();
    totalEditingController.dispose();
    quantityEditingController.dispose();
    finalValue.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)?.settings.arguments as List<dynamic>;
    final coinCode = data[0];
    final portfolioId = data[1];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor,size: 35,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontSize: 25),textAlign: TextAlign.center,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          tabs: const <Widget>[
            Tab(text: "Buy"),
            Tab(
              text: "Sell",
            ),
            Tab(
              text: "Transfer",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          textForm('Total Spent', coinCode,portfolioId),
          textForm('Total Received', coinCode,portfolioId),
          textForm('Transfer', coinCode,portfolioId),
        ],
      ),
    );
  }

  Widget textForm(String textLabel,String coinCode, String portfolioId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 20.0,
            ),
            Text(textLabel,style: kInputTitleTextStyle),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              controller: totalEditingController,
              cursorColor: kPrimaryColor,
              onChanged: (text) {
               value = (text.isNotEmpty && text !='.') ? double.parse(text): 0;
              },
              decoration: kTextFieldDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: const Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text('USD',style: kCardTextStyle,),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text('Quantity',style: kInputTitleTextStyle),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              controller: quantityEditingController,
              cursorColor: kPrimaryColor,
              onChanged: (text) {
               quantity = (text.isNotEmpty && text !='.') ? double.parse(text): 0;
                // print(quantity);
              },
              decoration: kTextFieldDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text(coinCode,style: kCardTextStyle,),
                ),
              ), ),
            const SizedBox(
              height: 20.0,
            ),
            const Text('Price Per Coin',style: kInputTitleTextStyle),
            TextField(
              readOnly: true,
              textAlign: TextAlign.start,
              controller: finalValue,
              decoration:
              kTextFieldDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: const Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text('USD',style: kCardTextStyle,),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text('Date',style: kInputTitleTextStyle),
            TextField(
              cursorColor: kPrimaryColor,
              controller: dateInput..text= DateFormat('yyyy-MM-dd').format(DateTime.now()),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2101)
                );

                if(pickedDate != null ){
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  //you can implement different kind of Date Format here according to your requirement

                  // setState(() {
                  dateInput.text = formattedDate; //set output date to TextField value.
                  // });
                }
                else{
                  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  dateInput.text = formattedDate;
                }
                // print(dateInput.text );
              },
              decoration: kTextFieldDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: const Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Icon(Icons.calendar_month),
                ),
              ), ),
            const SizedBox(
              height: 40.0,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [RoundedButton( title: 'Cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  }),
                RoundedButton( title: 'Submit',
                    onPressed: () {
                      //TODO: logic to save
                      double coinPrice = (finalValue.text.isNotEmpty && finalValue.text !='.') ? double.parse(finalValue.text): 0;
                      String? type = coinType();
                      print(quantity);
                      print(value);
                      print(dateInput.text );
                      Database.addTransactions(portfolioId, coinCode, coinPrice, quantity!, value!, type!, dateInput.text);
                      Database.updateCryptoCoin(portfolioId, coinCode, coinPrice, quantity!, value!, type);
                      totalEditingController.clear();
                      quantityEditingController.clear();
                      finalValue.clear();
                      dateInput.clear();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? totalCalculated() {
    String? textValue;
    String? textQuantity;

    textValue = totalEditingController.text;
    textQuantity = quantityEditingController.text;

    if ((textValue != '' && textQuantity != '') && (textQuantity != '0' && textQuantity != '.') && (textValue != '0' && textValue != '.') ){
      finalprice = (double.parse(textValue) / double.parse(textQuantity)).toStringAsFixed(3);
      finalValue.value = finalValue.value.copyWith(
        text: finalprice.toString(),
      );
    }
    else{
      finalprice = '0';
      finalValue.value = finalValue.value.copyWith(
        text: finalprice.toString(),
      );
    }
    return finalprice;
  }
  String? coinType()
  {
    String? type ;
    if(_tabController.index==0){
      type = 'buy';
    }else if(_tabController.index==1){
      type = 'sell';
    }else if(_tabController.index==3){
      type = 'transfer';
    }
    return type ;
  }
}
