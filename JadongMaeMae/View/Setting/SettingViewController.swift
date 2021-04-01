//
//  SettingViewController.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2021/04/02.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var funnyImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCuteImage()
    }
    
    @IBAction func tappedIPButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = URL(string: "https://api.ipify.org") else { return }
            let ipAddress = try? String(contentsOf: url)
            DispatchQueue.main.async {
                UIAlertController.simpleAlert(message: "IP Addr: " + (ipAddress ?? "Unknown"), autoClose: false)
            }
        }
    }
    
    @IBAction func tappedInsertAccessKey(_ sender: UIButton) {
        
    }
    
    @IBAction func tappedInsertSecureKey(_ sender: UIButton) {
        
    }
}

// MARK: - Setup View
extension SettingViewController {
    
    func setUpView() {
        title = "가이드"
    }
    
    func updateCuteImage() {
        funnyImageView.image = UIImage(named: "cute\(Int.random(in: 0...12))")
    }
}
