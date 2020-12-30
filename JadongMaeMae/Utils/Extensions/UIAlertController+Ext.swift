//
//  UIAlertController+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import UIKit

extension UIAlertController {
    typealias ConfirmActionHandler = (() -> Void)

    static func simpleAlert(message: String, completion: ConfirmActionHandler? = nil) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            completion?()
        }))
        DispatchQueue.main.async {
            guard let topVC = UIApplication.topViewController() else { return }
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = topVC.view
                    popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    topVC.present(alert, animated: true, completion: nil)
                }
            } else {
                topVC.present(alert, animated: true)
            }
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(5)) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}
