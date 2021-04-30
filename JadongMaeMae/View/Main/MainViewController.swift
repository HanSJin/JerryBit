//
//  MainViewController.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

class MainViewController: BaseViewController {
    
    static var current: MainViewController? {
        var appMain = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController as? MainViewController
        if appMain == nil {
            appMain = UIApplication.shared.windows.first?.rootViewController as? MainViewController
        }
        return appMain
    }
}

// MARK: - Life Cycles
extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController() as! TabBarViewController
        open(to: tabBarVC)
    }
}

// MARK: - Open VC
extension MainViewController {
    
}

// MARK: - Private
extension MainViewController {
    
    func open(to viewController: UIViewController) {
        guard removeAllChildViewController() else { return }

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)

        viewController.view.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            viewController.view.alpha = 1.0
        }
    }

    func removeAllChildViewController() -> Bool {
        for childVC in children {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        return true
    }
}
