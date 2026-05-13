import 'package:driver/Locale/locales.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemInformation extends StatefulWidget {
  @override
  ItemInformationState createState() {
    return ItemInformationState();
  }
}

class ItemInformationState extends State<ItemInformation> {
  List<ItemsDetails> orderDetails = [];

  var apCurrency;

  bool enterfirst = true;

  @override
  void initState() {
    super.initState();

    getSharedValue();
  }

  //Get shared preference value function
  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map receivedData = {};
    receivedData = ModalRoute.of(context)?.settings.arguments as Map;
    if (enterfirst) {
      setState(() {
        enterfirst = false;
        orderDetails = receivedData['details'];
        print("receivedData: ${receivedData.toString()}");
      });
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'ORDER INFO',
            style: TextStyle(color: kWhiteColor, fontSize: 18),
          ),
        ),
        body: (orderDetails.length > 0)
            ? Padding(
                padding: const EdgeInsets.only(
                    bottom: 10, left: 10, right: 10, top: 10),
                child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(1),
                        child: Card(
                          elevation: 0,
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            color: cardColor,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                          '${orderDetails[index].varientImage}',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.contain)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${orderDetails[index].productName}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: kPurpleLight,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      '(${orderDetails[index].quantity} ${orderDetails[index].unit})',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: kPurpleLight,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Item Price - $apCurrency ${orderDetails[index].price!.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: kPurpleLight,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(''),
                                        ),
                                        Text(
                                          '${locale!.invoice2h} - ${orderDetails[index].qty}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: kPurpleLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '${locale.invoice4h} ${locale.invoice3h} - $apCurrency ${orderDetails[index].price!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: kPurpleLight,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Product ID - #${orderDetails[index].orderCartId}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: kPurpleLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Payment Method - ',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: kPurpleLight,
                                          ),
                                        ),
                                        Text(
                                          '${orderDetails[index].payment_method}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: kPurpleLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, indext) {
                      return SizedBox(
                        height: 1,
                      );
                    },
                    itemCount: orderDetails.length),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
