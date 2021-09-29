//
//  UIApplication+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

extension UIApplication {

    var keyWindowInConnectedScenes: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }

    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {
        if let appMain = viewController as? MainViewController, let firstChildVC = appMain.children.first {
            return topViewController(firstChildVC)
        }
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
        if viewController is MainViewController {
            if let naviCon = viewController?.children.first as? UINavigationController {
                return naviCon.children.last
            } else {
                return viewController?.children.first
            }
        }
        return viewController
    }
}
