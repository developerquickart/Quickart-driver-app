import 'package:driver/Pages/home_page.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';

class CancelledOrderPage extends StatefulWidget {
  final OrderHistory? orderDetaials;
  final dynamic distance;
  final dynamic time;
  const CancelledOrderPage(
      {super.key, this.orderDetaials, this.distance, this.time});

  @override
  _CancelledOrderPageState createState() =>
      _CancelledOrderPageState(this.orderDetaials, this.distance, this.time);
}

class _CancelledOrderPageState extends State<CancelledOrderPage> {
  OrderHistory? orderDetaials;
  dynamic distance;
  dynamic time;
  _CancelledOrderPageState(this.orderDetaials, this.distance, this.time)
      : super();
  @override
  void initState() {
    super.initState();
    distance = widget.distance;
    time = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    setState(() {});

    return PopScope(
        onPopInvoked: (didPop) async {
          await Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => HomePage()),
              (route) => false);
        },
        child: SafeArea(
          child: Scaffold(
              body: Column(
            children: [
              Spacer(
                flex: 1,
              ),
              Image.asset(
                'assets/orderCancelled.png',
                scale: 3,
              ),
              SizedBox(
                height: 20,
              ),
              Text("Order Cancelled",
                  style: TextStyle(fontSize: 30, color: kRedColor)),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: locale!.viewOrderInfo,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Poppins'),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                                context, PageRoutes.orderHistoryPage,
                                arguments: {
                                  'OrderDetail': orderDetaials,
                                });
                          },
                      ),
                    ])),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPurpleLight),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) => HomePage()),
                            (route) => false);
                      },
                      child: Text(
                        "Back To Home",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: kWhiteColor),
                      )),
                ),
              )
            ],
          )),
        ));
  }
}
