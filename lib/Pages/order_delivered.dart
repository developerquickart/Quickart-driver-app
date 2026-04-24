import 'package:driver/Pages/home_page.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/Theme/style.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';

class OrderDeliveredPage extends StatefulWidget {
  final OrderHistory? orderDetaials;
  final dynamic distance;
  final dynamic time;

  const OrderDeliveredPage(
      {super.key, this.orderDetaials, this.distance, this.time});

  @override
  _OrderDeliveredPageState createState() =>
      _OrderDeliveredPageState(this.orderDetaials, this.distance, this.time);
}

class _OrderDeliveredPageState extends State<OrderDeliveredPage> {
  OrderHistory? orderDetaials;
  bool enterFirst = false;
  bool isLoading = false;
  dynamic apCurency;
  dynamic distance;
  dynamic time;
  dynamic screen;
  _OrderDeliveredPageState(this.orderDetaials, this.distance, this.time)
      : super();

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (!enterFirst) {
      setState(() {});
    }
    return WillPopScope(
        onWillPop: () async {
          bool? result = await Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => HomePage()),
              (route) => false);

          return result!;
        },
        child: SafeArea(
          child: Scaffold(
              body: Column(
            children: [
              Spacer(
                flex: 2,
              ),
              Image.asset(
                'assets/delivery completed.png',
                scale: 3,
              ),
              Spacer(),
              Text(locale!.deliveredSuccessfully!,
                  style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 6,
              ),
              Text(locale.thankYouForDelivering!,
                  style: TextStyle(fontSize: 16)),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  children: [
                    RichText(
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: locale.youDrove! + '\n', style: TextStyle()),
                      TextSpan(
                          text: '$time ($distance)\n',
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: primaryColor,
                              fontFamily: 'Poppins')),
                      TextSpan(
                        text: locale.viewOrderInfo,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Poppins'
                            // height: 1.5,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(
                                context, PageRoutes.orderHistoryPage,
                                arguments: {
                                  'OrderDetail': orderDetaials,
                                  'distance': distance,
                                  'time': time
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
