import Flutter
import UIKit
import Foundation
import Darwin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Gestion des exceptions non gérées
    NSSetUncaughtExceptionHandler { exception in
      NSLog("❌ Uncaught Exception: \(exception)")
      NSLog("Stack trace: \(exception.callStackSymbols)")
    }
    
    // Gestion des signaux (SIGABRT, SIGSEGV, etc.)
    signal(SIGABRT) { _ in
      NSLog("❌ SIGABRT signal received")
    }
    signal(SIGSEGV) { _ in
      NSLog("❌ SIGSEGV signal received")
    }
    
    // Enregistrement des plugins
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
