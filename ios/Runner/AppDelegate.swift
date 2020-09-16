import UIKit
import Flutter

#if canImport(WidgetKit)
import WidgetKit
#endif

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        var flutter_native_splash = 1
        UIApplication.shared.isStatusBarHidden = false
        
        GeneratedPluginRegistrant.register(with: self)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let widgetChannel = FlutterMethodChannel(name: "jp.yaegaki.dotlive-schedule/widget",
                                                 binaryMessenger: controller.binaryMessenger)
        widgetChannel.setMethodCallHandler({
            [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            guard call.method == "forceUpdateWidgets" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.forceUpdateWidgets(result: result)
        })
 
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func forceUpdateWidgets(result: FlutterResult) {
        if #available(iOS 14.0, *) {
            
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadTimelines(ofKind: "jp.yaegaki.dotlive-schedule.awaisensei2")
            #endif
        }
        
        result(Int(0))
    }
}
