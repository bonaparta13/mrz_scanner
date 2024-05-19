import UIKit
import Flutter
import AudioToolbox


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      AudioServicesPlaySystemSound(1108)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
