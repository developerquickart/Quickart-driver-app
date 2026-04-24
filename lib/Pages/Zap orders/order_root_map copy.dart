import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class OrderRootMapScreen extends StatefulWidget {
  @override
  _OrderRootMapScreenState createState() => _OrderRootMapScreenState();
}

class _OrderRootMapScreenState extends State<OrderRootMapScreen> {
  GoogleMapController? mapController;

  // 📍 Fixed Locations
  LatLng storeLocation = const LatLng(18.600129588138238, 73.76332479603619);
  LatLng customerLocation = const LatLng(18.601224772022967, 73.7630449720916);
  List<LatLng> routePoints = []; // travelled path
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  Position? lastPosition;
  DateTime? lastTime;
  StreamSubscription<Position>? positionStream;

  bool isReached = false;
  bool enterfirst = true;
  LatLng? lastRoutePosition;
  OrderHistory? orderDetaials;
  List<ItemsDetails> orderDetails = [];
  String? orderType = "";
  BitmapDescriptor? storeIcon;
  BitmapDescriptor? customerIcon;
  BitmapDescriptor? driverIcon;
  @override
  void initState() {
    super.initState();
    loadmarker();
    // init();
    loadRouteData();
  }

  Future<void> init() async {
    await requestPermission();
    await restoreRoute();
    addMarkers();

    await getRoute(storeLocation, customerLocation);
    moveCameraToBounds();
    startTracking();
  }

  loadmarker() async {
    await loadCustomMarkers();
  }

  Future<void> loadCustomMarkers() async {
    storeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/store.png',
    );

    customerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/customer.png',
    );

    driverIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/driver.png',
    );
  }

  void loadRouteData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final receivedData = ModalRoute.of(context)?.settings.arguments as Map;

      setState(() {
        orderDetaials = receivedData['OrderDetail'];
        orderDetails = receivedData['details'];
        orderType = receivedData['orderType'];

        storeLocation = LatLng(
          double.parse(orderDetaials!.storeLat!),
          double.parse(orderDetaials!.storeLng!),
        );

        customerLocation = LatLng(
          double.parse(orderDetaials!.userLat!),
          double.parse(orderDetaials!.userLng!),
        );
        print(
            "G1------>: ${storeLocation.toString()}, ${customerLocation.toString()}");
      });

      init();
      resetMapAndRoute(); // 👈 VERY IMPORTANT
    });
  }

  Future<void> resetMapAndRoute() async {
    print("RESET MAP");

    routePoints.clear();
    polylines.clear();
    markers.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("route");

    addMarkers(); // add store + customer again

    lastRoutePosition = storeLocation;

    await getRoute(storeLocation, customerLocation);

    setState(() {});
  }

  void moveCameraToBounds() {
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            storeLocation.latitude < customerLocation.latitude
                ? storeLocation.latitude
                : customerLocation.latitude,
            storeLocation.longitude < customerLocation.longitude
                ? storeLocation.longitude
                : customerLocation.longitude,
          ),
          northeast: LatLng(
            storeLocation.latitude > customerLocation.latitude
                ? storeLocation.latitude
                : customerLocation.latitude,
            storeLocation.longitude > customerLocation.longitude
                ? storeLocation.longitude
                : customerLocation.longitude,
          ),
        ),
        100,
      ),
    );
  }

  //  Permission
  Future<void> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  //  Start Tracking
  Future<void> startTracking() async {
    if (isReached) {
      isReached = false;
      routePoints.clear();
      updatePolyline();
      // Clear saved route
      SharedPreferences.getInstance().then((prefs) => prefs.remove("route"));
      // Set new route and polyline
      polylines.clear();
      lastRoutePosition = storeLocation;
      await getRoute(storeLocation, customerLocation);
    }
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      handleLocation(position);
    });
  }

  Future<void> stopTracking() async {
    positionStream?.cancel();
    positionStream = null;

    // Clear route data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("route");

    updatePolyline();
    print("Tracking stopped and route data cleared");
  }

  Future<void> markAsReached() async {
    if (!isReached) {
      isReached = true;
      await stopTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as reached customer location!")),
      );
    }
  }

  Future<void> handleLocation(Position position) async {
    DateTime now = DateTime.now();

    // First time
    if (lastTime == null) {
      await processLocation(position);
      return;
    }

    int timeDiff = now.difference(lastTime!).inSeconds;

    //  Only time check (20 sec)
    if (timeDiff >= 30) {
      await processLocation(position);
    } else {
      print("Skipped -> only $timeDiff sec passed");
    }
  }

  //  Process Location
  Future<void> processLocation(Position position) async {
    lastPosition = position;
    lastTime = DateTime.now();

    LatLng newPoint = LatLng(position.latitude, position.longitude);

    routePoints.add(newPoint);

    // Calculate bearing for arrow direction
    double bearing = 0.0;
    if (lastPosition != null && routePoints.length > 1) {
      LatLng prevPoint = routePoints[routePoints.length - 2];
      bearing = Geolocator.bearingBetween(
        prevPoint.latitude,
        prevPoint.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    // 🔥 Live Marker with arrow rotation
    // markers.removeWhere((m) => m.markerId.value == "live");
    // markers.add(
    //   Marker(
    //     markerId: const MarkerId("live"),
    //     position: newPoint,
    //     infoWindow: const InfoWindow(title: "Driver"),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    //     rotation: bearing,
    //   ),
    // );
    markers.removeWhere((m) => m.markerId.value == "live");

    markers.add(
      Marker(
        markerId: const MarkerId("live"),
        position: newPoint,
        icon: driverIcon ?? BitmapDescriptor.defaultMarker,
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 2, 
      ),
    );

    updatePolyline();
    await saveRoute();
    await sendToApi(position);

    moveCamera(newPoint);

    setState(() {});

    // Update route if moved >5m from last route position
    if (lastRoutePosition != null &&
        Geolocator.distanceBetween(
                lastRoutePosition!.latitude,
                lastRoutePosition!.longitude,
                position.latitude,
                position.longitude) >
            5) {
      lastRoutePosition = LatLng(position.latitude, position.longitude);
      await getRoute(lastRoutePosition!, customerLocation);
    }

    // Check if reached customer
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      customerLocation.latitude,
      customerLocation.longitude,
    );
    if (distance < 50 && !isReached) {
      isReached = true;
      stopTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reached customer location!")),
      );
    }
  }

  //  Draw Travel Path
  void updatePolyline() {
    polylines.removeWhere((p) => p.polylineId.value == "travelled");

    polylines.add(
      Polyline(
        polylineId: const PolylineId("travelled"),
        points: routePoints,
        width: 10,
        color: Colors.blue,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
  }

  //  Move Camera
  void moveCamera(LatLng latLng) {
    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  //  Store + Customer Markers
  void addMarkers1() {
    markers.clear(); // 🔥 important

    markers.add(
      Marker(
        markerId: const MarkerId("store"),
        position: storeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("customer"),
        position: customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void addMarkers() {
    markers.clear();

    markers.add(
      Marker(
        markerId: const MarkerId("store"),
        position: storeLocation,
        icon: storeIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId("customer"),
        position: customerLocation,
        icon: customerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );
  }
  // String apiKey = "AIzaSyADPEHze6hgRTG83JXfEJ6owhtNTmJJWwg";

  Future<void> getRoute(LatLng origin, LatLng destination) async {
    print(
        "Getting route from---- ${origin.toString()} to ${destination.toString()}");
    String apiKey = "AIzaSyADPEHze6hgRTG83JXfEJ6owhtNTmJJWwg";

    final response = await http.post(
      Uri.parse("https://routes.googleapis.com/directions/v2:computeRoutes"),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,
        "X-Goog-FieldMask": "routes.polyline.encodedPolyline"
      },
      body: jsonEncode({
        "origin": {
          "location": {
            "latLng": {
              "latitude": origin.latitude,
              "longitude": origin.longitude
            }
          }
        },
        "destination": {
          "location": {
            "latLng": {
              "latitude": destination.latitude,
              "longitude": destination.longitude
            }
          }
        },
        "travelMode": "DRIVE"
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        print("❌ No routes found");
        return;
      }

      String encoded = data['routes'][0]['polyline']['encodedPolyline'];

      List<LatLng> points = decodePolyline(encoded);

      print("POINTS COUNT: ${points.length}");

      // ✅ FIX: remove only road
      polylines.removeWhere((p) => p.polylineId.value == "road");

      polylines.add(
        Polyline(
          polylineId: const PolylineId("road"),
          points: points,
          width: 6,
          color: Colors.blue,
        ),
      );

      setState(() {});
    } else {
      print("❌ API ERROR: ${response.body}");
    }
  }

  // Decode Polyline
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }

  //  Save Route
  Future<void> saveRoute() async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, double>> data = routePoints
        .map((e) => {"lat": e.latitude, "lng": e.longitude})
        .toList();

    prefs.setString("route", jsonEncode(data));
  }

  //  Restore Route
  Future<void> restoreRoute() async {
    final prefs = await SharedPreferences.getInstance();

    String? route = prefs.getString("route");

    if (route != null) {
      List list = jsonDecode(route);

      routePoints =
          list.map<LatLng>((e) => LatLng(e['lat'], e['lng'])).toList();

      updatePolyline();
    }
  }

  //  API Call
  Future<void> sendToApi(Position position) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        print(
            "Started location tracking------> dboy_id: ${prefs.getInt('db_id')}  &-- lat: ${position.longitude} &-- lat: ${position.latitude}");
        http.post(
          zapUpdatelatlng,
          body: {
            'dboy_id': '${prefs.getInt('db_id')}',
            'lat': position.latitude.toString(),
            'lng': position.longitude.toString(),
          },
        ).then((value) {
          print(
              'dvd - ${value.body}      &.   lat: ${position.latitude.toString()}, lng: ${position.longitude.toString()}  ');
          if (value.statusCode == 200) {}
        }).catchError((e) {
          print(e);
        });
      }
    } on SocketException catch (_) {
      Toast.show("No internet connection", duration: 5, gravity: Toast.center);
      print('not connected');
    }
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Live Tracking",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, color: kWhiteColor),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: storeLocation,
                zoom: 18,
              ),
              polylines: polylines,
              markers: markers,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
            Positioned(
              bottom: 80,
              left: 50,
              right: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await markAsReached();
                  Navigator.pushNamed(context, PageRoutes.productListScreen,
                      arguments: {
                        'details': orderDetails,
                        'OrderDetail': orderDetaials,
                        "orderType": "zap"
                      }).then((value) {});
                },
                child: const Text("Reached Location"),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 50,
              right: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (positionStream == null) {
                    await startTracking();
                  } else {
                    await stopTracking();
                  }
                },
                child: Text(positionStream == null
                    ? "Start Tracking"
                    : "Stop Tracking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
