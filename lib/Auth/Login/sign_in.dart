import 'dart:convert';
import 'dart:io';
import 'package:driver/Routes/routes.dart';
import 'package:driver/beanmodel/CountryCodeModel.dart';
import 'package:driver/beanmodel/PrefixCodeList.dart';
import 'package:driver/beanmodel/PrefixModelNew.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:driver/beanmodel/signinmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Theme/colors.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../beanmodel/CountryCodeList.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool showProgress = false;
  int numberLimit = 7;
  var countryCodeController = TextEditingController();
  var _cPhone = TextEditingController();
  var phoneNumberController = TextEditingController();
  AppInfoModel? appInfoModeld;
  int checkValue = -1;
  String appname = '--';
  var passwordController = TextEditingController();
  bool showPassword = true;
  FocusNode _fPhoneCode = FocusNode();
  FocusNode _fPhoneCode1 = FocusNode();
  FocusNode _fPhone = FocusNode();

  String? dropdownValueCountryCode;
  String? dropdownValuePrefixCode;

  List<CountryCodeList> _countryCodeList = [];
  List<PrefixCodeList> _prefixCodeList = [];

  FirebaseMessaging? messaging;
  dynamic token;

  int count = 0;

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  Future<void> getAppInfo() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        hitAppInfo();
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: 'No internet connection',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT);
      print('not connected');
    }
  }

  Future<void> setInit() async {
    _getCountryCode();
    _getPrefixCode();
    hitAsynInit();
    dropdownValueCountryCode = dropdownValueCountryCode;
    dropdownValuePrefixCode = dropdownValuePrefixCode;
  }

  //Get fcm token
  void hitAsynInit() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging!.getToken().then((value) {
      token = value;
    });
  }

  //App info API call
  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showProgress = true;
    });
    var http = Client();
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
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() async {
            appInfoModeld = data1;
            appname = '${appInfoModeld!.appName}';
            countryCodeController.text = '${data1.countryCode}';
            numberLimit = int.parse('${data1.phoneNumberLength}');
            print("Mobile Number Length: ${data1.phoneNumberLength}");
            prefs.setString('app_currency', '${data1.currencySign}');
            prefs.setString('app_referaltext', '${data1.refertext}');
            prefs.setString('numberlimit', '$numberLimit');
            prefs.setString('numberlimit', '$numberLimit');
            prefs.setString('imagebaseurl', '${data1.imageUrl}');
            getImageBaseUrl();
            showProgress = false;
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            String version = packageInfo.version;
            String buildNumber = packageInfo.buildNumber;
            print("G1--->${version}");
            print("G1--->${data1.version}");
            final mversion = version.replaceAll(".", "");
            final apiVersion = data1.version!.replaceAll(".", "");
            print("G111---version>${mversion}");
            print("G111---1>${apiVersion}");
            print("G1112---1>${data1.forcefully_update}");
            print("data1.version-->${data1.version}, version-->${version}");
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
            }
          });
        } else {
          setState(() {
            showProgress = false;
          });
        }
      } else {
        setState(() {
          showProgress = false;
        });
      }
    }).catchError((e) {
      setState(() {
        showProgress = false;
      });
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0, left: 0, right: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      locale!.welcomeTo!,
                      style: TextStyle(
                          fontSize: 34,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.transparent,
                    ),
                    Image.asset(
                      "assets/icon.png",
                      scale: 2.5,
                      height: 150,
                    ),
                    Divider(
                      thickness: 2.0,
                      color: Colors.transparent,
                    ),
                    Text(
                      appname,
                      style: TextStyle(
                          fontSize: 34,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.transparent,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              height: 50,
                              width: 60,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7.0))),
                              margin: EdgeInsets.only(top: 10, left: 5),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 12, 0, 0),
                                child: Container(
                                  height: 50,
                                  child: FormField<String>(
                                    builder: (FormFieldState<String> state) {
                                      return DropdownButton<String>(
                                        focusNode: _fPhoneCode,
                                        key: Key('26'),
                                        hint: Text("971",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        dropdownColor: Colors.white,
                                        iconEnabledColor: kPurpleLight,
                                        value: dropdownValueCountryCode,
                                        isDense: true,
                                        onTap: () {
                                          dropdownValueCountryCode =
                                              dropdownValueCountryCode;
                                          _getCountryCode();
                                          print("S>>>>${_getCountryCode()}");
                                        },
                                        onChanged: (countryCode) {
                                          setState(() {
                                            dropdownValueCountryCode =
                                                countryCode;
                                            _getCountryCode();
                                          });
                                        },
                                        items: _countryCodeList
                                            .map((CountryCodeList countryCode) {
                                          return DropdownMenuItem(
                                            value: countryCode.country_code
                                                .toString(),
                                            child: Text(
                                              countryCode.country_code
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 60,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0))),
                          margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                            child: Container(
                              height: 50,
                              child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return DropdownButton<String>(
                                    key: Key('27'),
                                    focusNode: _fPhoneCode1,
                                    hint: Text("50",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16)),
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: kPurpleLight,
                                    value: dropdownValuePrefixCode,
                                    isDense: true,
                                    onTap: () {
                                      dropdownValuePrefixCode =
                                          dropdownValuePrefixCode;
                                      print("Sahil>>>");
                                      _getPrefixCode();
                                    },
                                    onChanged: (prefixCode) {
                                      setState(() {
                                        dropdownValuePrefixCode = prefixCode;
                                        _getPrefixCode();
                                      });
                                    },
                                    items: _prefixCodeList
                                        .map((PrefixCodeList prefixCode) {
                                      return DropdownMenuItem(
                                        value:
                                            prefixCode.prefix_code.toString(),
                                        child: Text(
                                          prefixCode.prefix_code.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width - 190,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7.0))),
                            margin: EdgeInsets.only(top: 12, right: 20),
                            padding: EdgeInsets.only(left: 10.0),
                            child: TextField(
                              controller: _cPhone,
                              focusNode: _fPhone,
                              autofocus: false,
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(7)
                              ],
                            )),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(7.0))),
                      padding: EdgeInsets.only(left: 10.0),
                      margin: EdgeInsets.only(top: 12, right: 20, left: 20),
                      child: TextField(
                        obscureText: showPassword,
                        obscuringCharacter: "*",
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: locale.password2,
                          hintStyle: TextStyle(
                            color: kHintColor,
                            fontSize: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(PageRoutes.langnew);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              locale.selectPreferredLanguage!,
                              style:
                                  TextStyle(fontSize: 14, color: kPurpleLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              (showProgress)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(
                          thickness: 1.0,
                          color: Colors.transparent,
                        ),
                        Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: CircularProgressIndicator()),
                        Divider(
                          thickness: 1.0,
                          color: Colors.transparent,
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPurpleLight),
                            onPressed: () {
                              if (!showProgress) {
                                setState(() {
                                  showProgress = true;
                                });

                                if (_cPhone.text.isNotEmpty) {
                                  if (_cPhone.text.length >= 7) {
                                    if (passwordController.text.length > 4) {
                                      hitLoginUrl(
                                          '$dropdownValueCountryCode',
                                          '$dropdownValuePrefixCode',
                                          '$_cPhone',
                                          passwordController.text,
                                          context);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Please enter your 6 digit password',
                                          gravity: ToastGravity.CENTER,
                                          toastLength: Toast.LENGTH_SHORT);
                                      setState(() {
                                        showProgress = false;
                                      });
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Please enter your 7 digit mobile number',
                                        gravity: ToastGravity.CENTER,
                                        toastLength: Toast.LENGTH_SHORT);
                                    setState(() {
                                      showProgress = false;
                                    });
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please enter your mobile number',
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_SHORT);
                                  setState(() {
                                    showProgress = false;
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: kWhiteColor,
                                  letterSpacing: 0.6),
                            )),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  //Login API call
  void hitLoginUrl(dynamic country_code, dynamic prefix_code, dynamic userPhone,
      dynamic userPassword, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_countryCodeList.length > 0 && _prefixCodeList.length > 0) {
      if (dropdownValueCountryCode == null) {
        dropdownValueCountryCode = _countryCodeList[0].country_code.toString();
      }
      if (dropdownValuePrefixCode == null) {
        dropdownValuePrefixCode = _prefixCodeList[0].prefix_code.toString();
      }
      String userPhone = dropdownValuePrefixCode! + _cPhone.text;
      print("ConcatePhoneNumber: $userPhone");
      if (token != null) {
        print(token);
        var http = Client();
        print(
            "CountryCode: ${country_code}, Phone: ${userPhone}, 'password': '${userPassword}','device_id': '${token}, 'loginUrl': '${loginUrl}");

        http.post(loginUrl, body: {
          'country_code': '$country_code',
          'phone': '$userPhone',
          'password': '$userPassword',
          'device_id': '$token',
        }).then((value) {
          print('sign - ${value.body}');
          if (value.statusCode == 200) {
            DeliveryBoyLogin dbLogin =
                DeliveryBoyLogin.fromJson(jsonDecode(value.body));

            if ('${dbLogin.status}' == '1') {
              prefs.setInt('db_id', int.parse('${dbLogin.data!.dboyId}'));
              prefs.setString('boy_name', '${dbLogin.data!.boyName}');
              prefs.setString('boy_phone', '${dbLogin.data!.boyPhone}');
              prefs.setString('boy_city', '${dbLogin.data!.boyCity}');
              prefs.setString('password', '${dbLogin.data!.password}');
              prefs.setString('boy_loc', '${dbLogin.data!.boyLoc}');
              prefs.setString('lat', '${dbLogin.data!.lat}');
              prefs.setString('lng', '${dbLogin.data!.lng}');
              prefs.setString('status', '${dbLogin.data!.status}');
              prefs.setString('added_by', '${dbLogin.data!.addedBy}');
              prefs.setString('ad_dboy_id', '${dbLogin.data!.dboyId}');
              prefs.setString('country_code', '${dbLogin.data!.country_code}');
              prefs.setString('prefix_code', '${dbLogin.data!.prefix_code}');
              prefs.setBool('islogin', true);
              Navigator.pushNamedAndRemoveUntil(
                  context, PageRoutes.homePage, (route) => false);
            } else {
              var msg = dbLogin.message;
              prefs.setBool('islogin', false);
              Fluttertoast.showToast(
                  msg: msg,
                  gravity: ToastGravity.CENTER,
                  toastLength: Toast.LENGTH_SHORT);
              setState(() {
                showProgress = false;
              });
            }
          } else {
            prefs.setBool('islogin', false);
          }

          setState(() {
            showProgress = false;
          });
        }).catchError((e) {
          prefs.setBool('islogin', false);
          setState(() {
            showProgress = false;
          });
          print(e);
        });
      } else {
        print("Else1111");
        if (count == 0) {
          count = 1;
          messaging!.getToken().then((value) {
            setState(() {
              token = value;
              hitLoginUrl(
                  country_code, prefix_code, userPhone, userPassword, context);
            });
          });
        } else {
          print("Else2222");
          setState(() {
            showProgress = false;
          });
        }
      }
    }
  }

  //Get country code API call
  _getCountryCode() async {
    setState(() {});
    var url = countryCodeUri;
    print('login url --->   - ${url}');
    var http = Client();
    http.post(url).then((value) {
      print('resp - ${value.body}');

      CountryModelNew data1 = CountryModelNew.fromJson(jsonDecode(value.body));

      print('sahil ${data1.toString()}');
      if (value.statusCode == 200) {
        print(' ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          print('S111>>>${data1.toString()}');
          _countryCodeList = data1.data!;
          print('CountryModelList${_countryCodeList.length}');
          setState(() {
            dropdownValueCountryCode = dropdownValueCountryCode;
          });
        }
      }
    }).catchError((e) {});
  }

  //Get prefix code API call
  _getPrefixCode() async {
    setState(() {});
    var url = prefixCodeUri;
    print('login url --->   - ${url}');
    var http = Client();
    http.post(url).then((value) {
      print('resp - ${value.body}');

      PrefixModelNew data2 = PrefixModelNew.fromJson(jsonDecode(value.body));

      print('sahil ${data2.toString()}');
      if (value.statusCode == 200) {
        print(' ${data2.toString()}');
        if (data2.status == "1" || data2.status == 1) {
          print('S111>>>${data2.toString()}');
          _prefixCodeList = data2.data!;
          print('PrefixModelList${_prefixCodeList.length}');
          setState(() {
            dropdownValuePrefixCode = dropdownValuePrefixCode;
          });
        }
      }
    }).catchError((e) {});
  }
}
