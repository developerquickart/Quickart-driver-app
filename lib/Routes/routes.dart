import 'package:driver/Pages/About/about_us.dart';
import 'package:driver/Pages/About/contact_us.dart';
import 'package:driver/Pages/Zap%20orders/order_root_map.dart';
import 'package:driver/Pages/accepted_order.dart';
import 'package:driver/Pages/edit_profile.dart';
import 'package:driver/Pages/home_page.dart';
import 'package:driver/Pages/insight_page.dart';
import 'package:driver/Pages/iteminfopage.dart';
import 'package:driver/Pages/notification_list.dart';
import 'package:driver/Pages/order_delivered.dart';
import 'package:driver/Pages/order_history.dart';
import 'package:driver/Pages/orderpage/todayorder.dart';
import 'package:driver/Pages/product_list.dart';
import 'package:driver/Pages/signature/cancel_order_screen.dart';
import 'package:driver/Pages/signature/signatureview.dart';
import 'package:driver/Pages/tncpage/tnc_page.dart';
import 'package:flutter/material.dart';

class PageRoutes {
  static const String homePage = 'home_page';
  static const String insightPage = 'insight_page';
  static const String languagePage = 'language_page';
  static const String walletPage = 'wallet_page';
  static const String addToBank = 'add_to_bank';
  static const String editProfilePage = 'edit_profile';
  static const String orderHistoryPage = 'order_history';
  static const String orderDeliveredPage = 'order_delivered';
  static const String newDeliveryPage = 'new_delivery';
  static const String contactUs = 'contact_us';
  static const String notificationList = 'notification_list';
  static const String orderAcceptedPage = 'order_accepted';
  static const String cancelOrderScreen = 'cancel_order';
  static const String todayOrderscreen = 'todayOrder';
  static const String productListScreen = 'product_list';
  static const String orderRootMapScreen = 'order_root_map';

  static const String tnc = 'tnc';
  static const String aboutus = 'aboutus';
  static const String iteminfo = 'iteminfo';
  static const String signatureview = 'signatureview';
  static const String langnew = '/langnew';

  Map<String, WidgetBuilder> routes() {
    return {
      homePage: (context) => HomePage(),
      insightPage: (context) => InsightPage(),
      editProfilePage: (context) => EditProfilePage(),
      orderHistoryPage: (context) => OrderHistoryPage(),
      orderDeliveredPage: (context) => OrderDeliveredPage(),
      notificationList: (context) => NotificationListPage(),
      contactUs: (context) => ContactUsPage(),
      orderAcceptedPage: (context) => OrderAcceptedPage(),
      tnc: (context) => TNCPage(),
      aboutus: (context) => AboutUsPage(),
      iteminfo: (context) => ItemInformation(),
      signatureview: (context) => SignatureView(),
      cancelOrderScreen: (context) => CancelOrderScreen(),
      todayOrderscreen: (context) => TodayOrder(),
      productListScreen: (context) => ProductList(),
      orderRootMapScreen: (context) => OrderRootMapScreen(),
    };
  }
}
