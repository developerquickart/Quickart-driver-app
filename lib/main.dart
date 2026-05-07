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
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print("AUTH STATUS => ${settings.authorizationStatus}");

    print("Permission: ${settings.authorizationStatus}");
  } catch (e) {
    print(e);
  }

  // FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //     alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  hitAppInfo();

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

class DeliveryBoyLogin extends StatefulWidget {
  @override
  _DeliveryBoyLoginState createState() => _DeliveryBoyLoginState();
}

class _DeliveryBoyLoginState extends State<DeliveryBoyLogin> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
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
    super.dispose();
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
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin!.initialize(initSettings);

    print("LISTENER ATTACHED");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 FOREGROUND PUSH RECEIVED");
      print("TITLE => ${message.notification?.title}");
      print("BODY => ${message.notification?.body}");

      await _handleForegroundMessage(message);
    });
  }
Future<void> _handleForegroundMessage(RemoteMessage message) async {
  try {
    print("✅ Notification Call");

    String title =
        message.notification?.title ?? message.data['title'] ?? "Title";

    String body =
        message.notification?.body ?? message.data['body'] ?? "Body";

    /// ✅ SHOW LOCAL NOTIFICATION ONLY FOR ANDROID
    if (Platform.isAndroid) {
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
        ),
      );
    }

    /// 🚫 PREVENT MULTIPLE DIALOGS
    if (isDialogShowing) return;

    isDialogShowing = true;

    /// ✅ SMALL DELAY FOR iOS UI READY
    await Future.delayed(const Duration(milliseconds: 300));

    final context = navigatorKey.currentState?.overlay?.context;

    print("Before dialog");
    print("Context => $context");

    if (context == null) {
      print("❌ Context NULL");
      isDialogShowing = false;
      return;
    }

    /// 🔊 PLAY SOUND
    await player.stop();
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('audio/buzzer.mp3'));

    /// ✅ SHOW ALERT
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);

              await player.stop();

              isDialogShowing = false;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZapTodayOrder(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
            child: const Text(
              "Go Order",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    /// 🔇 STOP SOUND WHEN DIALOG CLOSED
    await player.stop();

    isDialogShowing = false;
  } catch (e) {
    print("❌ Error => $e");

    await player.stop();

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
