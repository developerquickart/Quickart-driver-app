import UIKit
import Flutter
import GoogleMaps
// import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//     FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // GMSServices.provideAPIKey("your map key which is associated in google-info.plist")
        GMSServices.provideAPIKey("AIzaSyBKtnluPAjGVlf1qUC6QpxYFFJ-00fjcvE")
  //  if #available(iOS 10.0, *) {
  //    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  //  }
  //     UNUserNotificationCenter.current().delegate = self
           if #available(iOS 10.0, *) {
  // For iOS 10 display notification (sent via APNS)
  UNUserNotificationCenter.current().delegate = self
  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
  UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: { _, _ in }
  )
} else {
  let settings: UIUserNotificationSettings =
    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
  application.registerUserNotificationSettings(settings)
}
application.registerForRemoteNotifications()


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            completionHandler([.alert, .badge, .sound])
            
        }
    
}
