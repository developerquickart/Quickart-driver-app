import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:driver/Auth/Login/sign_in.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/Zap%20orders/zap_todayorder.dart';
import 'package:driver/Pages/home_page.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/style.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/appinfo.dart';
import 'package:driver/language_cubit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beanmodel/localNotificationModel.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final player = AudioPlayer();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification!.title
      .toString()
      .contains("Hey there! You got a new  order for delivery")) {
    player.play(AssetSource('audio/buzzer.mp3'));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15 Changes Enable Edge-to-Edge Mode
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print(e);
  }

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  hitAppInfo();

  HttpOverrides.global = new MyHttpOverrides();

  HttpOverrides.global = new MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('versionPop', 'show');
  bool? result;
  if (prefs.containsKey('islogin')) {
    result = prefs.getBool('islogin');
  } else {
    result = false;
  }
  runApp(Phoenix(
      child:
          (result != null && result) ? DeliveryBoyHome() : DeliveryBoyLogin()));
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  description: 'Channel Description',
  playSound: true,
  sound: RawResourceAndroidNotificationSound('buzzer'),
);
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   try {
//     await Firebase.initializeApp();
//     print('Handling a background message ${message.messageId}');
//   } catch (e) {
//     print('Exception - main.dart - _firebaseMessagingBackgroundHandler(): ' +
//         e.toString());
//   }
// }

//App info API call
void hitAppInfo() async {
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
  }).then((value) async {
    print('appInfoUrl: ${appInfoUri}');
    print(value.body);
    if (value.statusCode == 200) {
      AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
      if (data1.status == "1" || data1.status == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

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

class DeliveryBoyLogin extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String navigationActionId = 'id_3';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: SignIn(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _stopSound();
    dispose();
  }

  void _stopSound() {
    player.stop();
  }

  @override
  void initState() {
    isShowAlert = true;
    initState();
    setFNotification();
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  //Set notification function
  void setFNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin!.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        if (message != null && message.data != null) {
          LocalNotification _notificationModel =
              LocalNotification.fromJson(message.data);
          localNotificationModel = _notificationModel;
          isChatNotTapped = false;
        }

        if (message.notification != null) {
          Future<String> _downloadAndSaveFile(
              String url, String fileName) async {
            final Directory directory =
                await getApplicationDocumentsDirectory();
            final String filePath = '${directory.path}/$fileName';
            final http.Response response = await http.get(Uri.parse(url));
            final File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            return filePath;
          }

          if (Platform.isAndroid) {
            String bigPicturePath;
            AndroidNotificationDetails androidPlatformChannelSpecifics;
            if (message.notification!.android!.imageUrl != null &&
                '${message.notification!.android!.imageUrl}' != 'N/A') {
              print('in Image');
              print('${message.notification!.android!.imageUrl}');
              bigPicturePath = await _downloadAndSaveFile(
                  message.notification!.android!.imageUrl != null
                      ? message.notification!.android!.imageUrl!
                      : 'https://picsum.photos/200/300',
                  'bigPicture');
              final BigPictureStyleInformation bigPictureStyleInformation =
                  BigPictureStyleInformation(
                FilePathAndroidBitmap(bigPicturePath),
              );
              // androidPlatformChannelSpecifics = AndroidNotificationDetails(
              //     channel.id, channel.name,
              //     channelDescription: channel.description,
              //     icon: 'ic_notification',
              //     styleInformation: bigPictureStyleInformation,
              //     playSound: true);
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  channel.id, channel.name,
                  channelDescription: channel.description,
                  // sound:
                  //     RawResourceAndroidNotificationSound('audio/buzzer.mp3'),
                  sound: RawResourceAndroidNotificationSound('buzzer'),
                  icon: 'ic_notification',
                  styleInformation: bigPictureStyleInformation,
                  playSound: true);
            } else {
              print('in No Image');
              // androidPlatformChannelSpecifics = AndroidNotificationDetails(
              //     channel.id, channel.name,
              //     channelDescription: channel.description,
              //     icon: 'ic_notification',
              //     styleInformation:
              //         BigTextStyleInformation(message.notification!.body!),
              //     playSound: true);
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  channel.id, channel.name,
                  channelDescription: channel.description,
                  sound:
                      RawResourceAndroidNotificationSound('audio/buzzer.mp3'),
                  icon: 'ic_notification',
                  styleInformation:
                      BigTextStyleInformation(message.notification!.body!),
                  playSound: true);
            }
            final NotificationDetails platformChannelSpecifics =
                NotificationDetails(android: androidPlatformChannelSpecifics);
            flutterLocalNotificationsPlugin!.show(
                1,
                message.notification!.title,
                message.notification!.body,
                platformChannelSpecifics);
          } else if (Platform.isIOS) {
            final String bigPicturePath = await _downloadAndSaveFile(
                message.notification!.apple!.imageUrl != null
                    ? message.notification!.apple!.imageUrl!
                    : 'https://picsum.photos/200/300',
                'bigPicture.jpg');
            final DarwinNotificationDetails iOSPlatformChannelSpecifics =
                DarwinNotificationDetails(
                    attachments: <DarwinNotificationAttachment>[
                  DarwinNotificationAttachment(bigPicturePath)
                ],
                    presentSound: true);
            final DarwinNotificationDetails iOSPlatformChannelSpecifics2 =
                DarwinNotificationDetails(presentSound: true);
            final NotificationDetails notificationDetails = NotificationDetails(
              iOS: message.notification!.apple!.imageUrl != null
                  ? iOSPlatformChannelSpecifics
                  : iOSPlatformChannelSpecifics2,
            );
            await flutterLocalNotificationsPlugin!.show(
                1,
                message.notification!.title,
                message.notification!.body,
                notificationDetails);
          }
          await flutterLocalNotificationsPlugin!.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse:
                (NotificationResponse notificationResponse) {
              switch (notificationResponse.notificationResponseType) {
                case NotificationResponseType.selectedNotification:
                  selectNotificationStream.add(notificationResponse.payload);
                  break;
                case NotificationResponseType.selectedNotificationAction:
                  if (notificationResponse.actionId == navigationActionId) {
                    selectNotificationStream.add(notificationResponse.payload);
                  }
                  break;
              }
            },
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground,
          );
        }
      } catch (e) {
        print('Exception - main.dart - onMessage.listen(): ' + e.toString());
      }
    });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   print("onMessageOpenedApp: $message");
    //   Navigator.popAndPushNamed(
    //       navigatorKey.currentState!.context, PageRoutes.notificationList);
    // });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: $message");

      Navigator.popAndPushNamed(
          navigatorKey.currentState!.context, PageRoutes.notificationList);
      _stopSound();
    });
  }
}

// class DeliveryBoyHome extends StatelessWidget {
class DeliveryBoyHome extends StatefulWidget {
  @override
  _DeliveryBoyHomeState createState() => _DeliveryBoyHomeState();
}

class _DeliveryBoyHomeState extends State<DeliveryBoyHome> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isDialogShowing = false;
  String navigationActionId = 'id_3';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageCubit>(
      create: (context) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (_, locale) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: "Quickart Driver",
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ar'),
              const Locale('pt'),
              const Locale('fr'),
              const Locale('id'),
              const Locale('es'),
            ],
            locale: locale,
            theme: appTheme,
            home: HomePage(),
            routes: PageRoutes().routes(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _stopSound();
    dispose();
  }

  void _stopSound() {
    player.stop();
  }

  @override
  void initState() {
    super.initState(); // ✅ MUST call this
    isShowAlert = true;
    setFNotification();
  }

  //Background notification function
  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  Future<void> setFNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // ✅ Channel
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ✅ Permission (Android 13+)
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin!.initialize(initSettings);

    /// 🔥 FOREGROUND LISTENER
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 MESSAGE RECEIVED");

      _handleForegroundMessage(message);
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      print("✅ Notification Call");

      String title =
          message.notification?.title ?? message.data['title'] ?? "Title";

      String body =
          message.notification?.body ?? message.data['body'] ?? "Body";

      String payloadData = message.data.toString();

      /// 🔔 Show notification (optional sound)
      await flutterLocalNotificationsPlugin!.show(
        1,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('buzzer'),
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payloadData,
      );

      /// 🚫 Prevent multiple dialogs
      if (isDialogShowing) return;
      isDialogShowing = true;

      /// 🔥 Ensure UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final context = navigatorKey.currentState?.overlay?.context;

        if (context != null) {
          /// 🔊 PLAY SOUND ONLY ONCE
          // await player.stop(); // safety
          await player.setReleaseMode(ReleaseMode.loop);
          await player.play(AssetSource('audio/buzzer.mp3'));

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.blue.shade900, // 🔵 dialog background

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              title: Text(
                title,
                style: TextStyle(
                  color: Colors.white, // ✅ title color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              content: Text(
                body,
                style: TextStyle(
                  color: Colors.white70, // ✅ content text color
                  fontSize: 15,
                ),
              ),

              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange, // 🟠 button background
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    /// 🔇 STOP SOUND
                    player.stop();
                    isDialogShowing = false;
                    
                     Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ZapTodayOrder();
                      })).then((value) {
                        setState(() {
                
                        });
                      });
                  },
                  child: const Text(
                    "Go Order",
                    style: TextStyle(
                      color: Colors.white, // ✅ button text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          print("❌ Dialog context not available");
          isDialogShowing = false;
        }
      });
    } catch (e) {
      print("❌ Error: $e");
      isDialogShowing = false;
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return new MyHttpClient(super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true);
  }
}

class MyHttpClient implements HttpClient {
  HttpClient _realClient;

  MyHttpClient(this._realClient);

  @override
  bool get autoUncompress => _realClient.autoUncompress;

  @override
  set autoUncompress(bool value) => _realClient.autoUncompress = value;

  @override
  Duration? get connectionTimeout => _realClient.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) =>
      _realClient.connectionTimeout = value;

  @override
  Duration get idleTimeout => _realClient.idleTimeout;

  @override
  set idleTimeout(Duration value) => _realClient.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _realClient.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) =>
      _realClient.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _realClient.userAgent;

  @override
  set userAgent(String? value) => _realClient.userAgent = value;

  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _realClient.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _realClient.addProxyCredentials(host, port, realm, credentials);

  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _realClient.authenticate = f;

  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _realClient.authenticateProxy = f;

  @override
  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _realClient.badCertificateCallback = callback;

  @override
  void close({bool force = false}) => _realClient.close(force: force);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _realClient.delete(host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _realClient.deleteUrl(url);

  @override
  set findProxy(String Function(Uri url)? f) => _realClient.findProxy = f;

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _updateHeaders(_realClient.get(host, port, path));

  Future<HttpClientRequest> _updateHeaders(
      Future<HttpClientRequest> httpClientRequest) async {
    return (await httpClientRequest)
      ..headers.add("Access-Control-Allow-Origin", "*")
      ..headers.add("Access-Control-Allow-Headers",
          "Origin, X-Requested-With, Content-Type, Accept, Authorization")
      ..headers
          .add("Access-Control-Allow-Methods", "PUT, POST, DELETE, GET, PATCH");
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _updateHeaders(_realClient.getUrl(url.replace(path: url.path)));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _realClient.head(host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _realClient.headUrl(url);

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _realClient.open(method, host, port, path);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _realClient.openUrl(method, url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _realClient.patch(host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _realClient.patchUrl(url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _realClient.post(host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _realClient.postUrl(url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _realClient.put(host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _realClient.putUrl(url);

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(
              Uri url, String proxyHost, int proxyPort)?
          f) {
    // TODO: implement connectionFactory
  }

  @override
  set keyLog(Function(String line)? callback) {
    // TODO: implement keyLog
  }
}
