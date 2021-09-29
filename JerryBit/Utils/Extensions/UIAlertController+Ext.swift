//
//  UIAlertController+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/09.
//

import UIKit

extension UIAlertController {
    typealias ConfirmActionHandler = (() -> Void)

    static func simpleAlert(message: String, completion: ConfirmActionHandler? = nil, autoClose: Bool = true) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            completion?()
        }))
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(alert, animated: true)
        }
        guard autoClose else { return }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(5)) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}
