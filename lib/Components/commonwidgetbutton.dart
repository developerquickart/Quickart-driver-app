import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildCommonCircularButton(
  BuildContext context,
  IconData icon,
  String text, {
  List<ItemsDetails>? details,
  String? url,
  int type = 0,
}) {
  return GestureDetector(
    onTap: () {
      print('Order--->${details.toString()}');
      if (type == 1) {
        Navigator.pushNamed(context, PageRoutes.iteminfo,
            arguments: {'details': details});
      } else if (type == 2) {
        print(url);
        _getDirection(url);
      }
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
          color: kPurpleLight,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: kWhiteColor)),
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
            style: TextStyle(
              color: kWhiteColor,
            ),
          ),
        ],
      ),
    ),
  );
}

_getDirection(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
