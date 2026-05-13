import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:driver/Components/commonwidgetbutton.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/order_delivered.dart';
import 'package:driver/Pages/signature/cancel_order_screen.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SignatureView extends StatefulWidget {
  @override
  SignatureViewState createState() => SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
    exportBackgroundColor: kWhiteColor,
  );

  OrderHistory? orderDetaials;
  String? orderType = "";
  bool enterFirst = false;
  bool isLoading = false;
  dynamic apCurency;
  dynamic distance;
  dynamic time;
  bool itemIndex = false;
  var txtAmount = TextEditingController();
  var balAmount = TextEditingController();
  var approvalCode = TextEditingController();
  var txtNote = TextEditingController();

  var differenceAmount;
  bool pageDestroy = false;
  var httpC = http.Client();
  List<OrderHistory> newOrders = [];
  List<OrderHistory> newOrdersSort = [];
  List<ItemsDetails> itemDetails = [];
  bool isAllSelected = false,
      btnPendingSelected = true,
      btnOutForDeliverySelected = false,
      btnCompletedSelected = false;
  bool isSelectAllVisible = false, isNoteTextVisible = false;

  File? _image; // Stores the captured image
  final ImagePicker _picker = ImagePicker();
  XFile? compressedImage;

  // Function to capture an image from the camera
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  //Calculate amount function
  double calculateAmount(double amount1, double amount2) {
    if (amount1 < amount2) {
      return amount2 - amount1;
    }
    return amount1 - amount2;
  }

  // Update amount function
  updateAmount() {
    differenceAmount = calculateAmount(
        double.parse(orderDetaials!.remainingPrice!.toStringAsFixed(2)),
        double.tryParse(txtAmount.text) ?? 0.0);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getSharedValue();

    _controller.addListener(() => print("Value changed"));
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map dataObject = {};
    dataObject = ModalRoute.of(context)?.settings.arguments as Map;
    // final Map<String, Object> dataObject =
    //     ModalRoute.of(context).settings.arguments;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataObject['OrderDetail'];
        orderType = dataObject['orderType'];
        print("orderType in signature view: ${orderType}  ");
        distance = calculateDistance(
                double.parse('${orderDetaials!.userLat}'),
                double.parse('${orderDetaials!.userLng}'),
                double.parse('${orderDetaials!.storeLat}'),
                double.parse('${orderDetaials!.storeLng}'))
            .toStringAsFixed(2);
        time = calculateTime(
            double.parse('${orderDetaials!.userLat}'),
            double.parse('${orderDetaials!.userLng}'),
            double.parse('${orderDetaials!.storeLat}'),
            double.parse('${orderDetaials!.storeLng}'));
        print('$distance');
        print('$time');
      });
    }

    if (orderDetaials != null && orderDetaials!.items != null) {
      for (var i = 0; i < orderDetaials!.items!.length; i++) {
        if ('${orderDetaials!.items![i].payment_method}' == 'COD') {
          itemIndex = true;
          print("item index: $itemIndex");
        }
      }
    }

    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              leadingWidth: 40,
              centerTitle: false,
              toolbarHeight: 60,
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Delivery ID - \n#${orderDetaials!.delivery_unique_code}',
                      // 'Order',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kWhiteColor,
                          fontSize: 14)),
                ],
              ),
              actions: [
                InkWell(
                  onTap: () {
                    print("----${orderDetaials!.items.toString()}");
                    Navigator.pushNamed(context, PageRoutes.iteminfo,
                        arguments: {'details': orderDetaials!.items});
                  },
                  child: buildCommonCircularButton(
                      context, Icons.shopping_basket, 'Order Info',
                      details: orderDetaials!.items, type: 1),
                ),
              ],
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        'Please Capture Image',
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(child: Text('')),
                      ElevatedButton(
                        style: ButtonStyle(
                          shadowColor: WidgetStateProperty.all(kPurpleLight),
                          overlayColor: WidgetStateProperty.all(kPurpleLight),
                          backgroundColor:
                              WidgetStateProperty.all(kPurpleLight),
                          foregroundColor:
                              WidgetStateProperty.all(kPurpleLight),
                        ),
                        onPressed: () {
                          setState(() => _image = null);
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_image == null) {
                            _captureImage();
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please clear existing image',
                                gravity: ToastGravity.CENTER,
                                toastLength: Toast.LENGTH_SHORT);
                          }
                        },
                        child: Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 0.5)),
                          height: MediaQuery.of(context).size.height / 3.5,
                          width: MediaQuery.of(context).size.width - 20,
                          child: _image != null
                              ? RotatedBox(
                                  quarterTurns: 1,
                                  child: Image.file(
                                    _image!,
                                    width: 300,
                                    height: 300,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera,
                                      size: 40,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "No image captured",
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "Click here to capture image",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        'Sign/Signature In Below Box',
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(child: Text('')),
                      ElevatedButton(
                        style: ButtonStyle(
                          shadowColor: WidgetStateProperty.all(kPurpleLight),
                          overlayColor: WidgetStateProperty.all(kPurpleLight),
                          backgroundColor:
                              WidgetStateProperty.all(kPurpleLight),
                          foregroundColor:
                              WidgetStateProperty.all(kPurpleLight),
                        ),
                        onPressed: () {
                          setState(() => _controller.clear());
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 0.5)),
                    height: MediaQuery.of(context).size.height / 3.5,
                    child: Signature(
                      controller: _controller,
                      width: MediaQuery.of(context).size.width - 20,
                      backgroundColor: kWhiteColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print(
                              "orderType: zap   &. distance: ${distance}  &. time: ${time} ");

                          // Navigator.pushNamed(
                          //     context, PageRoutes.cancelOrderScreen,
                          //     arguments: {
                          //       'OrderDetail': orderDetaials,
                          //       'distance': distance,
                          //       'time': time,
                          //       "orderType": orderType,
                          //     }).then((value) {
                          //   getOrderList();
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CancelOrderScreen(
                                orderDetaials: orderDetaials,
                                distance: distance,
                                time: time,
                                orderType: orderType,
                              ),
                            ),
                          ).then((value) {
                            getOrderList();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kPurpleLight,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Cancel Order',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_image != null) {
                          if (itemIndex) {
                            showModalBottomSheet<void>(
                              isScrollControlled: true,
                              useSafeArea: true,
                              context: context,
                              builder: (BuildContext Ncontext) {
                                return SingleChildScrollView(
                                  child: StatefulBuilder(
                                    builder: (stfContext, stfSetState) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        },
                                        child: Padding(
                                          padding: MediaQuery.of(Ncontext)
                                              .viewInsets,
                                          child: Container(
                                            height: MediaQuery.sizeOf(Ncontext)
                                                    .height /
                                                1.3,
                                            width: MediaQuery.sizeOf(Ncontext)
                                                .width,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Complete Order',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 20,
                                                            color: kPurpleLight,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Expanded(child: Text("")),
                                                      InkWell(
                                                        onTap: () {
                                                          stfSetState(() {
                                                            txtAmount.text = "";
                                                            balAmount.text = "";
                                                            approvalCode.text =
                                                                "";
                                                            isNoteTextVisible =
                                                                false;
                                                            txtNote.text = "";
                                                          });
                                                          Navigator.of(Ncontext)
                                                              .pop();
                                                        },
                                                        child: Icon(
                                                          Icons.cancel,
                                                          size: 30,
                                                          color: kRedColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Total Bill Amount: ',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16,
                                                            color:
                                                                kMainTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        '$apCurency ${orderDetaials!.remainingPrice!.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16,
                                                            color:
                                                                kMainTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'Amount Received from Customer: ',
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 16,
                                                        color: kMainTextColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextField(
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    onChanged: (value) async {
                                                      balAmount.text = "";
                                                      stfSetState(() {
                                                        updateAmount();
                                                        if (double.parse(orderDetaials!
                                                                .remainingPrice!
                                                                .toStringAsFixed(
                                                                    2)) <
                                                            double.parse(
                                                                txtAmount
                                                                    .text)) {
                                                          balAmount.text =
                                                              '$differenceAmount';
                                                          double diffAmount =
                                                              double.parse(
                                                                  balAmount
                                                                      .text);
                                                          String refAmount =
                                                              diffAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                          balAmount.text =
                                                              refAmount;
                                                        }
                                                      });
                                                    },
                                                    onSubmitted: (value) {
                                                      balAmount.text = "";
                                                      stfSetState(() {
                                                        updateAmount();
                                                        if (double.parse(orderDetaials!
                                                                .remainingPrice!
                                                                .toStringAsFixed(
                                                                    2)) <
                                                            double.parse(
                                                                txtAmount
                                                                    .text)) {
                                                          balAmount.text =
                                                              '$differenceAmount';
                                                          double diffAmount =
                                                              double.parse(
                                                                  balAmount
                                                                      .text);
                                                          String refAmount =
                                                              diffAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                          balAmount.text =
                                                              refAmount;
                                                        }
                                                      });
                                                    },
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontFamily: 'Poppins'),
                                                    controller: txtAmount,
                                                    decoration: new InputDecoration(
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        hintText:
                                                            'Enter Amount',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                kMainTextColor,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16)),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Visibility(
                                                    visible: isNoteTextVisible,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Note: Insufficient amount entered for the order price.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 16,
                                                              color:
                                                                  kMainTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(height: 10),
                                                        TextField(
                                                          style: TextStyle(
                                                              color:
                                                                  kMainTextColor,
                                                              fontFamily:
                                                                  'Poppins'),
                                                          controller: txtNote,
                                                          decoration: new InputDecoration(
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              hintText:
                                                                  'Enter Note',
                                                              hintStyle: TextStyle(
                                                                  color:
                                                                      kMainTextColor,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize:
                                                                      16)),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Balance Amount Refunded: ',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16,
                                                            color:
                                                                kMainTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextField(
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    onChanged: (value) async {
                                                      stfSetState(() {});
                                                    },
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontFamily: 'Poppins'),
                                                    controller: balAmount,
                                                    decoration: new InputDecoration(
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        hintText:
                                                            'Refund Amount',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                kMainTextColor,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16)),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Please Enter Approval Code: ',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16,
                                                            color:
                                                                kMainTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextField(
                                                    onChanged: (value) async {
                                                      stfSetState(() {});
                                                    },
                                                    style: TextStyle(
                                                        color: kMainTextColor,
                                                        fontFamily: 'Poppins'),
                                                    controller: approvalCode,
                                                    decoration: new InputDecoration(
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        hintText:
                                                            'Approval Code',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                kMainTextColor,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 16)),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        kPurpleLight,
                                                                    minimumSize:
                                                                        Size(
                                                                            150,
                                                                            40)),
                                                            onPressed: () {
                                                              stfSetState(() {
                                                                txtAmount.text =
                                                                    "";
                                                                balAmount.text =
                                                                    "";
                                                                approvalCode
                                                                    .text = "";
                                                                isNoteTextVisible =
                                                                    false;
                                                                txtNote.text =
                                                                    "";
                                                              });
                                                              Navigator.of(
                                                                      Ncontext)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 16,
                                                                  color:
                                                                      kWhiteColor),
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        kPurpleLight,
                                                                    minimumSize:
                                                                        Size(
                                                                            150,
                                                                            40)),
                                                            onPressed: () {
                                                              if (double.parse(
                                                                          txtAmount
                                                                              .text) <
                                                                      double.parse(orderDetaials!
                                                                          .remainingPrice!
                                                                          .toStringAsFixed(
                                                                              2)) &&
                                                                  isNoteTextVisible ==
                                                                      false) {
                                                                isNoteTextVisible =
                                                                    true;
                                                                stfSetState(
                                                                    () {});

                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        'Please enter noten insufficient amount entered for the order price.',
                                                                    gravity:
                                                                        ToastGravity
                                                                            .CENTER,
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT);
                                                              } else {
                                                                setState(() {});
                                                                if (txtAmount
                                                                        .text ==
                                                                    "") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          'Please enter amount',
                                                                      gravity:
                                                                          ToastGravity
                                                                              .CENTER,
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT);
                                                                } else if (double.parse(txtAmount
                                                                            .text) <
                                                                        double.parse(orderDetaials!
                                                                            .remainingPrice!
                                                                            .toStringAsFixed(
                                                                                2)) &&
                                                                    txtNote.text
                                                                        .isEmpty &&
                                                                    txtNote.text ==
                                                                        "") {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          'Please enter note',
                                                                      gravity:
                                                                          ToastGravity
                                                                              .CENTER,
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT);
                                                                } else if (approvalCode
                                                                        .text ==
                                                                    "") {
                                                                  stfSetState(
                                                                      () {
                                                                    isNoteTextVisible =
                                                                        false;
                                                                  });
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          'Please enter approval code',
                                                                      gravity:
                                                                          ToastGravity
                                                                              .CENTER,
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT);
                                                                } else {
                                                                  Navigator.pop(
                                                                      Ncontext);
                                                                  uploadSignature(
                                                                      context,
                                                                      locale!);
                                                                }
                                                              }
                                                            },
                                                            child: Text(
                                                              "Submit",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 16,
                                                                  color:
                                                                      kWhiteColor),
                                                            )),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          } else {
                            print("Payment method card");
                            uploadSignature(context, locale!);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please upload product image',
                              gravity: ToastGravity.CENTER,
                              toastLength: Toast.LENGTH_SHORT);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kPurpleLight,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Mark As Delivered',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kWhiteColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
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
    print(ordersfortodayUri);
    print("dboy_id: ${prefs.getInt('db_id')}");
    http.post(ordersfortodayUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        if ('${value.body}' != '\n[{\"order_details\":\"no orders found\"}]') {
          var jsD = jsonDecode(value.body) as List;
          if (!pageDestroy) {
            setState(() {
              newOrders.clear();
              newOrdersSort.clear();
              newOrdersSort =
                  List.from(jsD.map((e) => OrderHistory.fromJson(e)).toList());
              orderStatusSorting(1);
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

  //Order sorting status wise function
  void orderStatusSorting(int selectedBtn) {
    newOrders.clear();
    for (var i = 0; i < newOrdersSort.length; i++) {
      if (selectedBtn == 1) {
        if ('${newOrdersSort[i].orderStatus}'.toLowerCase() == 'pending' ||
            '${newOrdersSort[i].orderStatus}'.toLowerCase() == 'accepted' ||
            '${newOrdersSort[i].orderStatus}'.toUpperCase() == 'CONFIRMED') {
          newOrders.add(newOrdersSort[i]);
        }
        btnPendingSelected = true;
        btnOutForDeliverySelected = false;
        btnCompletedSelected = false;
      } else if (selectedBtn == 2) {
        if ('${newOrdersSort[i].orderStatus}'.toUpperCase() ==
            'OUT FOR DELIVERY') {
          newOrders.add(newOrdersSort[i]);
        }
        btnPendingSelected = false;
        btnOutForDeliverySelected = true;
        btnCompletedSelected = false;
      } else if (selectedBtn == 3) {
        if ('${newOrdersSort[i].orderStatus}'.toLowerCase() ==
            'Completed'.toLowerCase()) {
          newOrders.add(newOrdersSort[i]);
        }
        btnPendingSelected = false;
        btnOutForDeliverySelected = false;
        btnCompletedSelected = true;
      }
      if ('${newOrdersSort[i].orderStatus}'.toUpperCase() == 'CONFIRMED') {
        isSelectAllVisible = true;
      }
    }
    if (!pageDestroy) {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {});
  }

  // Complete order API call
  void uploadSignature(BuildContext context, AppLocalizations locale) async {
    setState(() {
      isLoading = true;
    });
    showLoader(context);
    try {
      // Signature compression variables
      MultipartFile? userSignature;
      MultipartFile? driverPhoto;

      // Check if the signature controller contains data
      if (_controller.isNotEmpty) {
        Uint8List? data = await _controller.toPngBytes();

        // Compress the signature image
        final compressedData = await FlutterImageCompress.compressWithList(
          data!,
          quality: 50, // Adjust compression quality (1-100)
        );

        // Save the compressed file
        final directory = await getApplicationDocumentsDirectory();
        final File compressedFile =
            File('${directory.path}/compressed_signature.png')
              ..writeAsBytesSync(compressedData);

        // Prepare the compressed file for the API call
        userSignature = await MultipartFile.fromFile(compressedFile.path);
        driverPhoto = await MultipartFile.fromFile(_image!.path);

        print("Compressed file path: ${compressedFile.path}");
        print("Compressed file size: ${compressedFile.lengthSync()} bytes");
        print("image path: ${_image!.path.toString()}");
      } else {
        userSignature =
            MultipartFile.fromString(""); // If empty, send an empty string
      }

      // Handle other form data fields
      final balAmount1 = balAmount.text.isNotEmpty ? balAmount.text : null;
      final approvalCode1 =
          approvalCode.text.isNotEmpty ? approvalCode.text : null;
      final driverNote = txtNote.text.isNotEmpty ? txtNote.text : null;

      // Prepare FormData for API request
      final formData = FormData.fromMap({
        'cart_id': '${orderDetaials!.cartId}',
        'user_signature': userSignature,
        'subsciption_id': '${orderDetaials!.subsciption_id}',
        'delivery_unique_code': orderDetaials!.delivery_unique_code,
        'refunded_amount': balAmount1,
        'approval_code': approvalCode1,
        "driver_note": driverNote,
        'driver_photo': driverPhoto,
      });

      print("Delivery Completed API URL: ${deliveryCompletedUri.toString()}");
      print("cart_id: ${orderDetaials!.cartId.toString()}");
      print("user_signature: ${userSignature.toString()}");
      print("subsciption_id: ${orderDetaials!.subsciption_id.toString()}");
      print(
          "delivery_unique_code: ${orderDetaials!.delivery_unique_code.toString()}");
      print("refunded_amount: ${balAmount1.toString()}");
      print("approval_code: ${approvalCode1.toString()}");
      print("driver_note: ${driverNote.toString()}");
      print("driver_photo: ${_image!.path.toString()}");

      // Create Dio instance and send the request
      final dio = Dio();
      // print("G1---orderType--->$orderType");
      var url = deliveryCompletedUri;
      if (orderType == "zap") {
        url = zapDeliveryCompletedUri;
        // print("G1---orderType--->$orderType   &. url---->$url  ");
      }
      print("url: $url");

      final response = await dio.post(
        url.toString(),
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json', // Add additional headers if needed
          },
        ),
      );
      print("G1---response-->$response");
      // Handle API response
      if (response.data != null && response.data['status'] == '1') {
         print("G1---response-->$response");
        distance = '${response.data['distance']}';
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OrderDeliveredPage(
              orderDetaials: orderDetaials,
              distance: distance,
              time: time,
            ),
          ),
          (Route route) => false,
        );

        Fluttertoast.showToast(
          msg: response.data['message'],
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: response.data['message'],
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
        );
        hideLoader(context);
        throw Exception(response.data?['message'] ?? locale.pleasetryagain!);
      }
    } catch (e) {
      print("Error during API call: $e");

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: locale.pleasetryagain!,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: kPurpleLight,
          ),
        );
      },
    );
  }

  void hideLoader(BuildContext context) {
    Navigator.of(context).pop();
  }

  void pleaseSign(BuildContext context) {
    Fluttertoast.showToast(
        msg: 'Please signature',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT);
  }
}
