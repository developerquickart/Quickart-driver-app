import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/Components/commonwidget.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/Zap%20orders/order_root_map.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/CancellationReasonModel.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ZapTodayOrder extends StatefulWidget {
  @override
  _ZapTodayOrderState createState() => _ZapTodayOrderState();
}

class _ZapTodayOrderState extends State<ZapTodayOrder> {
  List<OrderHistory> newOrders = [];
  List<OrderHistory> newOrdersSort = [];
  List<CancellationReasons> cancelorderreason = [];
  bool isLoading = false;
  var http = Client();
  dynamic apCurency;
  bool pageDestroy = false;
  bool isBtnVisible = false;
  bool isSelectAllVisible = false;
  bool isAllSelected = false,
      btnPendingSelected = true,
      btnOutForDeliverySelected = false,
      btnCompletedSelected = false,
      btnCancelledSelected = false;
  int status = 1;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getOrderList();
    // getOrderCancellationReasons();
  }

  //Get current location function
  Future<void> getCurrentLocation() async {
    Geolocator.getCurrentPosition(forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        print("G1---1>${position.latitude}");
        print("G1---1>${position.longitude}");
        dBoyLat = position.latitude;
        dBoyLng = position.longitude;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    pageDestroy = true;
    http.close();
    super.dispose();
  }

  //Get order list API call
  void getOrderList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!pageDestroy) {
      setState(() {
        isLoading = true;
        apCurency = prefs.getString('app_currency');
      });
    }
    print(zapOrdersfortodayUri);
    print("---------dboy_id: ${prefs.getInt('db_id')}");
    http.post(zapOrdersfortodayUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        if ('${value.body}' != '\n[{\"order_details\":\"no orders found\"}]') {
          var jsD = jsonDecode(value.body) as List;
          if (!pageDestroy) {
            print("order for today: ${value.body}");
            setState(() {
              newOrders.clear();
              newOrdersSort.clear();
              newOrdersSort =
                  List.from(jsD.map((e) => OrderHistory.fromJson(e)).toList());
              if (status == 1) {
                orderStatusSorting(1);
              } else if (status == 2) {
                orderStatusSorting(2);
              } else if (status == 3) {
                orderStatusSorting(3);
              } else if (status == 4) {
                orderStatusSorting(4);
              }
            });
          }
        } else {
          if (!pageDestroy) {
            setState(() {
              newOrders.clear();
            });
          }
        }
      } else {
        if (!pageDestroy) {
          setState(() {
            newOrdersSort.clear();
          });
        }
      }
    }).catchError((e) {
      if (!pageDestroy) {
        setState(() {
          isLoading = false;
          newOrdersSort.clear();
        });
      }
      print(e);
    });
  }

  // //Get order cancellation reasons
  // void getOrderCancellationReasons() async {
  //   setState(() {});
  //   var url = zapCancelitemlist;
  //   var http = Client();
  //   print(zapCancelitemlist);
  //   http.get(url).then((value) {
  //     print('getOrderCancellationReasons resp - ${value.body}');
  //     if (value.statusCode == 200) {
  //       CancellationReasons data1 =
  //           CancellationReasons.fromJson(jsonDecode(value.body));
  //     }
  //   }).catchError((e) {});
  // }

  //Get order list API call
  void cancalledOrderItemList(String dUniqueID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!pageDestroy) {
      setState(() {
        isLoading = true;
        apCurency = prefs.getString('app_currency');
      });
    }
    print(zapCancelitemlist);
    print("delivery_unique_code: ${dUniqueID}");
    http.post(zapCancelitemlist,
        body: {'delivery_unique_code': '${dUniqueID}'}).then((value) {
      if (value.statusCode == 200) {
        if (value.body.trim() != '[{"order_details":"no orders found"}]') {
          var jsonMap = jsonDecode(value.body);
          if (!pageDestroy) {
            print("cancel item list: ${value.body}");
            List<dynamic> itemList = jsonMap['cart_items'];

            List<ItemsDetails> cartItems =
                itemList.map((item) => ItemsDetails.fromJson(item)).toList();

            setState(() {
              Navigator.pushNamed(context, PageRoutes.iteminfo,
                  arguments: {'details': cartItems}).then((value) {
                setState(() {
                  getOrderList();
                });
              });
            });
          }
        } else {
          if (!pageDestroy) {
            setState(() {});
          }
        }
      } else {
        if (!pageDestroy) {
          setState(() {});
        }
      }
    }).catchError((e) {
      if (!pageDestroy) {
        setState(() {
          isLoading = false;
        });
      }
      print(e);
    });
  }

  //Order sorting status wise function
  void orderStatusSorting(int selectedBtn) {
    newOrders.clear();
    for (var i = 0; i < newOrdersSort.length; i++) {
      if (selectedBtn == 1) {
        if ('${newOrdersSort[i].orderStatus}'.toLowerCase() == 'pending' ||
            '${newOrdersSort[i].orderStatus}'.toLowerCase() == 'accepted' ||
            '${newOrdersSort[i].orderStatus}'.toUpperCase() == 'CONFIRMED' ||
            '${newOrdersSort[i].orderStatus}' == 'Confirmed') {
          newOrders.add(newOrdersSort[i]);
        }
        btnPendingSelected = true;
        btnOutForDeliverySelected = false;
        btnCompletedSelected = false;
        btnCancelledSelected = false;
      } else if (selectedBtn == 2) {
        if ('${newOrdersSort[i].orderStatus}'.toUpperCase() ==
            'OUT FOR DELIVERY') {
          newOrders.add(newOrdersSort[i]);
          isSelectAllVisible = false;
        }
        btnPendingSelected = false;
        btnOutForDeliverySelected = true;
        btnCompletedSelected = false;
        btnCancelledSelected = false;
      } else if (selectedBtn == 3) {
        if ('${newOrdersSort[i].orderStatus}'.toLowerCase() ==
            'Completed'.toLowerCase()) {
          newOrders.add(newOrdersSort[i]);
          isSelectAllVisible = false;
        }
        btnPendingSelected = false;
        btnOutForDeliverySelected = false;
        btnCompletedSelected = true;
        btnCancelledSelected = false;
      } else if (selectedBtn == 4) {
        if ('${newOrdersSort[i].orderStatus}' == 'Cancelled') {
          newOrders.add(newOrdersSort[i]);
          isSelectAllVisible = false;
        }
        btnPendingSelected = false;
        btnOutForDeliverySelected = false;
        btnCompletedSelected = false;
        btnCancelledSelected = true;
      }
      if ('${newOrdersSort[i].orderStatus}'.toUpperCase() == 'CONFIRMED' ||
          '${newOrdersSort[i].orderStatus}' == 'Pending') {
        isSelectAllVisible = true;
      }
    }
    if (!pageDestroy) {
      setState(() {
        isLoading = false;
      });
    }
    print('g1----->$newOrders.length');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    var locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text(
              "Go ${locale!.todayorder!.toUpperCase()}",
              style: TextStyle(color: kWhiteColor, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              getOrderList();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            orderStatusSorting(1);
                            setState(() {
                              status = 1;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              margin: EdgeInsets.only(left: 0),
                              color: btnPendingSelected == true
                                  ? kPurpleLight
                                  : kYellowColor,
                              elevation: 3,
                              shape: btnPendingSelected == true
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))
                                  : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pending/Accepted',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: btnPendingSelected == true
                                            ? kYellowColor
                                            : kPurpleLight,
                                        letterSpacing: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          orderStatusSorting(2);
                          setState(() {
                            status = 2;
                            isSelectAllVisible = false;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            margin: EdgeInsets.only(left: 0),
                            color: btnOutForDeliverySelected == true
                                ? kPurpleLight
                                : kYellowColor,
                            elevation: 3,
                            shape: btnOutForDeliverySelected == true
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))
                                : RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              height: 50,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Out for Delivery',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: btnOutForDeliverySelected == true
                                          ? kYellowColor
                                          : kPurpleLight,
                                      letterSpacing: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            orderStatusSorting(3);
                            setState(() {
                              status = 3;
                              isSelectAllVisible = false;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              margin: EdgeInsets.only(right: 0),
                              color: btnCompletedSelected == true
                                  ? kPurpleLight
                                  : kYellowColor,
                              elevation: 3,
                              shape: btnCompletedSelected == true
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))
                                  : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Completed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: btnCompletedSelected == true
                                            ? kYellowColor
                                            : kPurpleLight,
                                        letterSpacing: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            orderStatusSorting(4);
                            setState(() {
                              status = 4;
                              isSelectAllVisible = false;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Card(
                              margin: EdgeInsets.only(right: 0),
                              color: btnCancelledSelected == true
                                  ? kPurpleLight
                                  : kYellowColor,
                              elevation: 3,
                              shape: btnCancelledSelected == true
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))
                                  : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Cancelled',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: btnCancelledSelected == true
                                            ? kYellowColor
                                            : kPurpleLight,
                                        letterSpacing: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: newOrders.length > 1 && isSelectAllVisible,
                  child: Row(
                    children: [
                      Expanded(child: Text('')),
                      Container(
                          child: CupertinoButton(
                        child: !isAllSelected
                            ? Text(
                                "Select all",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: kPurpleLight,
                                    fontSize: 14),
                              )
                            : Text(
                                "Unselect all",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: kPurpleLight,
                                    fontSize: 14),
                              ),
                        onPressed: () {
                          setState(() {
                            if (isAllSelected) {
                              isAllSelected = false;
                              isBtnVisible = false;
                              for (var i = 0; i < newOrders.length; i++) {
                                newOrders[i].isChecked = false;
                              }
                            } else {
                              for (var i = 0; i < newOrders.length; i++) {
                                if (newOrders[i].isChecked!) {
                                  isBtnVisible = false;
                                  isAllSelected = false;
                                } else {
                                  isBtnVisible = true;
                                  isAllSelected = true;
                                }
                                newOrders[i].isChecked = true;
                              }
                            }
                            print('Data Loaded');
                          });
                        },
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: (!isLoading &&
                          newOrders.length > 0 &&
                          newOrders[0].orderDetails == null)
                      ? ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            ListView.builder(
                                padding: EdgeInsets.only(bottom: 20),
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: newOrders.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return buildCompleteCard(
                                      context, newOrders[index], locale);
                                }),
                          ],
                        )
                      : isLoading
                          ? Align(
                              widthFactor: 40,
                              heightFactor: 40,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: Text(
                                locale.noorder!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                ),
                Visibility(
                  visible: isBtnVisible,
                  child: InkWell(
                      onTap: () {
                        List<OrderListAll> selectedorders = [];

                        for (var i = 0; i < newOrders.length; i++) {
                          if (newOrders[i].isChecked!) {
                            selectedorders.add(OrderListAll(
                                cart_id: newOrders[i].cartId,
                                subsciption_id: newOrders[i].subsciption_id,
                                delivery_unique_code:
                                    newOrders[i].delivery_unique_code,
                                dboy_lat: dBoyLat,
                                dboy_lng: dBoyLng));
                            print("cartID: ${newOrders[i].cartId}");
                            print("SubID: ${newOrders[i].subsciption_id}");
                          } else {}
                        }
                        List jsonList = [];
                        selectedorders
                            .map((item) => jsonList.add(item.toJson()))
                            .toList();
                        outForDelivery(context, jsonList);
                      },
                      child: Container(
                        color: kPurpleLight,
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Accept Delivery',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: kWhiteColor),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CircleAvatar buildStatusIcon(IconData icon, {bool disabled = false}) =>
      CircleAvatar(
          backgroundColor: !disabled ? Color(0xff222e3e) : Colors.grey[300],
          child: Icon(
            icon,
            size: 20,
            color: !disabled
                ? Theme.of(context).primaryColor
                : Theme.of(context).scaffoldBackgroundColor,
          ));

  GestureDetector buildCompleteCard(
      BuildContext context, OrderHistory mainP, AppLocalizations locale) {
    return GestureDetector(
      onTap: () {
        if ('${mainP.orderStatus}'.toUpperCase() == 'CONFIRMED' ||
            '${mainP.orderStatus}' == 'Pending') {
          // Navigator.pushNamed(context, PageRoutes.orderAcceptedPage,
          //         arguments: {'OrderDetail': mainP, "orderType": "zap"})
          //     .then((value) {
          //   getOrderList();
          // });

          Navigator.pushNamed(context, PageRoutes.orderAcceptedPage,
              arguments: {
                'details': mainP.items,
                'OrderDetail': mainP,
                "orderType": "zap"
              }).then((value) {
            getOrderList();
          });
        } else if ('${mainP.orderStatus}'.toLowerCase() ==
            'Completed'.toLowerCase()) {
          Navigator.pushNamed(context, PageRoutes.iteminfo,
              arguments: {'details': mainP.items}).then((value) {
            setState(() {});
          });
        } else if ('${mainP.orderStatus}'.toUpperCase() == 'OUT FOR DELIVERY') {
          Navigator.pushNamed(context, PageRoutes.productListScreen,
              arguments: {
                'details': mainP.items,
                'OrderDetail': mainP,
                "orderType": "zap"
              }).then((value) {
            getOrderList();
          });
        } else if ('${mainP.orderStatus}' == 'Cancelled') {
          cancalledOrderItemList(mainP.delivery_unique_code);
        }
      },
      child: Card(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        margin: EdgeInsets.only(left: 14, right: 14, top: 8),
        color: lightPurple,
        elevation: 1,
        child: Column(
          children: [
            buildItem(context, mainP),
            Visibility(
              visible: '${mainP.orderStatus}' != 'Cancelled',
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: cardLightPurple),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 12,
                                  color: kMainTextColor,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'Delivery Instruction:',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      color: kMainTextColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            mainP.del_partner_instruction != "" &&
                                    mainP.del_partner_instruction != null
                                ? Text(
                                    '${mainP.del_partner_instruction}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 12),
                                  )
                                : Text('N/A',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 12)),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 12,
                                  color: kMainTextColor,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'Special Instruction:',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      color: kMainTextColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            mainP.specialInstruction != "" &&
                                    mainP.specialInstruction != null
                                ? Text(
                                    '${mainP.specialInstruction}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 12),
                                  )
                                : Text('N/A',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 12)),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      // Spacer(),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (mainP.doorImage != null) {
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                  ),
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (BuildContext Ncontext) {
                                    return Stack(
                                      alignment: Alignment(1.03, -1.03),
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(Ncontext);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20)),
                                            child: CachedNetworkImage(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.2,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  20,
                                              imageUrl: mainP.doorImage,
                                              fit: BoxFit.fill,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(Ncontext);
                                          },
                                          child: Icon(
                                            Icons.cancel_outlined,
                                            size: 30,
                                            color: kWhiteColor,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                Toast.show("No image available to show",
                                    duration: Toast.lengthShort,
                                    gravity: Toast.center);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                height: 120,
                                width: 120,
                                imageUrl: '${mainP.doorImage}',
                                fit: BoxFit.contain,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 12,
                                color: kMainTextColor,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Door Image',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    color: kMainTextColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Click here to see',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.normal,
                                color: kMainTextColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: '${mainP.orderStatus}' == 'Cancelled',
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: cardLightPurple),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 12,
                            color: kRedColor,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            'Cancellation Reason:',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: kRedColor),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${mainP.cancel_reason}',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(color: cardLightPurple),
                child: Divider(
                  thickness: 0.5,
                )),
            buildOrderInfoRow(
                context,
                '$apCurency ${mainP.remainingPrice!.toStringAsFixed(2)}',
                '${mainP.paymentMethod}'.toUpperCase() == 'SODEXO'
                    ? 'Sodexo on delivery'
                    : '${mainP.paymentMethod}',
                '${mainP.orderStatus}',
                '${mainP.paymentMethod}'),
            Visibility(
              visible:
                  '${mainP.orderStatus}'.toUpperCase() == 'OUT FOR DELIVERY',
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.call,
                            color: Theme.of(context).focusColor,
                            size: 18,
                          ),
                          onPressed: () {
                            _launchURL("tel:${mainP.userPhone}");
                          }),
                      buildCircularButton(
                          context, Icons.navigation, "G ${locale.direction!}",
                          type: 2,
                          url:
                              'https://www.google.com/maps/dir/?api=1&origin=${dBoyLat},${dBoyLng}&destination=${mainP.userLat},${mainP.userLng}&travelmode=driving&dir_action=navigate',
                          latS: mainP.userLat,
                          lngS: mainP.userLng),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, PageRoutes.orderRootMapScreen,
                              arguments: {
                                'details': mainP.items,
                                'OrderDetail': mainP,
                                "orderType": "zap"
                              }).then((value) {
                            getOrderList();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: kPurpleLight,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(
                                  Icons.navigation,
                                  size: 18,
                                  color: kWhiteColor,
                                ),
                              ),
                              Text(
                                locale.direction!,
                                style:
                                    TextStyle(color: kWhiteColor, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  Container buildOrderInfoRow(BuildContext context, String price, String prodID,
      String orderStatus, String paymentMethod,
      {double borderRadius = 8}) {
    var locale = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
          color: cardLightPurple),
      padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
      child: Column(
        children: [
          Row(
            children: [
              buildGreyColumn(context, locale!.orderStatus!, orderStatus,
                  text2Color: Theme.of(context).primaryColor),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          buildGreyColumn(context, locale.paymentmode!, paymentMethod),
        ],
      ),
    );
  }

  Padding buildItem(BuildContext context, OrderHistory mainP) {
    var children2 = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ClipRRect(
          //     borderRadius: BorderRadius.circular(10),
          //     child: Image.asset('assets/icon.png', height: 70)),
          // SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${mainP.userName}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    )),
                Row(
                  children: [
                    Text(mainP.userPhone,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 15)),
                    Expanded(child: Container()),
                    Column(
                      children: [
                        Container(
                          height: 40,
                          width: 100,
                          child: Visibility(
                            visible: newOrders.length > 1 && isSelectAllVisible,
                            child: CheckboxListTile(
                              activeColor: kPurpleLight,
                              title: Text(''),
                              value: mainP.isChecked,
                              onChanged: (val) {
                                setState(() {
                                  mainP.isChecked = val;
                                  if (val!) {
                                    isBtnVisible = true;
                                  } else {
                                    isBtnVisible = false;
                                  }
                                  for (var i = 0; i < newOrders.length; i++) {
                                    if (newOrders[i].isChecked!) {
                                      isBtnVisible = true;
                                      isAllSelected = true;
                                    } else {
                                      isAllSelected = false;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                // SizedBox(height: 8),
                Text(
                  "Address:",
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
                Text(
                  mainP.userAddress,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Delivery ID: ',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12.0, fontFamily: 'Poppins'),
                    ),
                    Text(
                      "#${mainP.delivery_unique_code}",
                      style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                    )
                  ],
                ),
                SizedBox(height: 8),
                (mainP.items != null && mainP.items!.length > 0)
                    ? Row(
                        children: [
                          Text("Delivery Date: ",
                              style: TextStyle(
                                  fontSize: 12.0, fontFamily: 'Poppins')),
                          SizedBox(height: 5),
                          Text(
                            "${mainP.deliveryDate}",
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 8),
                (mainP.items != null && mainP.items!.length > 0 && mainP.timeSlot != null)
                    ? Row(
                        children: [
                          Text("Delivery Time Slot: ",
                              style: TextStyle(
                                  fontSize: 12.0, fontFamily: 'Poppins')),
                          SizedBox(height: 5),
                          Text(
                            "${mainP.timeSlot}",
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: children2,
      ),
    );
  }

  Padding buildAmountRow(String name, String price,
      {FontWeight fontWeight = FontWeight.w500}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: fontWeight, fontFamily: 'Poppins'),
          ),
          Spacer(),
          Text(
            price,
            style: TextStyle(fontWeight: fontWeight, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Row buildGreyColumn(BuildContext context, String text1, String text2,
      {Color text2Color = Colors.black}) {
    return Row(
      children: [
        Text(text1 + ": ",
            style: TextStyle(fontSize: 12, fontFamily: 'Poppins')),
        LimitedBox(
          maxWidth: 150,
          child: Text(text2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: text2Color)),
        ),
      ],
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Order out for delivery API call
  void outForDelivery(BuildContext context, List jsonn) async {
    setState(() {
      isLoading = true;
    });
    Map data = {'data': jsonn};
    print(data);

    var body = json.encode(data);

    var response = await http.post(outForDeliveryUri,
        headers: {"Content-Type": "application/json"}, body: body);
    print("StatusCode: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode == 200) {
      var js = jsonDecode(response.body);
      if ('${js['status']}' == '0') {
        setState(() {
          isLoading = false;
        });

        Toast.show("Something went wrong please try again after sometime",
            duration: Toast.lengthShort, gravity: Toast.center);
      }
      Toast.show(js['message'],
          duration: Toast.lengthShort, gravity: Toast.center);
      setState(() {
        isLoading = false;
        isBtnVisible = false;
        getOrderList();
      });
    } else {
      isLoading = false;
      Toast.show("Something went wrong please try again after sometime",
          duration: Toast.lengthShort, gravity: Toast.center);
    }
  }
}

class OrderListAll {
  dynamic cart_id;
  dynamic subsciption_id;
  dynamic delivery_unique_code;
  dynamic dboy_lat;
  dynamic dboy_lng;

  OrderListAll(
      {this.cart_id,
      this.subsciption_id,
      this.delivery_unique_code,
      this.dboy_lat,
      this.dboy_lng});

  OrderListAll.fromJson(Map<String, dynamic> json) {
    cart_id = json['cart_id'];
    subsciption_id = json['subsciption_id'];
    delivery_unique_code = json['delivery_unique_code'];
    dboy_lat = json['dboy_lat'];
    dboy_lng = json['dboy_lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_id'] = this.cart_id;
    data['subsciption_id'] = this.subsciption_id;
    data['delivery_unique_code'] = this.delivery_unique_code;
    data['dboy_lat'] = this.dboy_lat;
    data['dboy_lng'] = this.dboy_lng;

    return data;
  }
}
