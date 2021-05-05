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
        
        #if DEBUG
        guard AppData.accessKey == "", AppData.secretKey == "" else { return true }
        guard let accessKey = FileController().readFile(name: "accessKey")?.replacingOccurrences(of: "\n", with: ""),
              let secretKey = FileController().readFile(name: "secretKey")?.replacingOccurrences(of: "\n", with: "") else {
            fatalError("'accessKey' and 'secretKey' file is required in proj root.")
        }
        AppData.accessKey = accessKey
        AppData.secretKey = secretKey
        #endif
        
        return true
    }
}
