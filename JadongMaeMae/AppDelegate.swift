//
//  AppDelegate.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = GlobalTimer()
        
        return true
    }
}
