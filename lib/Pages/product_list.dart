import 'dart:convert';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductList extends StatefulWidget {
  @override
  ProductListState createState() {
    return ProductListState();
  }
}

class ProductListState extends State<ProductList> {
  List<ItemsDetails> orderDetails = [];
  OrderHistory? orderHistory;

  List<OrderHistory> newOrders = [];
  String? orderType = "";
  var apCurrency;

  bool enterfirst = true;

  bool isBtnVisible = false;
  bool isSelectAllVisible = false;
  bool isAllSelected = false;
  bool isLoading = false;
  var http = Client();
  dynamic apCurency;
  bool pageDestroy = false;
  List<OrderHistory> newOrdersSort = [];
  bool checkedValue = false;

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
    Map dataObject = {};
    dataObject = ModalRoute.of(context)?.settings.arguments as Map;
    if (enterfirst) {
      setState(() {
        enterfirst = false;
        orderHistory = dataObject['OrderDetail'];
        orderDetails = receivedData['details'];
         orderType = receivedData['orderType'];
        print("receivedData: ${receivedData.toString()}");
      });
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'PRODUCT LIST',
            style: TextStyle(color: kWhiteColor, fontSize: 18),
          ),
        ),
        body: (orderDetails.length > 0)
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10, top: 10),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            print("G1---varientImage---> ${orderDetails[index].varientImage}");
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
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: CachedNetworkImage(
                                            height: 90,
                                            width: 90,
                                            imageUrl:
                                                '${orderDetails[index].varientImage}',
                                            fit: BoxFit.contain,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${orderDetails[index].productName}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: kPurpleLight,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 2,
                                          ),
                                          Text(
                                            '(${orderDetails[index].quantity} ${orderDetails[index].unit})',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
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
                                              Expanded(child: Text('')),
                                              Checkbox(
                                                activeColor: kPurpleLight,
                                                value: orderDetails[index]
                                                    .isChecked,
                                                onChanged: (val) {
                                                  if (orderDetails[index]
                                                          .isChecked ==
                                                      true) {
                                                    unselectedProducts(
                                                        context,
                                                        orderDetails[index]
                                                            .varientId,
                                                        orderDetails[index]
                                                            .orderCartId,
                                                        orderHistory!
                                                            .delivery_unique_code);
                                                  } else {
                                                    selectedProducts(
                                                        context,
                                                        orderDetails[index]
                                                            .varientId,
                                                        orderDetails[index]
                                                            .orderCartId,
                                                        orderHistory!
                                                            .delivery_unique_code);
                                                  }

                                                  setState(() {
                                                    orderDetails[index]
                                                        .isChecked = val;
                                                  });
                                                },
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
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
              onTap: () {
                bool isAnyChecked = false;
                for (var i = 0; i < orderDetails.length; i++) {
                  if (orderDetails[i].isChecked == true) {
                    isAnyChecked = true;
                  }
                }
                if (isAnyChecked) {
                  Navigator.pushNamed(context, PageRoutes.signatureview,
                      arguments: {'OrderDetail': orderHistory, "orderType" :orderType}).then((value) {
                    getOrderList();
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "Please Select Atleast One Product",
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_SHORT);
                }
              },
              child: Container(
                color: kPurpleLight,
                height: 60,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'Next',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: kWhiteColor),
                ),
              )),
        ),
      ),
    );
  }

  //Selected product API call
  void selectedProducts(BuildContext context, dynamic varientIds,
      dynamic orderCartIds, dynamic deliveryUniqueCode) async {
    setState(() {
      isLoading = true;
    });
    // print("G1---orderType--->$orderType");
    var url = isProdSelected;
    if (orderType == "zap") {
      url = zapProdSelected;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    print("url: $url");
    print("varient_id: $varientIds");
    print("order_cart_id: ${orderCartIds}");
    print("delivery_unique_code: ${deliveryUniqueCode}");

    await http.post(url, body: {
      'varient_id': "$varientIds",
      'order_cart_id': orderCartIds,
      'delivery_unique_code': deliveryUniqueCode,
    }).then((value) {
      
      print("StatusCode: ${value.statusCode}");
      print("Body-----: ${value.body}");
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          setState(() {
            print("isChecked = true");
          });
        } else {
          isLoading = false;
        }
      } else {
        isLoading = false;
        Fluttertoast.showToast(
            msg: "Something went wrong please try again after sometime",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT);
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

  //Unselected products API call
  void unselectedProducts(BuildContext context, dynamic varientIds,
      dynamic orderCartIds, dynamic deliveryUniqueCode) async {
    setState(() {
      isLoading = true;
    });

      // print("G1---orderType--->$orderType");
    var url = isProdUnSelected;
    if (orderType == "zap") {
      url = zapProdUnSelected;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    print("url: $url");
      print("varient_id: $varientIds");
      print("order_cart_id: ${orderCartIds}");
      print("delivery_unique_code: ${deliveryUniqueCode}");
    await http.post(url, body: {
      'varient_id': "$varientIds",
      'order_cart_id': orderCartIds,
      'delivery_unique_code': deliveryUniqueCode,
    }).then((value) {
    
      print("StatusCode: ${value.statusCode}");
      print("Body-----: ${value.body}");
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          setState(() {
            print("isChecked = false");
          });
        } else {
          isLoading = false;
        }
      } else {
        isLoading = false;
        Fluttertoast.showToast(
            msg: "Something went wrong please try again after sometime",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT);
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

  //Get order list API call
  void getOrderList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!pageDestroy) {
      setState(() {
        isLoading = true;
        apCurency = prefs.getString('app_currency');
      });
    }
      // print("G1---orderType--->$orderType");
    var url = ordersfortodayUri;
    if (orderType == "zap") {
      url = zapOrdersfortodayUri;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    print("url: $url");
    print("dboy_id: ${prefs.getInt('db_id')}");
    http.post(url,
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
}

class ItemList {
  dynamic varient_id;
  dynamic order_cart_id;
  dynamic deliveryCode;

  ItemList({this.varient_id, this.order_cart_id, this.deliveryCode});

  ItemList.fromJson(Map<String, dynamic> json) {
    varient_id = json['varient_id'];
    order_cart_id = json['order_cart_id'];
    deliveryCode = json['delivery_unique_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['varient_id'] = this.varient_id;
    data['order_cart_id'] = this.order_cart_id;
    data['delivery_unique_code'] = this.deliveryCode;

    return data;
  }
}
