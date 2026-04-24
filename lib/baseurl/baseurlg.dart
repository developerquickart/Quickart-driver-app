import 'package:shared_preferences/shared_preferences.dart';

// String imagebaseUrl1 = 'https://quickart.ae/admin/';
//  String imagebaseUrl1 = 'https://quickart2.democheck.in/admin/';
 String imagebaseUrl1 = 'https://admin.quickart.ae/';
//  String imagebaseUrl1 = 'https://demoadmin.quickart.ae/';
//Zap orders...G1
// String imagebaseUrl1 = 'https://zap-admin-production.up.railway.app/';
String zaporderBaseURL = "";//'https://zap-admin-production.up.railway.app/api/';

var dBoyLat;
var dBoyLng;
var imagebaseUrl;
void getImageBaseUrl() async {
  SharedPreferences.getInstance().then((value) {
    if (value.containsKey('imagebaseurl')) {
      imagebaseUrl = value.getString('imagebaseurl')! + '/';
    } else {
      imagebaseUrl = imagebaseUrl1;
    }
  });
}

// *Api Endpoints
var apibaseUrl = imagebaseUrl1 + 'api/';
var dirverBaseUrl = imagebaseUrl1 + 'api/';
var cityUri = Uri.parse('${apibaseUrl}city');
var appInfoUri = Uri.parse('${apibaseUrl}app_info');
var appTermsUri = Uri.parse('${apibaseUrl}appterms');
var loginUrl = Uri.parse('${dirverBaseUrl}driver_login');
var driverCallbackReqUrl = Uri.parse('${dirverBaseUrl}driver_callback_req');
var driverFeedbackUrl = Uri.parse('${dirverBaseUrl}driver_feedback');
var completedOrdersUrl = Uri.parse('${dirverBaseUrl}completed_orders');
var appAboutusUri = Uri.parse('${apibaseUrl}appaboutus');
var driverNotificationUri = Uri.parse(
  '${dirverBaseUrl}driver_notificationlist',
);
var driverDeleteAllNotificationUri = Uri.parse(
  '${dirverBaseUrl}driver_delete_all_notification',
);
var updateStatusUri = Uri.parse('${dirverBaseUrl}update_status');
var ordersfortodayUri = Uri.parse('${dirverBaseUrl}ordersfortoday');
var ordersfornextdayUri = Uri.parse('${dirverBaseUrl}ordersfornextday');
var outForDeliveryUri = Uri.parse('${dirverBaseUrl}out_for_delivery');
var deliveryCompletedUri = Uri.parse('${dirverBaseUrl}delivery_completed');
var driverStatusUri = Uri.parse('${dirverBaseUrl}driver_status');
var driverBankUri = Uri.parse('${dirverBaseUrl}driver_bank');
var driverProfileUri = Uri.parse('${dirverBaseUrl}driver_profile');
var driverupdateprofileUri = Uri.parse('${dirverBaseUrl}driverupdateprofile');
var updatelatlng = Uri.parse('${dirverBaseUrl}latlngupdate');
var fcmUpdate = Uri.parse('${dirverBaseUrl}update_fcm_token');
var countryCodeUri = Uri.parse('${dirverBaseUrl}country_code_list');
var prefixCodeUri = Uri.parse('${dirverBaseUrl}prefix_code_list');
var driverDeactivate = Uri.parse('${apibaseUrl}driver_deactivate');
var cancellationReasons = Uri.parse('${apibaseUrl}cancelorderreason');
var cancelOrder = Uri.parse('${apibaseUrl}cancel_order');
var isProdSelected = Uri.parse('${apibaseUrl}is_prod_selected');
var isProdUnSelected = Uri.parse('${apibaseUrl}is_prod_unselected');
var cancelitemlist = Uri.parse('${apibaseUrl}cancelitemlist');


// Zap orders apis
var zapOrdersfortodayUri = Uri.parse('${zaporderBaseURL}zapordersfortoday');
var zapCancelitemlist = Uri.parse('${zaporderBaseURL}cancelitemlist');
var zapCancellationReasons = Uri.parse('${zaporderBaseURL}cancelorderreason');
var zapOutForDeliveryUri = Uri.parse('${zaporderBaseURL}out_for_delivery');
var zapUpdatelatlng = Uri.parse('${zaporderBaseURL}latlngupdate');
var zapProdSelected = Uri.parse('${zaporderBaseURL}is_prod_selected');
var zapProdUnSelected = Uri.parse('${zaporderBaseURL}is_prod_unselected');
var zapCancelOrder = Uri.parse('${zaporderBaseURL}cancel_order');
var zapDeliveryCompletedUri = Uri.parse('${zaporderBaseURL}delivery_completed');






