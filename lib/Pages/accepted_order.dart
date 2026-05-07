import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:driver/Components/commonwidget.dart';
import 'package:driver/Components/commonwidgetbutton.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/Zap%20orders/order_root_map.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OrderAcceptedPage extends StatefulWidget {
  @override
  _OrderAcceptedPageState createState() => _OrderAcceptedPageState();
}

class _OrderAcceptedPageState extends State<OrderAcceptedPage> {
  CameraPosition? kGooglePlex;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> _polyline = {};
  late List<LatLng> latlng = [];
  String? startPolyline;
  bool isOffline = true;
  bool enteredFirst = false;

  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  OrderHistory? orderDetaials;
  List<ItemsDetails> orderDetails = [];
  String? orderType = "";
  bool enterFirst = false;
  bool isLoading = false;
  dynamic distance;
  dynamic time;
  double? lat;
  double? lng;
  var http = Client();
  StreamSubscription<LocationData>? _locationSubscription;

  //Calculate distance function
  double calculateDistance(lat1, lon1, lat2, lon2, lat3, lon3) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //Calculate time function
  String calculateTime(lat1, lon1, lat2, lon2, lat3, lon3) {
    double kms = calculateDistance(lat1, lon1, lat2, lon2, lat3, lon3);
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
  void initState() {
    super.initState();
    ToastContext().init(context);
    _init();
  }

  _init() async {
    try {
      await WakelockPlus.enable();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lat1 = prefs.getString('lat');
      String? lng1 = prefs.getString('lng');
      lat = double.parse(lat1!);
      lng = double.parse(lng1!);

      await _updateMarker(lat, lng);
    } catch (e) {
      print('MAP Exception - locationScreen.dart - _init():' + e.toString());
    }
  }

  //Update marker function
  Future<bool> _updateMarker(_lat, _lng) async {
    try {
      String startCoordinatesString =
          '(${orderDetaials!.userLat}, ${orderDetaials!.userLng})';

      Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(double.parse('${orderDetaials!.userLat}'),
              double.parse('${orderDetaials!.userLng}')),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

      String startCoordinatesStringStore =
          '(${orderDetaials!.storeLat}, ${orderDetaials!.storeLng})';

      Marker thirdMarker = Marker(
          markerId: MarkerId(startCoordinatesStringStore),
          position: LatLng(double.parse('${orderDetaials!.storeLat}'),
              double.parse('${orderDetaials!.storeLng}')),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

      mapController = await _controller.future;
      markers.add(startMarker);
      markers.add(thirdMarker);

      _polyline.add(Polyline(
        polylineId: PolylineId(startCoordinatesString),
        visible: true,
        width: 5,
        points: latlng,
        color: Colors.blue,
      ));
      return true;
    } catch (e) {
      print('MAP Exception - locationScreen.dart - _updateMarker():' +
          e.toString());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map dataReced = {};
    dataReced = ModalRoute.of(context)?.settings.arguments as Map;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetaials = dataReced['OrderDetail'];
        orderType = dataReced['orderType'];
        orderDetails = dataReced['details'];

        LatLng latLngbBoy = LatLng(double.parse('${orderDetaials!.dboyLat}'),
            double.parse('${orderDetaials!.dboyLng}'));
        kGooglePlex = CameraPosition(
          target: latLngbBoy,
          zoom: 12.0,
        );
        latlng.add(latLngbBoy);

        LatLng latLngUser = LatLng(double.parse('${orderDetaials!.userLat}'),
            double.parse('${orderDetaials!.userLng}'));
        latlng.add(latLngUser);

        LatLng latLngStore = LatLng(double.parse('${orderDetaials!.storeLat}'),
            double.parse('${orderDetaials!.storeLng}'));
        latlng.add(latLngStore);

        _updateMarker(orderDetaials!.dboyLat, orderDetaials!.dboyLng);
        distance = calculateDistance(
                double.parse('${orderDetaials!.dboyLat}'),
                double.parse('${orderDetaials!.dboyLng}'),
                double.parse('${orderDetaials!.userLat}'),
                double.parse('${orderDetaials!.userLng}'),
                double.parse('${orderDetaials!.storeLat}'),
                double.parse('${orderDetaials!.storeLng}'))
            .toStringAsFixed(2);
        time = calculateTime(
            double.parse('${orderDetaials!.dboyLat}'),
            double.parse('${orderDetaials!.dboyLng}'),
            double.parse('${orderDetaials!.userLat}'),
            double.parse('${orderDetaials!.userLng}'),
            double.parse('${orderDetaials!.storeLat}'),
            double.parse('${orderDetaials!.storeLng}'));
        print('$distance');
        print('$time');
      });
      _getLocation(locale!, context);
    }

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppBar(
            leadingWidth: 50,
            centerTitle: false,
            toolbarHeight: 60,
            titleSpacing: 0,
            title: Text(
                'Delivery ID- \n#${orderDetaials!.delivery_unique_code}',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                    fontSize: 14)),
            automaticallyImplyLeading: true,
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
        body: Stack(
          children: [
            Container(
              child: GoogleMap(
                mapType: MapType.normal,
                markers: markers,
                polylines: _polyline,
                initialCameraPosition: kGooglePlex!,
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                compassEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30)),
                    border: Border.all(width: 0.2, color: kPurpleLight)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ListTile(
                      title: Text(
                        locale!.distance!,
                        style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                      ),
                      subtitle: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: '$distance km ',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: 'Poppins',
                                  fontSize: 14)),
                          TextSpan(
                              text: '($time)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: kMainTextColor,
                                  fontFamily: 'Poppins',
                                  fontSize: 14)),
                        ]),
                      ),
                      trailing: buildCircularButton(
                          context, Icons.navigation, locale.direction!,
                          type: 2,
                          url:
                              'https://www.google.com/maps/dir/?api=1&origin=${lat},${lng}&destination=${orderDetaials!.storeLat},${orderDetaials!.storeLng}&travelmode=driving&dir_action=navigate',
                          latS: orderDetaials!.storeLat,
                          lngS: orderDetaials!.storeLng),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 20,
                      ),
                      title: Text(
                        '${orderDetaials!.storeName}',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            fontSize: 16),
                      ),
                      subtitle: Text(
                        '${orderDetaials!.storeAddress}',
                        style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.navigation,
                        color: Colors.green,
                        size: 20,
                      ),
                      title: Text(
                        '${orderDetaials!.userName}',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address:",
                            maxLines: 2,
                            style:
                                TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                          ),
                          Text(
                            '${orderDetaials!.userAddress}',
                            style:
                                TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                          icon: Icon(
                            Icons.call,
                            color: kPurpleLight,
                            size: 18,
                          ),
                          onPressed: () {
                            _launchURL("tel:${orderDetaials!.userPhone}");
                          }),
                    ),
                    Visibility(
                      visible: '${orderDetaials!.orderStatus}' != 'Cancelled',
                      child: ListTile(
                        leading: Icon(
                          Icons.book_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        title: Text(
                          'Delivery Instruction:',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            orderDetaials!.del_partner_instruction != "" &&
                                    orderDetaials!.del_partner_instruction !=
                                        null
                                ? Text(
                                    '${orderDetaials!.del_partner_instruction}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 14),
                                  )
                                : Text(
                                    'N/A',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 14),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    isLoading
                        ? Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Align(
                              heightFactor: 40,
                              widthFactor: 40,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                right: 20, left: 20, bottom: 20),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPurpleLight),
                                  onPressed: () async {
                                    if (!isLoading) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await outForDelivery(
                                          context,
                                          orderDetaials!.cartId,
                                          orderDetaials!.subsciption_id,
                                          lat,
                                          lng,
                                          orderDetaials!.delivery_unique_code);
                                    }
                                  },
                                  child: Text(
                                    "Accept Delivery",
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
          ],
        ),
      ),
    );
  }

  //Get current location function
  void _getLocation(AppLocalizations locale, BuildContext context) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled!) {
        _permissionGranted = await location.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
          _permissionGranted = await location.requestPermission();
          if (_permissionGranted == PermissionStatus.granted) {
            //Comented for removing background location tracking by sahil
            // await _backLocationFetch();
            await _locationFetch();
            getLatLng(context, locale);
            await _updateMarker(lat, lng);
          }
        } else if (_permissionGranted == PermissionStatus.granted ||
            _permissionGranted == PermissionStatus.grantedLimited) {
          //Comented for removing background location tracking by sahil
          // await _backLocationFetch();
          await _locationFetch();
          getLatLng(context, locale);
          await _updateMarker(lat, lng);
        }
      }
    } else {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          print('this one');
          //Comented for removing background location tracking by sahil
          // await _backLocationFetch();
          await _locationFetch();
          getLatLng(context, locale);
          await _updateMarker(lat, lng);
        }
      } else if (_permissionGranted == PermissionStatus.granted ||
          _permissionGranted == PermissionStatus.grantedLimited) {
        print('this one 2');
        //Comented for removing background location tracking by sahil
        // await _backLocationFetch();
        await _locationFetch();
        getLatLng(context, locale);
        await _updateMarker(lat, lng);
      }
    }
  }
  //Comented for removing background location tracking by sahil
  // Future _backLocationFetch() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // await BackgroundLocation.setAndroidNotification(
  //     //   title: 'Background service is running',
  //     //   message: 'Background location in progress',
  //     //   icon: '@mipmap/ic_launcher',
  //     // );
  //     //await BackgroundLocation.setAndroidConfiguration(1000);
  //     await back.BackgroundLocation.startLocationService(distanceFilter: 20);
  //     back.BackgroundLocation.getLocationUpdates((location) async {
  //       await back.BackgroundLocation.setAndroidNotification(
  //         title: 'Background service is running',
  //         message: '${lat.toString()} ${lng.toString()}',
  //         icon: '@mipmap/ic_launcher',
  //       );

  //       lat = location.latitude;
  //       lng = location.longitude;

  //       http.post(
  //         updatelatlng,
  //         body: {
  //           'dboy_id': '${prefs.getInt('db_id')}',
  //           'lat': lat.toString(),
  //           'lng': lng.toString(),
  //         },
  //       ).then((value) {
  //         print("dboy_id: ${prefs.getInt('db_id')}");
  //         print("lat: ${lat.toString()}");
  //         print("lng: ${lng.toString()}");
  //         print('dvd - ${value.body}');
  //         if (value.statusCode == 200) {
  //           print('success');
  //           prefs.setString('lat', lat.toString());
  //           prefs.setString('lng', lng.toString());
  //         }
  //         // setState(() {
  //         //   isLoading = false;
  //         // });
  //       }).catchError((e) {
  //         // setState(() {
  //         //   isLoading = false;
  //         // });
  //         print(e);
  //       });
  //     });
  //   } catch (e) {
  //     print("Exceptioin - accepted_order.dart - _backLocationFetch():" +
  //         e.toString());
  //   }
  // }

  //Location fetch function
  Future _locationFetch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // _locationSubscription =
      //     location.onLocationChanged.listen((LocationData currentLocation) {
      //   print(
      //       "Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}");
      //   lat = currentLocation.latitude;
      //   lng = currentLocation.longitude;
      // });
      print("Started location tracking.");
      print("dboy_id: ${prefs.getInt('db_id')}");
      print("lat: ${lat.toString()}");
      print("lng: ${lng.toString()}");
      http.post(
        updatelatlng,
        body: {
          'dboy_id': '${prefs.getInt('db_id')}',
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      ).then((value) {
        print("dboy_id: ${prefs.getInt('db_id')}");
        print("lat: ${lat.toString()}");
        print("lng: ${lng.toString()}");
        print('dvd - ${value.body}');
        if (value.statusCode == 200) {
          print('success');
          prefs.setString('lat', lat.toString());
          prefs.setString('lng', lng.toString());
        }
      }).catchError((e) {
        print(e);
      });
    } catch (e) {
      print("Exceptioin - home_page.dart - _LocationFetch():" + e.toString());
    }
  }

  //Get current lat lng function
  void getLatLng(BuildContext context, AppLocalizations locale) async {
    _locationData = await location.getLocation();
    if (_locationData != null) {
      double? latt = _locationData!.latitude;
      double? lngt = _locationData!.longitude;
      GoogleMapController controller = await _controller.future;
      setState(() {
        lat = latt;
        lng = lngt;
      });
      kGooglePlex = CameraPosition(
        target: LatLng(
            double.tryParse(orderDetaials!.dboyLat.toString()) ?? 0.0,
            double.tryParse(orderDetaials!.dboyLng.toString()) ?? 0.0),
        zoom: 20,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex!));
    }
  }

  //Order out for delivery API call
  outForDelivery(BuildContext context, dynamic cartid, dynamic subsciptionid,
      dynamic dboy_lat, dynamic dboy_lng, dynamic delivery_unique_code) async {
    setState(() {
      isLoading = true;
    });
    Map data = {
      'data': [
        {
          'cart_id': cartid,
          'subsciption_id': subsciptionid,
          'dboy_lat': dboy_lat,
          'dboy_lng': dboy_lng,
          'delivery_unique_code': delivery_unique_code
        }
      ]
    };
    print(data);
    var url = outForDeliveryUri;
    if (orderType == "zap") {
      url = zapOutForDeliveryUri;
      // print("G1---orderType--->$orderType   &. url---->$url  ");
    }
    var body = json.encode(data);
    print("Body App:----- ${body}");
    print("URL:----- ${url}");
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print("StatusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      var js = jsonDecode(response.body);
      if ('${js['status']}' == '0') {
        setState(() {
          isLoading = false;
        });
        Toast.show("Something went wrong please try again after sometime",
            duration: Toast.lengthShort, gravity: Toast.center);
      } else {
        // Navigator.of(context).pop(true);
        if (orderType == "zap") {
          Navigator.pushNamed(
                              context, PageRoutes.orderRootMapScreen,
                              arguments: {
                                'details': orderDetails,
                                'OrderDetail': orderDetaials,
                                "orderType": orderType
                              }).then((value) {         
                          });
        } else {
          Navigator.pop(context, 'Out For Delivery');
        }
      }
      Toast.show(js['message'],
          duration: Toast.lengthShort, gravity: Toast.center);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Toast.show("Something went wrong please try again after sometime 2",
          duration: Toast.lengthShort, gravity: Toast.center);
    }
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class OrderListAll {
  dynamic cart_id;
  dynamic subsciption_id;
  dynamic dboy_lat;
  dynamic dboy_lng;
  OrderListAll(
      {this.cart_id, this.subsciption_id, this.dboy_lat, this.dboy_lng});

  OrderListAll.fromJson(Map<String, dynamic> json) {
    cart_id = json['cart_id'];
    subsciption_id = json['subsciption_id'];
    dboy_lat = json['dboy_lat'];
    dboy_lng = json['dboy_lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_id'] = this.cart_id;
    data['subsciption_id'] = this.subsciption_id;
    data['dboy_lat'] = this.dboy_lat;
    data['dboy_lng'] = this.dboy_lng;

    return data;
  }
}
