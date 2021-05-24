import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
     GMSServices.provideAPIKey("AIzaSyDyB4kxeHpdOfd0xW6PZuZIhV7ricz2drQ")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
