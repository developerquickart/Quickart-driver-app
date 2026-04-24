import 'dart:convert';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/Theme/style.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController numberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  var userName;
  var userNumber;
  int numberLimit = 1;
  bool? isLogin = false;

  bool isLoading = false;

  var http = Client();

  @override
  void initState() {
    getProfileDetails();
    super.initState();
  }

  //Get profile details from shared preference
  void getProfileDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isLogin = preferences.getBool('islogin');
      userName = preferences.getString('boy_name');
      userNumber = preferences.getString('boy_phone');
      numberLimit = int.parse('${preferences.getString('numberlimit')}');
      nameC.text = '$userName';
      numberC.text = '$userNumber';
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        drawer: AccountDrawer(),
        appBar: AppBar(
          foregroundColor: kWhiteColor,
          title: Text(
            locale!.contactUs!,
            style: TextStyle(color: kWhiteColor, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/icon.png',
                  scale: 2.5,
                  height: 280,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          locale.callBackReq2!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                  EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 15,
                                      bottom: 15)),
                              shadowColor:
                                  WidgetStateProperty.all(kPurpleLight),
                              overlayColor:
                                  WidgetStateProperty.all(kPurpleLight),
                              backgroundColor:
                                  WidgetStateProperty.all(kPurpleLight),
                              foregroundColor:
                                  WidgetStateProperty.all(kPurpleLight),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                          onPressed: () {
                            if (!isLoading) {
                              setState(() {
                                isLoading = true;
                              });
                              sendCallBackRequest(context);
                            }
                          },
                          child: Text(
                            locale.callBackReq1!,
                            style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
                  child: Text(
                    locale.or!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                  child: Text(
                    locale
                        .letUsKnowYourFeedbackQueriesIssueRegardingAppFeatures!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  ),
                ),
                Divider(
                  thickness: 3.5,
                  color: Colors.transparent,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(locale.fullName!,
                          style: TextStyle(
                              color: disabledColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        autofocus: false,
                        controller: nameC,
                        readOnly: false,
                        keyboardType: TextInputType.name,
                        maxLines: 1,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: locale.fullName,
                            counterText: '',
                            hintStyle: TextStyle(fontSize: 16)),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(locale.phoneNumber!,
                          style: TextStyle(
                              color: disabledColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        autofocus: false,
                        controller: numberC,
                        maxLength: numberLimit,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: locale.phoneNumber,
                            counterText: '',
                            hintStyle: TextStyle(fontSize: 16)),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text("Your Feedback",
                          style: TextStyle(
                              color: disabledColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        autofocus: false,
                        controller: messageC,
                        readOnly: false,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: locale.enterYourMessage!,
                            counterText: '',
                            hintStyle: TextStyle(
                                color: kHintColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
                Divider(
                  thickness: 3.5,
                  color: Colors.transparent,
                ),
                isLoading
                    ? Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          widthFactor: 40,
                          heightFactor: 40,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
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
                                if (!isLoading) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  sendFeedBack(messageC.text);
                                                                }
                              },
                              child: Text(
                                "Submit",
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
      ),
    );
  }

  //Send feedback API call
  void sendFeedBack(dynamic message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(driverFeedbackUrl, body: {
      'dboy_id': '${preferences.getInt('db_id')}',
      'feedback': '$message'
    }).then((value) {
      print('ddv - ${value.body}');
      print("ID: ${preferences.getInt('db_id')}");
      print("Feed: $message");
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        if ('${js['status']}' == '1') {
          messageC.clear();
        }
        Toast.show(js['message'],
            duration: Toast.lengthShort, gravity: Toast.center);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  //Send callback request API call
  void sendCallBackRequest(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    http.post(driverCallbackReqUrl, body: {
      'driver_id': '${preferences.getInt('db_id')}',
    }).then((value) {
      print('ddv - ${value.body}');
      if (value.statusCode == 200) {
        var js = jsonDecode(value.body);
        Toast.show(js['message'],
            duration: Toast.lengthShort, gravity: Toast.center);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }
}
