//
//  AppDelegate.swift
//  ToDoApp
//
//

import UIKit
import CocoaLumberjackSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: RootCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        DDLog.add(DDOSLogger.sharedInstance)
        let window = UIWindow()
        self.window = window
        coordinator = RootCoordinatorImpl()
        coordinator?.start(in: window)

        return true
    }

}
