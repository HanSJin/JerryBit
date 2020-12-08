//
//  MainViewController.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

class MainViewController: UIViewController {

}

// MARK: - Life Cycles
extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let myAccountVC = UIStoryboard(name: "MyAccount", bundle: nil).instantiateInitialViewController() as! MyAccountViewController
//        open(to: myAccountVC)
        
        let tradeMachineVC = UIStoryboard(name: "TradeMachine", bundle: nil).instantiateInitialViewController() as! TradeMachineViewController
        open(to: tradeMachineVC)
    }
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
