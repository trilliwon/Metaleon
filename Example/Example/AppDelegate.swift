//
//  AppDelegate.swift
//  Metaleon
//
//  Created by trilliwon on 07/05/2019.
//  Copyright © 2024 trilliwon.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let rootViewController = CameraViewController()
        rootViewController.view.frame = UIScreen.main.bounds
        rootViewController.view.backgroundColor = .black
        rootViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        return true
    }
}
