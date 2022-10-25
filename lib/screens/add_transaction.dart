import 'package:flutter/material.dart';
import 'package:crypto_portfolio_app/constants.dart';
import 'package:intl/intl.dart';
import 'package:crypto_portfolio_app/components/rounded_button.dart';

class AddTransaction extends StatefulWidget {
  static const String id = 'transaction_screen';
  AddTransaction({this.coinCode});
  final coinCode;

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController dateinput = TextEditingController();

  bool showFab = true;
  double? value;
  double? quantity;
  DateTime? date;


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
  }
  @override
  void dispose() {
    _tabController.dispose();
    dateinput.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final coinCode =
    ModalRoute.of(context)?.settings.arguments as String;

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
          textForm('Total Spent', coinCode),
          textForm('Total Received', coinCode),
          textForm('Transfer', coinCode),
        ],
      ),
    );
  }

  Widget textForm(String textlable,String coincode) {
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
            Text(textlable,style: kInputTitleTextStyle),
            TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              cursorColor: kPrimaryColor,
              onChanged: (text) {
                value = double.parse(text);
                print(value);
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
              cursorColor: kPrimaryColor,
              onChanged: (text) {
                quantity = double.parse(text);
                print(quantity);
              },
              decoration: kTextFieldDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: Align(
                  alignment: Alignment.center,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text(coincode,style: kCardTextStyle,),
                ),
              ), ),
            const SizedBox(
              height: 20.0,
            ),
            const Text('Date',style: kInputTitleTextStyle),
            TextField(
              cursorColor: kPrimaryColor,
              controller: dateinput,
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
                  dateinput.text = formattedDate; //set output date to TextField value.
                  // });
                }
                else{
                  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  dateinput.text = formattedDate;
                }
                print(dateinput.text );
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
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
