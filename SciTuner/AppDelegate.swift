//
//  AppDelegate.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 11.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let tuner = Tuner.sharedInstance
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = Style.background
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        tuner.isActive = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        tuner.isActive = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        tuner.isActive = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        tuner.isActive = true
    }


}

