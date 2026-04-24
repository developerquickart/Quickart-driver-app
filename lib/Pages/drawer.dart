import 'dart:convert';
import 'dart:io';
import 'package:driver/Auth/Login/sign_in.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class AccountDrawer extends StatelessWidget {
  AccountDrawer();

  String? dropdownValueCountryCode;
  String? dropdownValuePrefixCode;

  Future getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('boy_name');
  }

  //App info API call
  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    print('user_id - "" ');
    print('appInfoUrl: ${appInfoUri}');
    var platform;
    if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "android";
    }
    http.post(appInfoUri, body: {
      'user_id': '',
      'store_id': '',
      'platform': platform,
      'app_name': 'delivery'
    }).then((value) {
      print('user_id - "" ');
      print('appInfoUrl: ${appInfoUri}');
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          prefs.setString('app_currency', '${data1.currencySign}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setString('numberlimit', '${data1.phoneNumberLength}');
          prefs.setString('imagebaseurl', '${data1.imageUrl}');
          getImageBaseUrl();
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  //Deactivate account API call
  void deactivatedAccountHit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    print('driverDeactivate: ${driverDeactivate}');
    http.post(driverDeactivate, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      "activate_deactivate_status": "deactivate",
      "deactivate_by": "Driver",
    }).then((value) async {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          Toast.show(data1.message, duration: 4, gravity: Toast.center);
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.clear().then((value) {
            Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => SignIn()),
                (route) => false);
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Drawer(
      child: Container(
        color: kPurpleLight,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      hitAppInfo();
                    }
                    return Text(
                        (snapshot.hasData != null)
                            ? locale!.hey! + ', ' + '${snapshot.data}'
                            : '${locale!.hey!}\, User',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20));
                  },
                  future: getSharedValue(),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, PageRoutes.homePage, (r) => false);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.home_rounded,
                              color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale!.home!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, PageRoutes.editProfilePage);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.account_box, color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.myAccount!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, PageRoutes.insightPage);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.insert_chart,
                              color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.insight!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, PageRoutes.notificationList);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active,
                              color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.notifications!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(context, PageRoutes.aboutus);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.view_list, color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.aboutUs!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(context, PageRoutes.tnc);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings_rounded,
                              color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.tnc!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, PageRoutes.contactUs);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat, color: kWhiteColor, size: 24),
                          SizedBox(width: 15),
                          Text(
                            locale.helpCenter!.toUpperCase(),
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                letterSpacing: 0.8,
                                fontFamily: 'Poppins'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  LogoutTile(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _deactivatedAlert(
      String msg, bool showCancelBtn, BuildContext context) async {
    try {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return Theme(
              data: ThemeData(dialogTheme: DialogThemeData(backgroundColor: Colors.white)),
              child: CupertinoAlertDialog(
                title: Text(
                  'QuicKart',
                ),
                content: Text(
                  msg,
                ),
                actions: <Widget>[
                  Visibility(
                    visible: showCancelBtn,
                    child: CupertinoDialogAction(
                      child: Text(
                        'Cancel',
                      ),
                      onPressed: () {
                        return Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  CupertinoDialogAction(
                    child: Text('Ok'),
                    onPressed: () async {
                      deactivatedAccountHit(context);
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

  ListTile buildListTile(
      BuildContext context, IconData icon, String text, Function onTap) {
    var theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: kWhiteColor),
      title: Text(text.toUpperCase(),
          style:
              TextStyle(fontSize: 17, letterSpacing: 0.8, color: kWhiteColor)),
      onTap: onTap(),
    );
  }
}

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    var theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.exit_to_app,
        color: kWhiteColor,
        size: 24,
      ),
      title: Text(locale!.logout!.toUpperCase(),
          style:
              TextStyle(fontSize: 16, letterSpacing: 0.8, color: kWhiteColor)),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Logging out',
                  style: TextStyle(color: kPurpleLight),
                ),
                content: Text(
                  'Are you sure?',
                  style: TextStyle(fontSize: 16),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      shadowColor:
                          WidgetStateProperty.all(Colors.transparent),
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                      foregroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      'No',
                      style: TextStyle(color: kPurpleLight, fontSize: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                        shadowColor:
                            WidgetStateProperty.all(Colors.transparent),
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(color: kPurpleLight, fontSize: 16),
                      ),
                      onPressed: () async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.clear().then((value) {
                          Navigator.pushAndRemoveUntil<dynamic>(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => SignIn()),
                              (route) => false);
                        });
                      })
                ],
              );
            });
      },
    );
  }
}
