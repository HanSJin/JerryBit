//
//  AppDelegate.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printIpAddress()
        _ = GlobalTimer()
        
        return true
    }
    
    private func printIpAddress() {
        guard let url = URL(string: "https://api.ipify.org") else { return }
        let ipAddress = try? String(contentsOf: url)
        print("My public IP address is: " + (ipAddress ?? "Unknown"))
    }
}

