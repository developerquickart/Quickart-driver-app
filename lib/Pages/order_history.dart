import 'package:driver/Pages/home_page.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  OrderHistory? orderDetaials;
  List<ItemsDetails> orderDetails = [];
  bool enterFirst = false;
  bool isLoading = false;
  dynamic distance;
  dynamic time;
  dynamic apCurency;

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  //Get shared preference value function
  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map dataObject = {};
    dataObject = ModalRoute.of(context)?.settings.arguments as Map;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataObject['OrderDetail'];
        distance = dataObject['distance'];
        time = dataObject['time'];
        orderDetails = orderDetaials!.items!;
        print('$distance');
        print('$time');
      });
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          foregroundColor: kWhiteColor,
          title: Text(
            'Delivery ID - #${orderDetaials!.delivery_unique_code}\n${locale!.deliveryDate} ${orderDetaials!.deliveryDate}',
            style: TextStyle(
                fontWeight: FontWeight.w300, color: kWhiteColor, fontSize: 14),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  primary: true,
                  child: Column(
                    children: [
                      (orderDetails.length > 0)
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              primary: false,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, bottom: 0, left: 10, right: 10),
                                  child: Card(
                                    color: cardColor,
                                    elevation: 0,
                                    clipBehavior: Clip.hardEdge,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.network(
                                                  '${orderDetails[index].varientImage}',
                                                  fit: BoxFit.contain,
                                                  height: 90,
                                                  width: 90,
                                                )),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${orderDetails[index].productName}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: kPurpleLight,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                maxLines: 2,
                                              ),
                                              Text(
                                                '(${orderDetails[index].quantity} ${orderDetails[index].unit})',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: kPurpleLight,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Item Price - $apCurency ${orderDetails[index].price!.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: kPurpleLight,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(''),
                                                  ),
                                                  Text(
                                                    '${locale.invoice2h} - ${orderDetails[index].qty}',
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
                                                '${locale.invoice4h} ${locale.invoice3h} - $apCurency ${orderDetails[index].price!.toStringAsFixed(2)}',
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
                                              SizedBox(height: 5),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  height: 0,
                                );
                              },
                              itemCount: orderDetails.length)
                          : SizedBox.shrink(),
                      Divider(
                        height: 10,
                      ),
                      distance != null && distance != 0.00
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12),
                              child: Row(
                                children: [
                                  RichText(
                                      text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text: locale.distance! + '\n',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins')),
                                    TextSpan(
                                        text: '$distance',
                                        style: TextStyle(
                                            color: Colors.green,
                                            height: 1.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins')),
                                    TextSpan(
                                        text: ' ($time)',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Poppins')),
                                  ])),
                                  Spacer(
                                    flex: 2,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      distance != null && distance != 0.00
                          ? Divider(
                              height: 5,
                            )
                          : Container(),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 24,
                        ),
                        title: Text(
                          '${orderDetaials!.storeName}',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          '${orderDetaials!.storeAddress}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.navigation,
                          color: Colors.green,
                          size: 24,
                        ),
                        title: Text(
                          '${orderDetaials!.userName}',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address:",
                              maxLines: 2,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${orderDetaials!.userAddress}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
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
          ),
        ),
      ),
    );
  }
}
