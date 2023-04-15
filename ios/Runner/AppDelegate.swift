import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
//      if (IS_IOS_(10)) {
//           [self networkStatus:application didFinishLaunchingWithOptions:launchOptions];
//       }else {
//           //2.2已经开启网络权限 监听网络状态
//           [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
//       }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
