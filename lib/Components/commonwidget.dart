import 'dart:io';

import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildCircularButton(
  BuildContext context,
  IconData icon,
  String text, {
  List<ItemsDetails>? details,
  String? url,
  int type = 0,
  dynamic latS = 0.0,
  dynamic lngS = 0.0,
}) {
  return GestureDetector(
    onTap: () {
      if (type == 1) {
        Navigator.pushNamed(context, PageRoutes.iteminfo,
            arguments: {'details': details});
      } else if (type == 2) {
        print(url);
        _getDirection(url, latS, lngS);
      }
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
              icon,
              size: 18,
              color: kWhiteColor,
            ),
          ),
          Text(
            text,
            style: TextStyle(color: kWhiteColor, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}

_getDirection(url, lat, lon) async {
  // if (Platform.isIOS) {

  //   String appleUrl =
  //       'https://maps.apple.com/?saddr=&daddr=$lat,$lon&directionsmode=driving';

  //   if (await canLaunch(appleUrl)) {
  //     await launch(appleUrl);
  //   } else {
  //     if (await canLaunch(url)) {
  //       await launch(url);
  //     } else {
  //       throw 'Could not open the map.';
  //     }
  //   }
  // } else {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  // lat = 18.5285;
  // lon = 73.8744;
  final appleUrl = Uri.parse(
    'https://maps.apple.com/?daddr=$lat,$lon&dirflg=d',
  );

  // Construct Google Maps URL (Web fallback)
  final googleUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving&dir_action=navigate',
  );
  if (Platform.isIOS) {
    // Try launching Apple Maps first
    if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch any map application.';
    }
  } else {
    await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
  }
}
