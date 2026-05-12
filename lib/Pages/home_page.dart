import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/Zap%20orders/zap_todayorder.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Pages/Zap%20orders/order_root_map.dart';
import 'package:driver/Pages/orderpage/todayorder.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:driver/beanmodel/driverstatus.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:driver/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'notification_list.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const LatLng _center = const LatLng(25.2048, 55.2708);
  CameraPosition kGooglePlex = CameraPosition(
    target: _center,
    zoom: 12,
  );

  List<LatLng>? latlng;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  dynamic lat;
  dynamic lng;
  bool isOffline = true;
  bool enteredFirst = false;
  bool _isInForeGround = true;
  var http = Client();
  int totalOrder = 0;
  double totalincentives = 0.0;
  dynamic apCurency;
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  var isRun = false;
  String todayOrder = "Today's Order";
  OrderHistory? orderDetails;
  StreamSubscription<LocationData>? _locationSubscription;

  //Update driver status online/offline API call
  void updateStatus(int status) async {
    var locale = AppLocalizations.of(context);
    setState(() {
      isRun = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('dboy_id: ${prefs.getInt('db_id')}');
    print('status: ${status}');
    http.post(updateStatusUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'status': '$status'
    }).then((value) {
      print('dboy_id: ${prefs.getInt('db_id')}');
      print('status: ${status}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        prefs.setInt('online_status', status);
        if (status == 0) {
          setState(() {
            isOffline = true;
            isRun = false;
            // stopTracking();
          });
        } else {
          setState(() {
            isOffline = false;
            isRun = false;
            // _getLocation(locale!, context);
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  //Update fcm token API call
  void updateFCMToken() async {
    var http = Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(fcmUpdate);
    http.post(fcmUpdate, body: {
      'user_id': '${prefs.getInt('db_id')}',
      "device_id": await FirebaseMessaging.instance.getToken(),
      "type": "driver"
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            // print("G1--->FCM updated");
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> getAppInfo() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        hitAppInfo();
      }
    } on SocketException catch (_) {
      Toast.show("No internet connection", duration: 5, gravity: Toast.center);
      print('not connected');
    }
  }

  Future<void> setInit() async {
    getCurrentLocation();
    _init();
    WidgetsBinding.instance.addObserver(this);
    setFirebase();
    getDrierStatus();
  }

  //Get current location function
  Future<void> getCurrentLocation() async {
    Geolocator.getCurrentPosition(forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        print(
            "G1---1--latitude-->${position.latitude} ----longitude-->${position.longitude}");
        dBoyLat = position.latitude;
        dBoyLng = position.longitude;
      });
    }).catchError((e) {
      print(e);
    });
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeGround = state == AppLifecycleState.resumed;
  }

  //Set firebase and notifications function
  void setFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('FIR -> $e');
    }
    messaging = FirebaseMessaging.instance;
    iosPermission(messaging);
    messaging.getToken().then((value) {
      debugPrint('token: $value');
    });

    messaging.getInitialMessage().then((RemoteMessage? message) {
      print('message done');
      if (message != null) {
        RemoteNotification? notification = message.notification;
        if (notification != null && _isInForeGround) {}
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('message done');
      if (message != null) {
        RemoteNotification notification = message.notification!;
        if (notification != null && _isInForeGround) {}
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationListPage(),
        ),
      );
    });
  }

  //App info API call
  void hitAppInfo() async {
    var http = Client();

    var platform;
    if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "android";
    }
    print(appInfoUri);
    print(
        "'user_id': '', 'store_id': '', 'platform': ${platform}, 'app_name': 'delivery'");
    http.post(appInfoUri, body: {
      'user_id': '',
      'store_id': '',
      'platform': platform,
      'app_name': 'delivery'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('app_currency', '${data1.currencySign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            prefs.setString('numberlimit', '${data1.phoneNumberLength}');
            prefs.setString('imagebaseurl', '${data1.imageUrl}');
            getImageBaseUrl();
            updateFCMToken();
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            String version = packageInfo.version;
            final mversion = version.replaceAll(".", "");
            final apiVersion = data1.version!.replaceAll(".", "");
            print("version: ${version}");
            print("apiVersion-->$apiVersion");
            print("forecefully_update-->${data1.forcefully_update}");
            print(
                "data1.version-->${data1.version}, version-->${version}");

            if (data1.version == null || data1.version == version) {
              setInit();
              print(
                  "data1.version22-->${data1.version}, mversion-->${mversion}, apiVersion-->${apiVersion}");
            } else {
              // String? versionPop = prefs.getString('versionPop');
              print(
                  "data1.version11-->${data1.version}, mversion-->${mversion}, apiVersion-->${apiVersion}");

              // if (versionPop == 'show') {
              //   prefs.setString('versionPop', 'no');
              if (data1.forcefully_update == 1 && data1.version != version) {
                _updateForcefullyDialog(
                    "New update available.\nPlease download the updated app.",
                    data1.app_link!);
              } else {
                _updateDialog(
                    "New update available.\nPlease download the updated app.",
                    data1.app_link!);
              }
              // } else {
              //   setInit();
              // }
            }
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  _updateDialog(String msg, String appLink) async {
    try {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: Theme.of(context).copyWith(
                  dialogTheme: DialogThemeData(backgroundColor: Colors.red)),
              child: CupertinoAlertDialog(
                title: Text(
                  'QuicKart',
                ),
                content: Text(
                  '${msg}',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('Skip'),
                    onPressed: () async {
                      Navigator.pop(context);
                      setInit();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text('Update'),
                    onPressed: () async {
                      Navigator.pop(context);
                      print(appLink);
                      var url = "${appLink}";
                      if (await canLaunch(url))
                        await launch(url);
                      else
                        // can't launch url, there is some error
                        throw "Could not launch $url";
                    },
                  ),
                ],
              ),
            );
          });
    } catch (e) {
      print('Exception - app_menu_screen.dart - exitAppDialog(): ' +
          e.toString());
    }
  }

  _updateForcefullyDialog(String msg, String appLink) async {
    try {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(
                  dialogTheme: DialogThemeData(backgroundColor: Colors.white)),
              child: CupertinoAlertDialog(
                title: Text(
                  'QuicKart',
                ),
                content: Text(
                  '${msg}',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('Update'),
                    onPressed: () async {
                      print(appLink);
                      var url = "${appLink}";
                      if (await canLaunch(url))
                        await launch(url);
                      else
                        // can't launch url, there is some error
                        throw "Could not launch $url";
                    },
                  ),
                ],
              ),
            );
          });
    } catch (e) {
      print('Exception - app_menu_screen.dart - exitAppDialog(): ' +
          e.toString());
    }
  }

  //Get driver status API call
  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRun = true;
      apCurency = prefs.getString('app_currency');
    });
    if (prefs.containsKey('online_status')) {
      if (prefs.getInt('online_status') == 1) {
        setState(() {
          isOffline = false;
        });
      } else {
        setState(() {
          isOffline = true;
        });
      }
    } else {
      setState(() {
        isOffline = true;
      });
    }
    print('dboy_id: ${prefs.getInt('db_id')}');
    http.post(driverStatusUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      print('dboy_id: ${prefs.getInt('db_id')}');
      print('driverStatusUri: $driverStatusUri');
      if (value.statusCode == 200) {
        DriverStatus dstatus = DriverStatus.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          int onoff = int.parse('${dstatus.onlineStatus}');
          prefs.setInt('online_status', onoff);
          if (onoff == 1) {
            setState(() {
              isOffline = false;
            });
          } else {
            setState(() {
              isOffline = true;
            });
          }
          totalOrder = int.parse('${dstatus.totalOrders}');
          totalincentives = double.parse('${dstatus.totalIncentive}');
        }
      }
      setState(() {
        isRun = false;
      });
    }).catchError((e) {
      setState(() {
        isRun = false;
      });
      print(e);
    });
  }

  //Update marker function
  Future<bool> _updateMarker(_lat, _lng) async {
    try {
      String startCoordinatesString = '$_lat,$_lng';

      Marker startMarker = Marker(
          markerId: MarkerId(startCoordinatesString),
          position: LatLng(_lat, _lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

      mapController = await _controller.future;
      markers.add(startMarker);

      return true;
    } catch (e) {
      print('MAP Exception - locationScreen.dart - _updateMarker():' +
          e.toString());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: kPurpleLight));
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    if (!enteredFirst) {
      setState(() {
        enteredFirst = true;
      });
      _getLocation(locale!, context);
    }
    return SafeArea(
      top: true,
      child: Scaffold(
        drawer: AccountDrawer(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: AppBar(
              backgroundColor: kPurpleLight,
              title: Text(
                isOffline
                    ? locale!.youReOffline!.toUpperCase()
                    : locale!.youReOnline!.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: kWhiteColor),
              ),
              actions: <Widget>[
                isRun
                    ? CupertinoActivityIndicator(
                        radius: 15,
                      )
                    : Container(),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        if (isOffline) {
                          updateStatus(1);
                        } else {
                          updateStatus(0);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        width: 104,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isOffline
                              ? locale.goOnline!.toUpperCase()
                              : locale.goOffline!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: theme.scaffoldBackgroundColor,
                              fontSize: 14),
                        ),
                        decoration: BoxDecoration(
                          color: isOffline
                              ? theme.primaryColor
                              : Color(0xffff452c),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                mapType: MapType.normal,
                markers: markers,
                initialCameraPosition: kGooglePlex,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                compassEnabled: false,
                mapToolbarEnabled: false,
                buildingsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
              ),
            ),
            Positioned(
              bottom: 15,
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TodayOrder();
                      })).then((value) {
                        setState(() {
                          getDrierStatus();
                        });
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 170,
                      padding: EdgeInsets.symmetric(
                          horizontal: totalOrder > 10 ? 10 : 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: kPurpleLight,
                        borderRadius:
                            BorderRadius.circular(12), // ✅ radius added
                      ),
                      child: Stack(
                        children: [
                          totalOrder != 0
                              ? Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      totalOrder <= 99
                                          ? '${totalOrder}'
                                          : "99+",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : new SizedBox(),
                          Center(
                            child: Container(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                todayOrder,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: kWhiteColor,
                                    letterSpacing: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // GestureDetector(
                  //   onTap: () async{
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) {
                  //       return ZapTodayOrder();
                  //     })).then((value) {
                  //       setState(() {
                  //         getDrierStatus();
                  //       });
                  //     });

                  //   },
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.green,
                  //       borderRadius: BorderRadius.circular(12), // ✅ radius added
                  //     ),
                  //     width: 170,
                  //     padding: EdgeInsets.symmetric(
                  //         horizontal:  10 , vertical: 12),
                  //     child: Center(
                  //       child: Container(
                  //         padding: EdgeInsets.only(top: 5,bottom: 5),
                  //         child: Text(
                  //           'Go Orders',
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //               fontSize: 16,
                  //               color: kWhiteColor,
                  //               letterSpacing: 0.6),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
               
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Get location function
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
  //       print("dboy_id: ${prefs.getInt('db_id')}");
  //       print("lat: ${lat.toString()}");
  //       print("lng: ${lng.toString()}");
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

  //Fetch location function
  Future _locationFetch() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // _locationSubscription =
      //     location.onLocationChanged.listen((LocationData currentLocation) {
      //   print(
      //       "Latitude: ${currentLocation.latitude}, Longitude--: ${currentLocation.longitude}");
      //   lat = currentLocation.latitude;
      //   lng = currentLocation.longitude;
      // });
      print(
          "Started location tracking.------> dboy_id: ${prefs.getInt('db_id')}  &-- lat: ${lat.toString()} &-- lat: ${lat.toString()}");
      http.post(
        updatelatlng,
        body: {
          'dboy_id': '${prefs.getInt('db_id')}',
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      ).then((value) {
        print('dvd - ${value.body}');
        if (value.statusCode == 200) {
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
        target: LatLng(lat, lng),
        zoom: 12,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future selectNotification(String payload) async {}

  void iosPermission(FirebaseMessaging firebaseMessaging) {
    if (Platform.isIOS) {
      firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}

Column buildRowChild(ThemeData theme, String text1, String text2,
    {CrossAxisAlignment? alignment}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: alignment ?? CrossAxisAlignment.center,
    children: <Widget>[
      Row(
        children: [
          Text(
            text2,
            style: TextStyle(color: kMainTextColor, fontSize: 16),
          ),
          Text(
            '$text1',
            style: TextStyle(color: kMainTextColor, fontSize: 16),
          ),
          SizedBox(
            width: 9.0,
          ),
        ],
      ),
    ],
  );
}
