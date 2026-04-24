import 'dart:convert';
import 'dart:io';
import 'package:driver/Pages/home_page.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/Theme/style.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/CountryCodeList.dart';
import 'package:driver/beanmodel/CountryCodeModel.dart';
import 'package:driver/beanmodel/DriverData.dart';
import 'package:driver/beanmodel/GetProfileDataModel.dart';
import 'package:driver/beanmodel/PrefixCodeList.dart';
import 'package:driver/beanmodel/PrefixModelNew.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class EditProfilePage extends StatefulWidget {
  final String? countryCode;
  final String? prefixCode;

  EditProfilePage({Key? key, this.countryCode, this.prefixCode});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GetProfileDataModel? profilePeople;
  DriverData? driverData;
  var http = Client();
  bool isLoading = false;
  TextEditingController nameC = TextEditingController();
  TextEditingController genderC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  var _cPhone = TextEditingController();

  FocusNode _fPhoneCode = FocusNode();
  FocusNode _fPhoneCode1 = FocusNode();
  FocusNode _fPhone = FocusNode();

  String? dropdownValueCountryCode;
  String? dropdownValuePrefixCode;

  bool showShadow = false;
  bool showBorder = false;

  List<CountryCodeList> _countryCodeList = [];
  List<PrefixCodeList> _prefixCodeList = [];
List<String> uniqueCountryCodes = [];

  @override
  void initState() {
    super.initState();
    getDrierStatus();
    _getCountryCode();
    _getPrefixCode();
  }

  //Get driver status API call
  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    print('dboy_id: ${prefs.getInt('db_id')}');
    print(driverProfileUri);
    http.post(driverProfileUri,
        body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      print('dvd - ${value.body.toString()}');
      if (value.statusCode == 200) {
        GetProfileDataModel getProfileData =
            GetProfileDataModel.fromJson(jsonDecode(value.body));
        print("G1--->14");
        dropdownValueCountryCode =
            getProfileData.driverData!.country_code!.toString();
        dropdownValuePrefixCode =
            getProfileData.driverData!.prefix_code!.toString();
        print("countryCodeUnique" + dropdownValueCountryCode!);
        if ('${getProfileData.status}' == '1') {
          setState(() {
            profilePeople = getProfileData;
            nameC.text = '${profilePeople!.driverData!.boy_name}';
            String nPhone1;
            print("G1--->14'${getProfileData.driverData!.boy_phone}'");

            if (Platform.isIOS) {
              nPhone1 = getProfileData.driverData!.boy_phone!.substring(2);
            } else {
              nPhone1 = getProfileData.driverData!.boy_phone!.substring(2);
            }
            print('G1--->1');
            _cPhone.text = nPhone1.toString();
            emailC.text = '${getProfileData.driverData!.password}';
            prefs.setString('boy_name', '${nameC.text}');
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
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
            locale!.myAccount!.toUpperCase(),
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Divider(
                  thickness: 8,
                  color: Theme.of(context).dividerColor,
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 15),
                  child: Text(locale.profileInfo!,
                      style: TextStyle(fontSize: 16, color: disabledColor)),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(locale.fullName!.toUpperCase(),
                          style: TextStyle(
                              color: disabledColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        autofocus: false,
                        onEditingComplete: () {
                          setState(() {
                            showShadow = false;
                          });
                        },
                        onTap: () {
                          setState(() {
                            showShadow = true;
                            showBorder = true;
                          });
                        },
                        controller: nameC,
                        readOnly: false,
                        keyboardType: TextInputType.name,
                        maxLines: 1,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: "Name",
                            counterText: '',
                            hintStyle: TextStyle(fontSize: 14)),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(locale.phoneNumber!.toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).disabledColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
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
                                      return 
                                      DropdownButton<String>(
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
                                          onChanged: (value) {
                                            setState(() {
                                              dropdownValueCountryCode = value;
                                              _getCountryCode();
                                            });
                                          },
                                          items: _countryCodeList.map(
                                              (CountryCodeList countryCode) {
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
                                          }).toList()
                                          );
                                    },
                                  ),
                                ),
                              ))),
                    ),
                    Container(
                      height: 50,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(7.0))),
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
                                  _getPrefixCode();
                                },
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValuePrefixCode = value;
                                    _getPrefixCode();
                                  });
                                },
                                items: _prefixCodeList
                                    .map((PrefixCodeList prefixCode) {
                                  return DropdownMenuItem(
                                    value: prefixCode.prefix_code.toString(),
                                    child: Text(
                                      prefixCode.prefix_code.toString(),
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
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
                          style: TextStyle(fontSize: 16),
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
                SizedBox(height: 20),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(locale.password1!.toUpperCase(),
                          style: TextStyle(
                              color: disabledColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        autofocus: false,
                        onEditingComplete: () {
                          setState(() {
                            showShadow = false;
                          });
                        },
                        onTap: () {
                          setState(() {
                            showShadow = true;
                            showBorder = true;
                          });
                        },
                        controller: emailC,
                        readOnly: false,
                        keyboardType: TextInputType.name,
                        maxLines: 1,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: "Password",
                            counterText: '',
                            hintStyle: TextStyle(fontSize: 14)),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ],
        ),
        bottomNavigationBar: isLoading
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
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPurpleLight),
                      onPressed: () {
                        if (!isLoading) {
                          if (nameC.text.length > 0) {
                            if (_cPhone.text.length >= 7) {
                              if (emailC.text.length > 5) {
                                setState(() {
                                  isLoading = true;
                                });
                                updateYourProfile(context);
                              } else {
                                Toast.show(
                                    "Please enter your password", //locale.pleaseallfield,

                                    duration: Toast.lengthShort,
                                    gravity: Toast.center);
                              }
                            } else {
                              Toast.show(
                                  "Please enter your 7 digit mobile number", //locale.pleaseallfield,

                                  duration: Toast.lengthShort,
                                  gravity: Toast.center);
                            }
                          } else {
                            Toast.show(
                                "Please enter your name", //locale.pleaseallfield,

                                duration: Toast.lengthShort,
                                gravity: Toast.center);
                          }
                        } else {
                          Toast.show(
                              "Driver profile updated successfully", //locale.pleaseallfield,

                              duration: Toast.lengthShort,
                              gravity: Toast.center);
                        }
                      },
                      child: Text(
                        // locale.updateInfo!,
                        "Update Info",
                        style: TextStyle(
                            color: kWhiteColor,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                            fontSize: 16),
                      )),
                ),
              ),
      ),
    );
  }

  //Update profile API call
  void updateYourProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('dboy_id - ${prefs.getInt('db_id')}');
    print('boy_name - ${nameC.text}');
    print('boy_phone - ${_cPhone.text}');
    print('password - ${emailC.text}');

    http.post(driverupdateprofileUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'boy_name': '${nameC.text}',
      'boy_phone': '$dropdownValuePrefixCode' + '${_cPhone.text}',
      'password': '${emailC.text}',
    }).then((value) {
      print('dboy_id - ${prefs.getInt('db_id')}');
      print('boy_name - ${nameC.text}');
      print('boy_phone - ${_cPhone.text}');
      print('password - ${emailC.text}');
      print('dv - ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        prefs.setString('boy_name', '${nameC.text}');
        prefs.setString(
            'boy_phone', '$dropdownValuePrefixCode' + '${_cPhone.text}');
        prefs.setString('password', '${emailC.text}');
      }
      Toast.show(js['message'],
          duration: Toast.lengthShort, gravity: Toast.center);
      Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => HomePage()),
          (route) => false);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
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
      if (value.statusCode == 200) {
        print(' ${data1.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          print('S111>>>${data1.toString()}');
          _countryCodeList = data1.data!;
          print('CountryModelList${_countryCodeList.length}');
           uniqueCountryCodes = _countryCodeList
              .map((e) => e.country_code.toString())
              .toSet() // 🔥 removes duplicates
              .toList();

          // Safety: reset value if invalid
          if (!uniqueCountryCodes.contains(dropdownValueCountryCode)) {
            dropdownValueCountryCode = null;
          }
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
