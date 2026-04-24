import 'dart:convert';
import 'dart:math';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/cancelled_order.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/CancellationReasonModel.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';

class CancelOrderScreen extends StatefulWidget {
  final dynamic distance;
  final dynamic time;
  final dynamic orderType;
  final dynamic orderDetaials;
  const CancelOrderScreen({super.key, this.distance, this.time, this.orderType, this.orderDetaials});
  @override
  CancelOrderScreenState createState() =>
      CancelOrderScreenState(this.distance, this.time, this.orderType, this.orderDetaials);
}

class CancelOrderScreenState extends State<CancelOrderScreen> {
  CancelOrderScreenState(this.distance, this.time, this.orderType, this.orderDetaials) : super();
  CancellationReasons cancellation_Reasons = new CancellationReasons();
  OrderHistory? orderDetaials;
  dynamic orderType;
  bool isDataLoaded = false;
  bool enterFirst = false;
  int selectedIndex = -1;
  var http = Client();
  dynamic reason;
  dynamic distance;
  dynamic time;
  dynamic apCurency;
  bool pageDestroy = false;
  bool isLoading = false;
  List<OrderHistory> newOrders = [];
  List<OrderHistory> newOrdersSort = [];
  bool isBtnVisible = false;
  bool isSelectAllVisible = false;
  bool isAllSelected = false,
      btnPendingSelected = true,
      btnOutForDeliverySelected = false,
      btnCompletedSelected = false,
      btnCancelledSelected = false;
  var cancelReason = TextEditingController();

  @override
  void initState() {
    super.initState();
    orderDetaials = widget.orderDetaials;
    distance = widget.distance;
  time = widget.time;
  orderType = widget.orderType;
    print("orderType:-- ${orderType}   &. distance: ${distance}  &. time: ${time} ");
    getOrderCancellationReasons();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  //Get order cancellation reasons API call
  void getOrderCancellationReasons() async {
    setState(() {
      isLoading = true;
    });
    var url = cancellationReasons;
        print("G1---orderType--->$orderType");

    if (orderType == "zap") {
      url = zapCancellationReasons;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    print("url: $url");
    http.get(url).then((value) {
      print('resp - ${value.body}');
      if (value.statusCode == 200) {
        cancellation_Reasons =
            CancellationReasons.fromJson(jsonDecode(value.body));
        setState(() {
          isDataLoaded = true;
          isLoading = false;
        });
      } else {
        setState(() {
          isDataLoaded = false;
          isLoading = true;
        });
      }
    }).catchError((e) {});
  }

  //Order cancel API call
  void cancelOrderApiCall() {
    setState(() {
      isLoading = true;
    });
    print("Unique Code: ${orderDetaials!.delivery_unique_code}");
    print("Cancel Reason: ${reason.toString()}");
    print('G1----distance--->$distance');
    print('G1----time--->$time');

    var url = cancelOrder;
    if (orderType == "zap") {
      url = zapCancelOrder;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    print("url: $url");
    http.post(url, body: {
      'delivery_unique_code': '${orderDetaials!.delivery_unique_code}',
      'cancel_reason': '${reason.toString()}'
    }).then((value) async {
      print(value.body);
      if (value.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print('G1----distance1--->$distance');
        print('G1----time1--->$time');
        Navigator.of(context)
            .pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => CancelledOrderPage(
                          orderDetaials: orderDetaials,
                          distance: distance,
                          time: time,
                        )),
                (Route route) => false)
            .then((value) {});
        print("OrderDetail: ${orderDetaials}");
      } else {
        Toast.show("Something Went Wrong",
            gravity: Toast.center, duration: Toast.lengthShort);
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((e) {});
  }

  //Calculate distance function
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //Calculate time function
  String calculateTime(lat1, lon1, lat2, lon2) {
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kmsPerMin = 0.5;
    double minsTaken = kms / kmsPerMin;
    double min = minsTaken;
    if (min < 60) {
      return "" + '${min.toInt()}' + " mins";
    } else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60).toStringAsFixed(2)}' +
          " hour " +
          minutes +
          " mins";
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations.of(context);
    // Map dataObject = {};
    // dataObject = ModalRoute.of(context)?.settings.arguments as Map;
    // if (!enterFirst) {
    //   setState(() {
    //     enterFirst = true;
    //     orderDetaials = dataObject['OrderDetail'];
    //   });
    // }

    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              centerTitle: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cancel Order',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kWhiteColor,
                          fontSize: 18)),
                ],
              ),
              actions: [],
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount:
                                cancellation_Reasons.cancelReason!.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        reason = cancellation_Reasons
                                            .cancelReason![index].reason;
                                        print(selectedIndex);
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      children: [
                                        Radio(
                                          activeColor: kPurpleLight,
                                          value: index,
                                          groupValue: selectedIndex,
                                          toggleable: false,
                                          onChanged: (valse) {
                                            setState(() {
                                              selectedIndex = index;
                                              cancelReason.text = "";
                                              reason = cancellation_Reasons
                                                  .cancelReason![index].reason;
                                              print("reason: $reason");
                                              print(selectedIndex);
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${cancellation_Reasons.cancelReason![index].reason}',
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Visibility(
                            visible: (reason ?? "").toString().toLowerCase() == "others",
                            child: TextField(
                              maxLines: null,
                              onChanged: (value) async {
                                setState(() {
                                  reason = cancelReason.text;
                                  print("reason: $reason");
                                });
                              },
                              style: TextStyle(
                                  color: kMainTextColor, fontFamily: 'Poppins'),
                              controller: cancelReason,
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  hintText: 'Cancel Reason',
                                  hintStyle: TextStyle(
                                      color: kMainTextColor,
                                      fontFamily: 'Poppins',
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 50,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kPurpleLight),
                              onPressed: () {
                                if (reason.toLowerCase() == "others" &&
                                    cancelReason.text == "" &&
                                    cancelReason.text.isEmpty) {
                                  Toast.show("Please enter cancellation reason",
                                      gravity: Toast.center,
                                      duration: Toast.lengthShort);
                                } else {
                                  cancelOrderApiCall();
                                }
                              },
                              child: Text(
                                "Cancel Order",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: kWhiteColor),
                              )),
                        )
                      ],
                    ),
                  ),
                )),
    );
  }
}
