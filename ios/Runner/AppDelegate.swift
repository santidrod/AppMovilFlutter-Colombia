import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var visualEffectView = UIVisualEffectView()
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self // as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        self.visualEffectView.removeFromSuperview()
    }

    override func applicationWillResignActive(_ application: UIApplication) {
    if !self.visualEffectView.isDescendant(of: self.window!) {
        let blurEffect = UIBlurEffect(style: .light)
        self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        self.visualEffectView.frame = (self.window?.bounds)!
        self.window?.addSubview(self.visualEffectView)
       }
    }
    override func applicationDidBecomeActive(_ application: UIApplication) {
        self.visualEffectView.removeFromSuperview()
    }
    
}
