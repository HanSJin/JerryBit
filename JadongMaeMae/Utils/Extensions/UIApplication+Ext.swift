//
//  UIApplication+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

extension UIApplication {

    var keyWindowInConnectedScenes: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }

    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if viewController is UIAlertController {
            return viewController?.presentingViewController
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
}
